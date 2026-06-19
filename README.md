# Midea Portasplit Cover for Siegenia HS GR 260 Sliding Door

A parametric OpenSCAD adapter designed to fit the Midea Portasplit hose into a Siegenia HS GR 260 sliding door rail. This repository includes a repeatable middle piece, optional hose cutout, and top/bottom end caps for a clean, stackable installation.

## Supported hardware

- Siegenia HS GR 260 sliding door rail
- Midea Portasplit hose

> This model is tuned for these components. If you use a different rail profile or hose, verify the fit before printing.

## Contents

- `default-adapter.scad` — repeatable middle piece with optional hose slot
- `end-cap.scad` — top and bottom finishing caps for the assembly
- `default-adapter.3mf`, `portasplit-siegenia-adapter.3mf` — 3MF project files
- `default-adapter-10cm.stl`, `default-adapter-15cm.stl`, `default-adapter-20cm.stl` — preview STL exports
- `end-cap-top.stl`, `end-cap-bottom.stl` — cap preview models
- `LICENSE` — GNU GPLv3 license

## What this project does

This design creates a sliding-door-friendly cover for the Midea Portasplit hose inside the Siegenia HS GR 260 door rail. It uses:

- door-side tenons to engage the sliding door channel
- wall-side mortises and a center channel for fixed pin clearance
- dovetail-style tongues and grooves for vertical stacking
- an optional hose cutout that lets the hose pass through the part without detaching the assembly

## Recommended print setup

- Material: PETG is recommended for durability and fit
- Orientation: print vertically with the long face in Z
- Supports: minimal, only if your slicer requires them for small overhangs
- Layer height: 0.2mm or finer for best fit detail
- Tolerance: default `tolerance = 0.15`; adjust by ±0.05mm if the assembly feels too tight or loose

## Quick start

1. Open `default-adapter.scad` in OpenSCAD.
2. Set `hose_hole = true` to enable the hose slot, or `false` for a solid adapter piece.
3. Customize dimensions if needed, but keep the rail-specific interface values unless you are changing the rail geometry.
4. Render and export the model as STL or 3MF.
5. Use `end-cap.scad` with `part = "bottom"` for the bottom cap and `part = "top"` for the top cap.

## Usage examples

- Enable the hose slot:

```scad
hose_hole = true;
```

- Generate the bottom cap:

```scad
part = "bottom";
```

- Generate the top cap:

```scad
part = "top";
```

## Customization options

Key parameters in `default-adapter.scad`:

- `width`, `depth`, `height` — main body size
- `tenon_w`, `tenon_d`, `tenon_spacing` — door rail tenon fit
- `mortise_w`, `mortise_d`, `mortise_spacing` — wall-side mortises
- `channel_w` — center channel width for pins or obstacles
- `tongue_h`, `tongue_w_top`, `tongue_w_bot` — vertical dovetail stack geometry
- `hose_w`, `hose_h`, `hose_z`, `hose_tolerance` — hose aperture size and clearance
- `tolerance` — print fit offset for PETG

## Recommended workflow

- Print a short calibration slice first (30–40mm height)
- Check fit on the door rail and stack alignment before printing full-length pieces
- If the hose slot is enabled, verify the hose fits through the cutout cleanly
- Assemble one bottom cap, one or more middle pieces, and one top cap for a finished installation

## Notes for makers

- This design is optimized for the Siegenia HS GR 260 sliding door rail and Midea Portasplit hose geometry. Use caution if adapting to other rails.
- OpenSCAD parameter editing is the preferred way to create new lengths or custom fits.
- The current tolerance values are tuned for PETG; different friendly materials may require a new calibration print.

## What to improve next

If you want to make this repo stronger for public use, consider adding:

- preview photos or render images in the repo
- a `CHANGELOG.md` for versioned updates
- a small `assembly-guide.pdf` or `HOWTO` with installation photos
- additional height variants and a “no hose” version as separate exports
- a more explicit copyright header in the license

## License

This project is licensed under GNU GPLv3. See `LICENSE` for details.
