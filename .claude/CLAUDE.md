# Midea Portasplit Cover — Project Reference
## Siegenia HS GR 260 Sliding Door Rail

## Context
Modular 3D-printed cover for a Midea Portasplit air conditioner hose, inserted into a Siegenia HS GR 260 sliding door rail. The cover is assembled from multiple stackable pieces printed in **PETG**. Printer max build height: **256mm**.

## Rail Specifications
| Parameter | Value |
|---|---|
| Rail visible face width | 68mm |
| Rail depth (window → wall) | 50mm |
| Opening to cover | 50mm |
| Fixed wall pins on frame | Present, spaced regularly along height |

## Piece Architecture
The full cover consists of **4 piece types**:
1. **Repeatable middle piece** — `default-adapter.scad` (currently designed)
2. **Top finishing cap**
3. **Bottom finishing base** (potentially compatible with floor rail)
4. **Hose piece** (same as middle but with hole for Portasplit pipe)

## Repeatable Middle Piece — Design Overview

**Primary dimensions** are parametrically defined in `default-adapter.scad`:
- Body: `width` (X), `depth` (Y), `height` (Z)
- Door-side tenons: `tenon_w`, `tenon_d`, `tenon_spacing`
- Wall-side mortises: `mortise_w`, `mortise_d`, `mortise_spacing`, `mortise_end_h`
- Vertical assembly: `tongue_h`, `tongue_w_top`, `tongue_w_bot`
- Tolerance: `tolerance` (applied to all fits)

Refer to `default-adapter.scad` for current values — this document focuses on design intent and tolerance strategy.

### Functional Features

**Door-Side Tenons** (protrude in −Y direction toward door)
- Count: 2, positioned symmetrically
- Engage with door rail groove for horizontal alignment
- Run full piece height for strength

**Wall-Side Mortises** (cut into body on +Y wall side)
- Count: 2, positioned symmetrically
- Receive tenons from wall rail frame
- Depth limited to preserve structural integrity

**Wall-Side Exterior Ears** (around mortises)
- Structural support at top and bottom only (reduces material, preserves compliance)
- Each mortise flanked on both sides
- Improve grip and stability on wall rail

**Wall-Side Center Channel** (between mortises)
- Clearance for fixed wall pins that cannot move
- Centered symmetrically between mortises
- Minimum wall thickness (`mortise_wall_thickness`) preserved on each side

**Vertical Assembly — Dovetail System**
- Type: Trapezoidal tongue (top face) + groove (bottom face)
- Insertion direction: Horizontal (slide in from side, perpendicular to piece height)
- Cross-section plane: X-Z (tapers from wide top to narrow bottom)
- Count: 2 pairs (left and right, positioned outside door tenon zones)
- Positioned symmetrically to balance assembly
- Depth spans full piece depth (Y axis)

## Tolerance & Fitting Strategy

### Global Tolerance
**`tolerance = 0.15mm`** — Applied to all mating surfaces (PETG material)
- Dovetail grooves expanded by `tolerance` in all dimensions
- Door tenon/mortise fits: nominal with no tolerance (tight nominal fit)
- Wall mortise/tenon fits: nominal with no tolerance (tight nominal fit)

**Why 0.15mm?**
- 0.3mm was too loose in PETG — caused slop and assembly wobble
- 0.15mm provides press-fit security without distorting print geometry
- Accounts for PETG shrinkage and printer calibration variance
- Tested empirically in previous iterations

### Critical Interfaces

**Door Rail Engagement (Tenon ↔ Mortise)**
- Nominal fit (no tolerance added)
- Door tenons: `tenon_w` × `tenon_d`
- Wall mortises: `mortise_w` × `mortise_d`
- **Fit behavior:** Tenons slightly narrower than mortises for smooth insertion
- Check actual door rail dimensions during test print phase

**Vertical Stacking (Dovetail Tongue ↔ Groove)**
- Groove expanded by `tolerance` in width and height
- Tongue dimensions held to nominal
- **Fit behavior:** Tongue slides into groove with light friction
- Prevents rattle in assembled stack
- Can be printed with tolerance already baked in (groove is the oversized part)

### Print-Time Tolerance Validation

**Before full 150mm print:**
1. Print a **30–40mm test slice** (same model, same orientation, same printer settings)
2. Test assembly:
   - Can piece slide smoothly onto door rail?
   - Do dovetail tongues fit into grooves with appropriate resistance?
   - Can you build a 2–3 piece stack without binding or rocking?
3. If too tight: increase `tolerance` by 0.05mm and reprint
4. If too loose: decrease `tolerance` by 0.05mm and reprint

## OpenSCAD Parameters Reference

All dimensions are configurable at the top of `default-adapter.scad`. Key variables:

```openscad
// Piece body
width = 68;   depth = 50;   height = 150;

// Door-side features
tenon_w = 3.3;   tenon_d = 18;   tenon_spacing = 26;

// Wall-side features
mortise_w = 4.0;   mortise_d = 15;   mortise_end_h = 5;   mortise_spacing = 26;
mortise_wall_thickness = 3.5;   channel_w = 15;

// Vertical assembly (dovetail)
tongue_h = 8;   tongue_w_top = 12;   tongue_w_bot = 8;

// Assembly tolerance
tolerance = 0.15;
```

Derived values (calculated from base parameters):
- Tenon centers: `tenon_left_x`, `tenon_right_x`
- Tongue centers: `tongue_left_center_x`, `tongue_right_center_x`
- Channel bounds: `channel_x_min`, `channel_x_max`

## Lessons Learned / Critical Constraints

**Tolerance & Fit**
- Tolerance of 0.3mm was too loose for PETG — 0.15mm works much better
- Tight nominal fits on door/wall interfaces prevent wobble
- Dovetail groove tolerance must be applied symmetrically (groove expanded, tongue nominal)
- Always validate tolerance with test print first — temperature and printer calibration affect shrinkage

**Geometry & Modeling**
- `linear_extrude` with `rotate()` can produce wrong orientation — prefer `hull()` for trapezoidal prisms along Y axis
- Grooves placed at negative Z are invisible and non-functional — always cut from Z=0 upward into the body
- Removing too much material from wall side in one large cube cut corrupts geometry — use precise, independent coordinate bounds
- Always check for non-manifold warnings in OpenSCAD — `Simple: yes` confirms valid geometry

**Assembly Rules**
- Dovetail tongues must be positioned **outside** the door tenon zones in X — must not overlap
- Door tenons run the **full height** — no gap when pieces are stacked
- Wall channel must **not overlap mortises** — `mortise_wall_thickness` preserved on each side
- Bottom groove must be **open at Z=0** (cut into body from below), not floating below Z=0
- Exterior ears are added in `union()` **before** `difference()` cuts



## Print Settings & Validation

**Recommended Material & Orientation**
- **Material:** PETG (all tolerance values calibrated for PETG)
- **Infill:** Set in slicer (body model is solid)
- **Orientation:** Print vertically (Z axis = piece height)

**Tolerance Validation Workflow**
1. **Before full print:** Always print a 30–40mm test slice first
   - Same model, same orientation, same printer settings
   - Tests door rail engagement and dovetail fit
2. **Assembly check:**
   - Can piece slide smoothly onto door rail?
   - Do dovetail tongues fit with light resistance (no rattle, no binding)?
   - Stack 2–3 pieces and verify no wobble or gaps
3. **Adjust if needed:**
   - Too tight fit → increase `tolerance` by 0.05mm
   - Too loose fit → decrease `tolerance` by 0.05mm
   - Reprint test slice and validate before full print

**Why test first?**
- Printer calibration, ambient temperature, and PETG batch all affect shrinkage
- Dovetail fit is critical to assembly quality — small tolerance changes make big differences
- Better to discover fit issues on a 30mm print than a 150mm print

## Files
| File | Description |
|---|---|
| `default-adapter.scad` | OpenSCAD source, repeatable middle piece, all dimensions parametric |
