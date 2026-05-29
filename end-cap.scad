// ============================================================
// Portasplit End Cap — Top and Bottom finishing pieces
// Siegenia HS GR 260 sliding door rail
// ============================================================
//
// Set `part` to generate either cap:
//   "top"    — dovetail groove on bottom face (female), flat top face
//   "bottom" — dovetail tongue on top face (male), flat bottom face
//
// The terminal face (top for "bottom" cap, bottom for "top" cap)
// can have one or two through-holes running the full Y depth
// (door-tenon side through to wall side).  These replace the
// dovetail that would exist on a middle piece at that position.
//
// No hose slot — end caps do not pass the Portasplit hose.
// All other dimensions identical to default-adapter.scad.

// ── Which piece to generate ──────────────────────────────
part = "top";   // "top" | "bottom"

// ── Piece dimensions ──────────────────────────────────────
width  = 68;
depth  = 55;
height = 40;

// ── Door-side tenons ──────────────────────────────────────
tenon_w        = 3.3;
tenon_d        = 18;
tenon_h        = height;
tenon_corner_r = 0.8;
tenon_spacing  = 26;

// ── Wall-side mortises ────────────────────────────────────
mortise_w              = 3.5;
mortise_d              = 30;
ear_d                  = 0;
inner_tenon_d          = 5;
mortise_inner_d        = 21;
mortise_end_h          = 5;
mortise_spacing        = 26;

// ── Wall-side structural details ──────────────────────────
mortise_wall_thickness = 3.5;
channel_w              = 15;

// ── Dovetail tongue / groove ──────────────────────────────
tongue_h     = 8;
tongue_w_top = 12;
tongue_w_bot = 8;

// ── Tolerance (PETG) ─────────────────────────────────────
tolerance = 0.15;

// ── Through-hole on terminal face ────────────────────────
// Single centered hole running the full Y axis: from tenon tips
// (-tenon_d) through to the wall face (+depth).
// Placed on the face OPPOSITE the dovetail:
//   "bottom" cap → bottom face (Z = 0)
//   "top"    cap → top face    (Z = height)
through_hole  = true;   // enable / disable
hole_w        = 30;     // hole width in X [mm]
hole_h_top    = 22;     // hole height in Z for top cap    [mm]
hole_h_bottom = 15;     // hole height in Z for bottom cap [mm]

hole_h = (part == "top") ? hole_h_top : hole_h_bottom;

// ── Derived positions ─────────────────────────────────────
tenon_left_x  = width / 2 - tenon_spacing / 2;
tenon_right_x = width / 2 + tenon_spacing / 2;

tongue_left_center_x  = tenon_left_x / 2;
tongue_right_center_x = tenon_right_x + (width - tenon_right_x) / 2;

mortise_left_x  = width / 2 - mortise_spacing / 2;
mortise_right_x = width / 2 + mortise_spacing / 2;
channel_x_min   = mortise_left_x + mortise_w / 2 + mortise_wall_thickness;
channel_x_max   = mortise_right_x - mortise_w / 2 - mortise_wall_thickness;

inner_wall_d = depth - 5;

// Z start of through-hole — opposite face from the dovetail
// "bottom" cap: dovetail on top  → hole on bottom face (Z = 0)
// "top"    cap: dovetail on bottom → hole on top face (Z = height - hole_h)
hole_z0 = (part == "bottom") ? 0 : height - hole_h;

// ============================================================
// COMPONENT MODULES  (identical to default-adapter.scad)
// ============================================================

module door_tenon(x_pos) {
    r = tenon_corner_r;
    translate([x_pos - tenon_w / 2, -tenon_d, 0])
        hull() {
            translate([r,         r, 0]) cylinder(r=r, h=tenon_h, $fn=32);
            translate([tenon_w-r, r, 0]) cylinder(r=r, h=tenon_h, $fn=32);
            translate([0, tenon_d - 0.01, 0]) cube([tenon_w, 0.01, tenon_h]);
        }
}

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

module dovetail_tongue(tongue_center_x) {
    translate([tongue_center_x, 0, height])
        hull() {
            translate([-tongue_w_bot / 2, 0, 0])
                cube([tongue_w_bot, depth, 0.01]);
            translate([-tongue_w_top / 2, 0, tongue_h - 0.01])
                cube([tongue_w_top, depth, 0.01]);
        }
}

module dovetail_groove(tongue_center_x) {
    translate([tongue_center_x, -1, 0])
        hull() {
            translate([-(tongue_w_bot + tolerance) / 2, 0, 0])
                cube([tongue_w_bot + tolerance, depth + 2, 0.01]);
            translate([-(tongue_w_top + tolerance) / 2, 0, tongue_h + tolerance - 0.01])
                cube([tongue_w_top + tolerance, depth + 2, 0.01]);
        }
}

// Single centered through-hole running full Y depth.
// Rectangular cross-section: hole_w (X) × hole_h (Z).
module through_hole_cut() {
    y0 = -tenon_d - 1;         // start beyond tenon tips
    yl = depth + tenon_d + 2;  // full Y span including tenon protrusion
    translate([width / 2 - hole_w / 2, y0, hole_z0])
        cube([hole_w, yl, hole_h]);
}

// ============================================================
// MAIN
// ============================================================

module end_cap() {
    difference() {
        union() {
            cube([width, depth, height]);

            door_tenon(tenon_left_x);
            door_tenon(tenon_right_x);

            for (mortise_x = [mortise_left_x, mortise_right_x]) {
                exterior_ear(mortise_x, "left",  "top");
                exterior_ear(mortise_x, "left",  "bottom");
                exterior_ear(mortise_x, "right", "top");
                exterior_ear(mortise_x, "right", "bottom");
            }

            // "bottom" cap: tongue on top face connects to the piece above
            if (part == "bottom") {
                dovetail_tongue(tongue_left_center_x);
                dovetail_tongue(tongue_right_center_x);
            }
        }

        // Inner wall slots
        translate([mortise_left_x + mortise_w / 2, inner_wall_d, -1])
            cube([mortise_wall_thickness, depth - inner_wall_d + 1, height + 2]);
        translate([channel_x_max, inner_wall_d, -1])
            cube([mortise_wall_thickness, depth - inner_wall_d + 1, height + 2]);

        // Wall-side mortises
        for (mortise_x = [mortise_left_x, mortise_right_x]) {
            translate([mortise_x - mortise_w / 2, depth - mortise_inner_d, -1])
                cube([mortise_w, mortise_inner_d + 1, height + 2]);
        }

        // Wall-side center channel
        translate([channel_x_min, depth - inner_tenon_d, -1])
            cube([channel_x_max - channel_x_min, inner_tenon_d + 1, height + 2]);

        // "top" cap: groove on bottom face receives the tongue from the piece below
        if (part == "top") {
            dovetail_groove(tongue_left_center_x);
            dovetail_groove(tongue_right_center_x);
        }

        // Through-hole on terminal face (opposite side from dovetail)
        if (through_hole)
            through_hole_cut();
    }
}

end_cap();
