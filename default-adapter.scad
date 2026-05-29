// ============================================================
// Midea Portasplit Cover - Repeatable middle piece
// Siegenia HS GR 260 sliding door rail
// ============================================================

// Piece dimensions
width       = 68;
depth       = 55;
height      = 100;

// Door-side tenons (protrude toward door in -Y direction)
tenon_w         = 3.3;
tenon_d         = 18;
tenon_h         = height;   // Z-height of door tenons (defaults to full piece height)
tenon_corner_r  = 0.8;      // Corner radius of door tenons (0 = sharp)
tenon_spacing   = 26;

// Wall-side mortises (cut into back face, +Y side)
mortise_w       = 3.5;
mortise_d       = 30;        // Overall Y extent of wall-side engagement zone
ear_d           = 0;         // Y-depth of exterior ear blocks (shorter = less reach from back face)
inner_tenon_d   = 38;        // Put it to 38mm when need to clear tenon from window
                             // Use 5 when nothing in the channel
mortise_inner_d = 21;        // Mortise slot depth — matches tenon length by default
mortise_end_h   = 5;         // Height of exterior ears at top and bottom
mortise_spacing = 26;

// Wall-side structural details
mortise_wall_thickness = 3.5;  // Minimum wall each side of center channel
channel_w               = 15;  // Center channel width

// Dovetail tongue/groove (vertical assembly via top/bottom faces)
tongue_h      = 8;
tongue_w_top  = 12;
tongue_w_bot  = 8;

// Tolerance for all fits (PETG)
tolerance = 0.15;

// Derived positions
tenon_left_x  = width / 2 - tenon_spacing / 2;
tenon_right_x = width / 2 + tenon_spacing / 2;

// Tongue centers positioned symmetrically outside tenon zones
tongue_left_center_x  = tenon_left_x / 2;
tongue_right_center_x = tenon_right_x + (width - tenon_right_x) / 2;

// Channel bounds: mortises + wall thickness on each side
mortise_left_x  = width / 2 - mortise_spacing / 2;
mortise_right_x = width / 2 + mortise_spacing / 2;
channel_x_min   = mortise_left_x + mortise_w / 2 + mortise_wall_thickness;
channel_x_max   = mortise_right_x - mortise_w / 2 - mortise_wall_thickness;

inner_wall_d = depth - 5; // Depth of inner walls between mortise slots and channel

// Portasplit hose slot (27mm × 60mm flat hose, Midea Portasplit)
// Through-hole in X (side face to side face); open at window face (Y=0) for non-detachable hose.
hose_hole      = false;          // Set true to cut hose slot in this block
hose_w         = 31;            // Hose thickness → slot depth from window face (Y direction)
hose_h         = 66;            // Hose face → slot height (Z direction)
hose_z         = height / 2;    // Z center of hose slot (default: piece center)
hose_tolerance = 0.1;           // Clearance per side
hose_corner_r  = 2.8;             // Fillet on back-wall corners inside the slot (window face stays sharp)
outer_fillet_r = 20;             // Fillet around hole perimeter at each side face (cable exits here)

// ============================================================
// COMPONENT MODULES
// ============================================================

// Door-side tenon: rounded at door-tip only, square at body base
module door_tenon(x_pos) {
    r = tenon_corner_r;
    translate([x_pos - tenon_w / 2, -tenon_d, 0])
        hull() {
            // Door-tip: two cylinders give a rounded end
            translate([r,         r, 0]) cylinder(r=r, h=tenon_h, $fn=32);
            translate([tenon_w-r, r, 0]) cylinder(r=r, h=tenon_h, $fn=32);
            // Body base: full-width flat slice — keeps this end square
            translate([0, tenon_d - 0.01, 0]) cube([tenon_w, 0.01, tenon_h]);
        }
}

// Wall-side exterior ear: small block at top or bottom, flanks each mortise
// side: "left" or "right" relative to mortise center
// z_pos: "top" or "bottom"
module exterior_ear(mortise_x, side, z_pos) {
    ear_x = (side == "left") 
        ? mortise_x - mortise_w / 2 - 5 
        : mortise_x + mortise_w / 2;
    ear_z = (z_pos == "top") 
        ? height - mortise_end_h 
        : 0;
    
    translate([ear_x, depth, ear_z])
        cube([5, ear_d, mortise_end_h]);
}

// Dovetail tongue on top face: trapezoidal cross-section in X-Z plane
// Narrow at base (tongue_w_bot), wide at tip (tongue_w_top) — ~14° half-angle with defaults
// Inserted by sliding piece horizontally (X direction); wide tip locks against groove opening
module dovetail_tongue(tongue_center_x) {
    translate([tongue_center_x, 0, height])
        hull() {
            translate([-tongue_w_bot / 2, 0, 0])
                cube([tongue_w_bot, depth, 0.01]);
            translate([-tongue_w_top / 2, 0, tongue_h - 0.01])
                cube([tongue_w_top, depth, 0.01]);
        }
}

// Portasplit hose slot: open at window face (Y=0), through-hole in X
// Back-wall (Y=sd) corners are rounded internally; window face (Y=0) stays sharp
module hose_slot() {
    sd = hose_w + hose_tolerance;
    sh = hose_h + 2 * hose_tolerance;
    r  = hose_corner_r;
    // Front cylinders at Y=-1 (outside body) → window face remains a sharp rectangle
    // Back cylinders at Y=sd → back-wall corners are rounded with radius r
    hull() {
        for (zoff = [r, sh - r])
            for (yoff = [-1, sd])
                translate([-1, yoff, hose_z - sh/2 + zoff])
                    rotate([0, 90, 0])
                        cylinder(r=r, h=width+2, $fn=32);
    }
}

// Outer perimeter fillet: rounded lip on each X face.
// Uses the arc centered at (r, zt+r) / (r, zb-r): xi = r(1-cosθ), ri = r(1-sinθ).
// This arc has a HORIZONTAL tangent at the face (xi=0, ri=r) — the surface starts flush
// with the face and curves smoothly inward, creating a visible rounded lip on the outside
// of the slot edge rather than a funnel hole going into the piece.
module hose_outer_fillet() {
    sd  = hose_w + hose_tolerance;
    sh  = hose_h + 2 * hose_tolerance;
    r   = outer_fillet_r;
    zb  = hose_z - sh / 2;
    zt  = hose_z + sh / 2;
    N   = 16;
    eps = 0.01;

    // Left face (x=0)
    hull() {
        for (i = [0:N-1])
            for (yc = [0, sd])
                for (zc = [zb, zt])
                    translate([r * (1 - cos(90 * i / N)), yc, zc])
                        rotate([0, 90, 0])
                            cylinder(r = r * (1 - sin(90 * i / N)), h = eps, $fn = 16);
        translate([r, 0, zb]) cylinder([eps, sd, sh]);
    }

    // Right face (x=width)
    hull() {
        for (i = [0:N-1])
            for (yc = [0, sd])
                for (zc = [zb, zt])
                    translate([width - r * (1 - cos(90 * i / N)), yc, zc])
                        rotate([0, 90, 0])
                            cylinder(r = r * (1 - sin(90 * i / N)), h = eps, $fn = 16);
        translate([width - r, 0, zb]) cylinder([eps, sd, sh]);
    }
}

// Dovetail groove on bottom face: complement of tongue, with tolerance applied
// Opening (Z=0) is narrow, depth (Z=tongue_h) is wide — tongue tip can't exit through opening
module dovetail_groove(tongue_center_x) {
    translate([tongue_center_x, -1, 0])
        hull() {
            translate([-(tongue_w_bot + tolerance) / 2, 0, 0])
                cube([tongue_w_bot + tolerance, depth + 2, 0.01]);
            translate([-(tongue_w_top + tolerance) / 2, 0, tongue_h + tolerance - 0.01])
                cube([tongue_w_top + tolerance, depth + 2, 0.01]);
        }
}


// ============================================================
// MAIN GEOMETRY
// ============================================================

module portasplit_cover() {
    difference() {
        // Additive features
        union() {
            // Main body
            cube([width, depth, height]);

            // Door-side tenons
            door_tenon(tenon_left_x);
            door_tenon(tenon_right_x);

            // Wall-side exterior ears (structural support around mortises)
            for (mortise_x = [mortise_left_x, mortise_right_x]) {
                exterior_ear(mortise_x, "left", "top");
                exterior_ear(mortise_x, "left", "bottom");
                exterior_ear(mortise_x, "right", "top");
                exterior_ear(mortise_x, "right", "bottom");
            }

            // Dovetail tongues on top face (for vertical stacking)
            dovetail_tongue(tongue_left_center_x);
            dovetail_tongue(tongue_right_center_x);
        }

        // Subtractive features (cuts)

        // Inner walls: cut from wall side inward, leaving inner_wall_d depth from door side
        translate([mortise_left_x + mortise_w / 2, inner_wall_d, -1])
            cube([mortise_wall_thickness, depth - inner_wall_d + 1, height + 2]);
        translate([channel_x_max, inner_wall_d, -1])
            cube([mortise_wall_thickness, depth - inner_wall_d + 1, height + 2]);

        // Wall-side mortises: receive tenons from wall rail groove
        for (mortise_x = [mortise_left_x, mortise_right_x]) {
            translate([mortise_x - mortise_w / 2, depth - mortise_inner_d, -1])
                cube([mortise_w, mortise_inner_d + 1, height + 2]);
        }

        // Wall-side center channel: clearance for fixed wall pins
        // Centered between mortises, minimum wall thickness on each side
        translate([channel_x_min, depth - inner_tenon_d, -1])
            cube([channel_x_max - channel_x_min, inner_tenon_d + 1, height + 2]);

        // Dovetail grooves on bottom face: receive tongues from piece below
        dovetail_groove(tongue_left_center_x);
        dovetail_groove(tongue_right_center_x);

        // Portasplit hose slot (only when enabled)
        if (hose_hole) {
            hose_slot();
            hose_outer_fillet();
            // Remove door tenons in the hose slot Z range
            translate([-tenon_d - 1, -tenon_d - 1, hose_z - (hose_h + 2*hose_tolerance)/2])
                cube([width + 2*tenon_d + 2, tenon_d + 1, hose_h + 2*hose_tolerance]);
        }
    }
}

// Render the part
portasplit_cover();

