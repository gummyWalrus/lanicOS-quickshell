# lanicOS quickshell

My personal quickshell configuration to run on Hyprland

# Answer and edit processes

1. Let me handle the linting, testing and reload part, just code what is requested
2. Ignore warnings related to these Quickshell docs statement

```md
We are aware of the following issues:

* Qmlls does not work well when a file is not correctly structured. This means that completions and lints won’t work unless braces are closed correctly and such.
* The LSP cannot provide any documentation for Quickshell types.
* PanelWindow in particular cannot be resolved.

```

# Restrictions

Comments :
1. Comments are rare, only use them for globally explaining things (eg : at the top of a class)
2. Comments should not be used to explain a block of code that's small (0-20 lines) or code that can be understood easily by reading
2. Comments must not be more than 3 lines long, be succint