User : I want to move my current sddm login setup to a quickshell custom interface and use https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Greetd/ 

## What the Quickshell side does

`Greetd` is a singleton that talks to a running greetd daemon. The docs say it lets you authenticate a user and launch a session. You write the whole greeter UI in QML, and Quickshell handles the greetd protocol.

The flow looks like this:

1. Call `createSession(user)`.
2. greetd (via PAM) sends `authMessage` signals. If `responseRequired` is set, you show a prompt and answer with `respond(text)`. Messages with `error` set are recoverable problems, like a fingerprint misread.
3. A bad password or timeout arrives as `authFailure`. Success arrives as `readyToLaunch`.
4. Call `launch(["Hyprland"])`, optionally with an environment list. This ends Quickshell.

The docs warn that greetd expects the greeter to exit quickly after you set the session. Do any animations *before* calling `launch`, or the greeter may be restarted.

Sources: [Quickshell.Services.Greetd](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Greetd/) and [Greetd type reference](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Greetd/Greetd). The GDM comparison and greetd daemon details are from my general knowledge, not those pages.

User : Currently I have sddm as a display manager that runs before and executes hyprland wrapped by uwsm. how does greetd and a potential quickshell implementation i could build integrates / replaces those

greetd would replace SDDM

## How the login chain changes

Today SDDM starts its own greeter, lists the sessions from `/usr/share/wayland-sessions`, and runs the entry you pick. That entry is usually the uwsm one, whose Exec line is roughly `uwsm start ... hyprland.desktop`.

With greetd:

1. greetd starts your greeter command as a dedicated `greeter` user. A typical `config.toml` entry is `command = "cage -s -- quickshell -p /etc/greetd/quickshell"`.
2. `cage` (or a minimal Hyprland) is only there to give the greeter a display. It is not your real session.
3. Your QML calls `Greetd.createSession(user)`, handles the PAM prompts, and waits for `readyToLaunch`.
4. You call `Greetd.launch([...])` with the same command SDDM's desktop entry would have run. For you, that is the uwsm start command that wraps Hyprland.
5. The greeter exits, and greetd starts your real session, which uwsm then manages like it does today.

The greeter never runs under uwsm, and uwsm only wraps the real session.

## Things you have to build yourself

SDDM gives you these for free, and greetd doesn't:

- **Session list.** Parse `/usr/share/wayland-sessions/*.desktop` yourself (for example with `Process` or `FileView`), or hardcode your one session if you only use Hyprland.
- **User list and remembered choices.** Read `/etc/passwd` or hardcode your user. Store the last user and session in a state file the `greeter` user can write.
- **Power buttons.** Call `systemctl poweroff` and similar via `Process`.
- **File permissions.** The greeter runs as a different user and can't read your home directory. Keep the greeter's QML, fonts and wallpaper somewhere world-readable, such as `/etc/greetd/` or `/usr/share/`.

A bonus is that you can share your theme singleton and components between the greeter and your in-session shell, so the login screen matches. Copy or symlink the shared files into that readable location, because the greeter can't see `~/.config`.

## Migration advice

- **Only one display manager can own `display-manager.service`.** Disable SDDM and enable greetd, e.g. `systemctl disable sddm && systemctl enable greetd`.
- **Keep TTY access** so a broken greeter doesn't lock you out of the machine.

## Sutff about permissions

Mostly yes, but the docs let me tighten a few of the claims I made. Here is what the v0.3.1 docs confirm and what they don't.

## Confirmed

- **Discovery only looks at direct children.** The docs say Quickshell searches the `quickshell` subfolder of every XDG config path. Each named subfolder containing a `shell.qml` is a config. Your `quickshell/myconfig/greeter/shell.qml` is two levels down, so it isn't treated as a config. It only runs if you point at it explicitly.
- **`-p` accepts raw `.qml` files.** The docs say configs outside the XDG paths, "including raw qml files", can be run with `--path` or `-p`. So `-p .../greeter/greeter.qml` is valid. `QS_CONFIG_PATH` is documented as equivalent to `--path`, which is handy for greetd.
- **Uppercase filenames are importable as types.** Any `.qml` file starting with an uppercase letter can be referenced by name. A lowercase `shell.qml` can't be used that way, as I said.

## Corrections to what I said earlier

1. **Live reload scope isn't documented.** The docs say Quickshell live-reloads your code and that `QS_DISABLE_FILE_WATCHER` disables hot reloading. They don't say which files are watched. My claim that editing greeter files would reload your running shell was a guess. For the greeter in production, setting `QS_DISABLE_FILE_WATCHER=1` is a sensible hardening step, since nothing should change under it.
2. **I was too quick to dismiss `-c` for the greeter.** I said `-c myconfig` wouldn't resolve for the `greeter` user. That's true for the user's own config directory, but the docs say *every XDG standard config path* is searched. So installing the greeter system-wide at `/etc/xdg/quickshell/<name>/shell.qml` should let `quickshell -c <name>` work for any user, assuming `XDG_CONFIG_DIRS` is unset or includes `/etc/xdg` in the greeter's environment. I haven't verified that, so test it. It's a cleaner alternative to `-p` with a long path.
3. **A gotcha in the discovery rule.** If the base `~/.config/quickshell/` folder itself contains a `shell.qml`, subfolders are *not* considered at all. That doesn't affect your layout, but it's worth a README note for users who might drop a `shell.qml` there.

## New things worth knowing for the greeter

- **Avoid `import "root:/..."` for shared code.** The docs call root imports an old feature that breaks the LSP and singletons, with a replacement planned. Use relative imports (for example `import "../shared"`) so singletons like your theme keep working. The docs have an "explicit imports" section in the QML language page, which I haven't read, so check it for the exact syntax.
- **Instance pragmas only work in the root `shell.qml`.** Things like `//@ pragma Env`, `ShellId` and `StateDir` must be at the top of the entry file you launch. That means the greeter's own entry file can set its own state directory, which helps with the writable-state problem I mentioned.
- **`ShellId` is path-based by default.** Your installed greeter copy at a different path gets different data, state and cache directories than your in-session config, which is usually what you want.

Sources: [Introduction (Config Files)](https://quickshell.org/docs/v0.3.1/guide/introduction), [Advanced Options](https://quickshell.org/docs/v0.3.1/guide/advanced), [FAQ](https://quickshell.org/docs/v0.3.1/guide/faq)

# Setup

The greeter is the `qs.greeter` module in this folder plus the shared modules of the shell. `copy-greeter.sh` assembles them into `/usr/share/greeter`, because `qs.*` imports resolve next to the entry `shell.qml` and the `greeter` user can't read `~/.config`.

```
/usr/share/greeter/
  shell.qml        <- greeter/shell.qml
  hyprland.lua     <- greeter/hyprland.lua, the greeter's own compositor config
  greeter/         <- greeter/*.qml + qmldir
  bar/ colors/ components/ config/ fonts/ services/ settings/ types/ widgets/
  assets/wallpaper <- ~/.config/hypr/CURRENT_WALLPAPER
```

## Preview

```sh
./greeter/copy-greeter.sh --preview
```

Builds the same tree in `$XDG_RUNTIME_DIR/lanicos-greeter-preview` as your user and runs it over the current session. Logging in doesn't work there ("greetd is not running"). Press Escape in the password field to quit.

## Install

1. Install greetd: `sudo pacman -S greetd`
2. Run `./greeter/copy-greeter.sh` (it asks for sudo). It is idempotent, re-run it after changing the wallpaper, the matugen colors or any shared QML.
3. Switch display manager, effective at next boot (sddm is already disabled here, the first command is then a no-op):
   ```sh
   sudo systemctl disable sddm.service
   sudo systemctl enable greetd.service
   ```
4. Reboot.

Rollback: `sudo systemctl disable greetd.service && sudo systemctl enable sddm.service`, the original greetd config is kept as `/etc/greetd/config.toml.orig`.
If the greeter breaks, `Ctrl+Alt+F2` still gives a TTY login.

## What the script does

- Refuses to run without greetd installed, without `colors/Colors.qml`, or when `Hyprland --verify-config` rejects `hyprland.lua`.
- Builds the tree in a temporary sibling of `/usr/share/greeter`, owned by `root:root` with `755` folders and `644` files, then swaps it in. Nothing in it is writable by the `greeter` user, and an unrelated `/usr/share/greeter` is never replaced.
- Creates `/var/lib/lanicos-greeter` (`greeter:greeter`, `700`), where the last user and session are remembered, and the greeter's home if sysusers didn't.
- Writes `/etc/greetd/config.toml` (`root:root`, `644`) only when it differs, backing up the packaged one once:
  ```toml
  [terminal]
  vt = 1

  [default_session]
  command = "start-hyprland -- --config /usr/share/greeter/hyprland.lua"
  user = "greeter"
  ```
- Warns when Orbitron or JetBrainsMono Nerd Font aren't installed system-wide.

The greeter compositor has no keybinds, its config can't auto reload, and quickshell runs with `QS_DISABLE_FILE_WATCHER=1`. Hyprland exits as soon as quickshell does, so greetd either starts the session or restarts the greeter.

## Notes

- Fonts must be installed system-wide for the `greeter` user to see them. fontconfig scans `/usr/share/fonts` and `/usr/local/share/fonts` recursively, so any world-readable subfolder works. Orbitron came with the SDDM theme, so give it its own folder before removing that theme:
  ```sh
  sudo install -Dm644 "/usr/share/fonts/astronaut-sddm-theme/Orbitron Black.ttf" /usr/local/share/fonts/orbitron/OrbitronBlack.ttf
  sudo fc-cache -f
  ```
- Monitors, keyboard layouts and nvidia env in `hyprland.lua` are copies of `~/.config/hypr/hyprland.lua`, keep them in sync.
- `GreeterConfig.qml` holds the greeter knobs: default session, session folders, uid range, font size, state file. Every greeter window shows on every monitor `hyprland.lua` enables.
