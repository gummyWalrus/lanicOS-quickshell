# lanicOS quickshell

My personal quickshell configuration to run on Hyprland

# Documentation

Always check your claims with /usr/lib/qt6/qml/Quickshell types and https://quickshell.org/docs/v0.3.1/* for documentation, your training data might be outdated


# Answer and edit processes

1. Let me handle the linting, testing, verifying and reload part, just code what is requested
2. When asking for permissions, provide an explanatory one-liner of your changes or cmd
3. Ignore warnings related to these Quickshell docs statement

```md
We are aware of the following issues:

* Qmlls does not work well when a file is not correctly structured. This means that completions and lints won’t work unless braces are closed correctly and such.
* The LSP cannot provide any documentation for Quickshell types.
* PanelWindow in particular cannot be resolved.

```

# Restrictions

Agents :
1. Do not use background agents as they consume too much tokens

Comments :
1. Comments are rare, only use them for globally explaining things (eg : at the top of a class)
2. Comments are not be used to explain a block of code that's small (0-20 lines) or code that can be understood easily by reading
2. Comments must not be more than 3 lines, be succint