# Clean-source import fix

The previous clean-source archive included all original art files, including
`assets/art/ui/cursor_pointer.svg`, but intentionally excluded the generated
`.godot/imported` cache. The old launcher started the project directly, so the
SVG preload was resolved before Godot had generated its `.ctex` import. That
caused both `phase0_run.gd` and `menu_screen.gd` to fail parsing.

This revision:

- runs Godot `--import` before launching the source project;
- changes the custom cursor from a parse-time preload to a safe runtime load;
- falls back to the system cursor if the custom resource is unavailable; and
- adds source-specific launch instructions.

No game art or gameplay data was missing from the previous archive.
