#!/usr/bin/env bash
# Installs the lanicOS greeter into /usr/share/greeter and locks it down, safe to re-run.
# --preview builds an unprivileged copy in $XDG_RUNTIME_DIR and runs it instead.
# Installing greetd and switching display managers are manual steps, see README.md.
set -euo pipefail
umask 022

readonly GREETER_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
readonly REPO=$(dirname "$GREETER_DIR")
readonly DEST=/usr/share/greeter
readonly STATE_DIR=/var/lib/lanicos-greeter
readonly GREETD_CONFIG=/etc/greetd/config.toml
# settings/ is never used by the greeter, but bar/ files import it
readonly SHARED=(bar colors components config fonts services settings types widgets)

OWNER=$(stat -c %U "$REPO")
OWNER_HOME=$(getent passwd "$OWNER" | cut -d: -f6)
TMP_PATHS=()
trap 'rm -rf -- "${TMP_PATHS[@]}"' EXIT

log() { printf 'copy-greeter: %s\n' "$*"; }
warn() { printf 'copy-greeter: warning: %s\n' "$*" >&2; }
die() {
    printf 'copy-greeter: error: %s\n' "$*" >&2
    exit 1
}

build_tree() {
    local dir=$1 module wallpaper

    mkdir -p "$dir/greeter"
    cp "$GREETER_DIR/shell.qml" "$GREETER_DIR/hyprland.lua" "$dir/"
    cp "$GREETER_DIR/qmldir" "$dir/greeter/"
    cp -r "$GREETER_DIR/assets/" "$dir/"

    find "$GREETER_DIR" -maxdepth 1 -name '*.qml' ! -name shell.qml -exec cp -t "$dir/greeter/" {} +

    for module in "${SHARED[@]}"; do
        cp -rL "$REPO/$module" "$dir/"
    done

    wallpaper=$(readlink -f "$OWNER_HOME/.config/hypr/CURRENT_WALLPAPER" || true)
    if [[ -n $wallpaper && -f $wallpaper ]]; then
        cp "$wallpaper" "$dir/assets/wallpaper"
    else
        warn "no wallpaper behind $OWNER_HOME/.config/hypr/CURRENT_WALLPAPER, using a plain background"
    fi
}

secure_tree() {
    chown -R root:root "$1"
    find "$1" -type d -exec chmod 755 {} +
    find "$1" -type f -exec chmod 644 {} +
}

preview() {
    [[ $EUID -ne 0 ]] || die "--preview runs as your user, not as root"
    local dir=${XDG_RUNTIME_DIR:?}/lanicos-greeter-preview

    rm -rf -- "$dir"
    build_tree "$dir"
    log "previewing $dir, press Escape in the password field to quit"
    exec quickshell -p "$dir"
}

install_files() {
    local stage

    if [[ -e $DEST ]] && ! grep -qx 'module qs.greeter' "$DEST/greeter/qmldir" 2>/dev/null; then
        die "$DEST exists but is not a lanicOS greeter, refusing to replace it"
    fi

    stage=$(mktemp -d "$DEST.XXXXXX")
    TMP_PATHS+=("$stage")
    build_tree "$stage"
    secure_tree "$stage"

    if [[ -d $DEST ]] && diff -rq "$stage" "$DEST" >/dev/null 2>&1; then
        secure_tree "$DEST"
        log "$DEST already up to date"
        return
    fi

    rm -rf -- "$DEST.old"
    if [[ -e $DEST ]]; then
        mv -T -- "$DEST" "$DEST.old"
    fi
    mv -T -- "$stage" "$DEST"
    rm -rf -- "$DEST.old"
    log "installed $DEST"
}

install_state() {
    local home

    install -d -o greeter -g greeter -m 700 "$STATE_DIR"

    # Hyprland and quickshell keep caches in the greeter's home, which sysusers doesn't create
    home=$(getent passwd greeter | cut -d: -f6)
    if [[ -n $home && $home != / && ! -e $home ]]; then
        install -d -o greeter -g greeter -m 700 "$home"
        log "created greeter home $home"
    fi
}

install_greetd_config() {
    local config

    config=$(mktemp)
    TMP_PATHS+=("$config")
    cat >"$config" <<EOF
[terminal]
vt = 1

[default_session]
command = "start-hyprland -- --config $DEST/hyprland.lua"
user = "greeter"
EOF

    chown root:root /etc/greetd
    chmod 755 /etc/greetd

    if cmp -s "$config" "$GREETD_CONFIG"; then
        chown root:root "$GREETD_CONFIG"
        chmod 644 "$GREETD_CONFIG"
        log "$GREETD_CONFIG already up to date"
        return
    fi

    if [[ -e $GREETD_CONFIG && ! -e $GREETD_CONFIG.orig ]]; then
        cp -a "$GREETD_CONFIG" "$GREETD_CONFIG.orig"
        log "backed up the original config to $GREETD_CONFIG.orig"
    fi
    install -o root -g root -m 644 "$config" "$GREETD_CONFIG"
    log "wrote $GREETD_CONFIG"
}

check_fonts() {
    local families family

    families=$(fc-list : family)
    for family in "Orbitron" "JetBrainsMono Nerd Font"; do
        grep -qiF "$family" <<<"$families" || warn "font \"$family\" is not installed system-wide, the greeter can't use it"
    done
}

install_greeter() {
    if [[ $EUID -ne 0 ]]; then
        exec sudo -- "$GREETER_DIR/copy-greeter.sh"
    fi

    [[ -f $REPO/colors/Colors.qml ]] || die "colors/Colors.qml is missing, generate it with matugen first"
    if [[ ! -d /etc/greetd ]] || ! getent passwd greeter >/dev/null; then
        die "greetd is not installed, see the Setup section of $GREETER_DIR/README.md"
    fi

    log "checking hyprland.lua"
    runuser -u "$OWNER" -- env XDG_RUNTIME_DIR="/run/user/$(id -u "$OWNER")" \
        Hyprland --verify-config --config "$GREETER_DIR/hyprland.lua" >/dev/null \
        || die "Hyprland rejected hyprland.lua, run: Hyprland --verify-config --config $GREETER_DIR/hyprland.lua"

    install_files
    install_state
    install_greetd_config
    check_fonts

    log "done, enable greetd as described in $GREETER_DIR/README.md if not already"
}

case ${1:-} in
    --preview) preview ;;
    "") install_greeter ;;
    *) die "usage: copy-greeter.sh [--preview]" ;;
esac
