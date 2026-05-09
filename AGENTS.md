# Agent Notes

## Workflow

- Use `uv` for Python tooling. Prefer `uv run scadm ...` over global Python, pip, or globally installed `scadm`.
- Use the Makefile targets for routine work: `make sync`, `make install`, `make check`, `make render`, `make png`, and `make build`.
- Keep generated STL/PNG/3MF artifacts out of Git. They are ignored and can be regenerated.

## OpenSCAD Style

- Keep models parametric and compatible with OpenSCAD Customizer sections.
- Follow HomeRacker conventions: `BASE_UNIT = 15`, `BASE_STRENGTH = 2`, `TOLERANCE = 0.2`, 4 mm lock-pin holes, and `$fn = 100` for production renders.
- Prefer BOSL2 for chamfered solids and reusable geometry when it keeps the model clearer.
- Validate model changes with `make render`; use `make png` while iterating so the model can be visually inspected.

## Licensing

- This project's original model work is intended to be CC BY-SA 4.0.
- The HomeRacker dependency contains MIT-licensed code and CC BY-SA models; keep upstream notices intact when copying or adapting code.
