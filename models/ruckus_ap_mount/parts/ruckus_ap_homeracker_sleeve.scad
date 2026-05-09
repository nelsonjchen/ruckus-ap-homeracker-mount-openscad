// Ruckus AP HomeRacker sleeve scaffold
//
// CC BY-SA 4.0

/* [HomeRacker Sleeve] */
part_mode = 3; // [0:Sleeve only,1:Reference STL only,2:Sleeve with reference overlay,3:Prototype mount,4:Prototype with reference overlay]
sleeve_units = 9; // [3:1:12]
sleeve_island_count = 1; // [1:One centered island,2:Two end islands]
sleeve_holes_per_island = 2; // [1:1:8]
sleeve_rotation = 90; // [0,90]
sleeve_wall = 2; // [1.2:0.1:4]
sleeve_roof_thickness = 3; // [1.6:0.1:6]
sleeve_tolerance = 0.2; // [0:0.05:0.6]
lockpin_holes_enabled = true; // [false,true]

/* [Reference] */
reference_alpha = 0.25; // [0:0.05:1]
reference_scale = 1; // [0.1:0.01:5]
reference_translate = [0, 0, 0];
reference_rotate = [0, 0, 0];

/* [Ruckus Interface] */
ruckus_base_length = 93; // [60:0.1:130]
ruckus_base_width = 24; // [12:0.1:50]
ruckus_base_thickness = 4.4; // [1:0.1:8]
ruckus_bridge_width = 8; // [4:0.1:20]
ruckus_raised_bridge_length = 32.25; // [10:0.1:80]
ruckus_raised_bridge_width = 6; // [3:0.1:20]
ruckus_raised_bridge_height = 0; // [0:0.1:6]
ruckus_prong_spacing = 84.7; // [50:0.1:110]
ruckus_prong_shaft_diameter = 4; // [2:0.1:8]
ruckus_prong_shaft_height = 2.1; // [1:0.1:8]
ruckus_prong_cap_diameter = 6.7; // [3:0.1:12]
ruckus_prong_cap_height = 3.5; // [1:0.1:8]
ruckus_interface_rotation = 90; // [0,90]
ruckus_mount_z = -4.4; // [-20:0.1:30]
ruckus_gussets_enabled = true; // [false,true]
ruckus_gusset_thickness = 8; // [1:0.1:20]
ruckus_gusset_overhang_angle = 30; // [10:0.1:60]

/* [Debug] */
debug_colors = false; // [false,true]

/* [Hidden] */
$fn = 100;
EPSILON = 0.01;

// HomeRacker-compatible dimensions, mirrored locally so the model also
// compiles when opened directly in the OpenSCAD GUI.
BASE_UNIT = 15;
BASE_STRENGTH = 2;
TOLERANCE = 0.2;
LOCKPIN_HOLE_SIDE_LENGTH = 4;
HR_YELLOW = "#f7b600";
REFERENCE_BLUE = "#4c78a8";
PRONG_GREEN = "#00a651";

LOCKPIN_SIDE = LOCKPIN_HOLE_SIDE_LENGTH;
SLEEVE_INNER_SIDE = BASE_UNIT + sleeve_tolerance;
SLEEVE_OUTER_WIDTH = BASE_UNIT + 2 * sleeve_wall + sleeve_tolerance;
SLEEVE_SEGMENT_LENGTH = sleeve_holes_per_island * BASE_UNIT - sleeve_tolerance;
SLEEVE_ROOF_SEGMENT_LENGTH = SLEEVE_SEGMENT_LENGTH;
SLEEVE_ROOF_WIDTH = SLEEVE_OUTER_WIDTH;
SLEEVE_SEGMENT_OFFSET = sleeve_island_count == 1 ? 0 : (sleeve_units - sleeve_holes_per_island) * BASE_UNIT / 2;
SLEEVE_LOCKPIN_CENTER_Z = BASE_UNIT / 2 + sleeve_tolerance / 2;
SLEEVE_ISLAND_SIDES = sleeve_island_count == 1 ? [0] : [-1, 1];
RUCKUS_INTERFACE_BASE_Z = SLEEVE_INNER_SIDE + sleeve_roof_thickness + ruckus_mount_z;
RUCKUS_GUSSET_INNER_X = SLEEVE_OUTER_WIDTH / 2;
RUCKUS_GUSSET_OUTER_X = min(
    ruckus_base_length / 2,
    RUCKUS_GUSSET_INNER_X + RUCKUS_INTERFACE_BASE_Z / tan(ruckus_gusset_overhang_angle)
);
REFERENCE_CENTER = [62.5, 40, 0];

module centered_box(size) {
    cube(size, center = true);
}

module lockpin_hole() {
    centered_box([SLEEVE_OUTER_WIDTH + EPSILON, LOCKPIN_SIDE, LOCKPIN_SIDE]);
}

module lockpin_holes() {
    if (lockpin_holes_enabled) {
        for (segment_side = SLEEVE_ISLAND_SIDES) {
            for (hole = [0 : 1 : sleeve_holes_per_island - 1]) {
                local_y = (hole - (sleeve_holes_per_island - 1) / 2) * BASE_UNIT;

                translate([0, segment_side * SLEEVE_SEGMENT_OFFSET + local_y, SLEEVE_LOCKPIN_CENTER_Z])
                    lockpin_hole();
            }
        }
    }
}

module sleeve_segment(segment_side) {
    segment_y = segment_side * SLEEVE_SEGMENT_OFFSET;

    union() {
        for (wall_side = [-1, 1]) {
            translate([
                wall_side * (SLEEVE_INNER_SIDE / 2 + sleeve_wall / 2),
                segment_y,
                SLEEVE_INNER_SIDE / 2
            ])
                centered_box([sleeve_wall, SLEEVE_SEGMENT_LENGTH, SLEEVE_INNER_SIDE]);
        }

        translate([0, segment_y, SLEEVE_INNER_SIDE + sleeve_roof_thickness / 2])
            centered_box([SLEEVE_ROOF_WIDTH, SLEEVE_ROOF_SEGMENT_LENGTH, sleeve_roof_thickness]);
    }
}

module homeracker_sleeve() {
    color(debug_colors ? HR_YELLOW : HR_YELLOW)
    rotate([0, 0, sleeve_rotation])
    difference() {
        union() {
            for (segment_side = SLEEVE_ISLAND_SIDES)
                sleeve_segment(segment_side);
        }

        lockpin_holes();
    }
}

module homeracker_channel_clearance() {
    rotate([0, 0, sleeve_rotation])
    for (segment_side = SLEEVE_ISLAND_SIDES) {
        segment_y = segment_side * SLEEVE_SEGMENT_OFFSET;

        translate([0, segment_y, SLEEVE_INNER_SIDE / 2])
            centered_box([
                SLEEVE_INNER_SIDE + 2 * EPSILON,
                SLEEVE_SEGMENT_LENGTH + 2 * EPSILON,
                SLEEVE_INNER_SIDE + 2 * EPSILON
            ]);
    }
}

module reference_mount() {
    color(REFERENCE_BLUE, reference_alpha)
    translate(reference_translate)
    rotate(reference_rotate)
    scale(reference_scale)
    translate(-REFERENCE_CENTER)
        import("../../../reference/Ruckus_Wall_Mount_-_Miniature_Experimental.stl", convexity = 10);
}

module ruckus_prong(center_x) {
    color(PRONG_GREEN)
    translate([center_x, 0, ruckus_base_thickness])
    union() {
        cylinder(d = ruckus_prong_shaft_diameter, h = ruckus_prong_shaft_height);
        translate([0, 0, ruckus_prong_shaft_height])
            cylinder(d = ruckus_prong_cap_diameter, h = ruckus_prong_cap_height);
    }
}

module ruckus_base_outline_2d() {
    square([ruckus_base_length, ruckus_bridge_width], center = true);
}

module ruckus_drop_gusset_positive() {
    x_inner = RUCKUS_GUSSET_INNER_X;
    x_outer = RUCKUS_GUSSET_OUTER_X;
    y0 = -ruckus_gusset_thickness / 2;
    y1 = ruckus_gusset_thickness / 2;
    z_bottom = -RUCKUS_INTERFACE_BASE_Z;

    color(debug_colors ? REFERENCE_BLUE : "#f5f5f0")
    polyhedron(
        points = [
            [x_inner, y0, z_bottom],
            [x_inner, y0, 0],
            [x_outer, y0, 0],
            [x_inner, y1, z_bottom],
            [x_inner, y1, 0],
            [x_outer, y1, 0]
        ],
        faces = [
            [0, 1, 2],
            [3, 5, 4],
            [0, 3, 4, 1],
            [1, 4, 5, 2],
            [2, 5, 3, 0]
        ]
    );
}

module ruckus_drop_gusset(side) {
    if (side < 0) {
        mirror([1, 0, 0])
            ruckus_drop_gusset_positive();
    } else {
        ruckus_drop_gusset_positive();
    }
}

module ruckus_drop_gussets() {
    if (ruckus_gussets_enabled) {
        for (side = [-1, 1])
            ruckus_drop_gusset(side);
    }
}

module ruckus_reference_approximation() {
    union() {
        color(debug_colors ? REFERENCE_BLUE : "#f5f5f0")
            linear_extrude(ruckus_base_thickness)
                ruckus_base_outline_2d();

        ruckus_drop_gussets();

        if (ruckus_raised_bridge_height > 0) {
            color(debug_colors ? REFERENCE_BLUE : "#f5f5f0")
            translate([0, 0, ruckus_base_thickness + ruckus_raised_bridge_height / 2])
                centered_box([ruckus_raised_bridge_length, ruckus_raised_bridge_width, ruckus_raised_bridge_height]);
        }

        for (side = [-1, 1])
            ruckus_prong(side * ruckus_prong_spacing / 2);
    }
}

module prototype_mount() {
    union() {
        homeracker_sleeve();

        difference() {
            translate([0, 0, SLEEVE_INNER_SIDE + sleeve_roof_thickness + ruckus_mount_z])
                rotate([0, 0, ruckus_interface_rotation])
                    ruckus_reference_approximation();

            homeracker_channel_clearance();
        }
    }
}

module model() {
    assert(sleeve_units > 0, "Sleeve units must be positive.");
    assert(sleeve_island_count == 1 || sleeve_island_count == 2, "Sleeve island count must be 1 or 2.");
    assert(sleeve_holes_per_island > 0, "At least one sleeve hole per island is required.");
    assert(sleeve_island_count == 1 || sleeve_holes_per_island * 2 <= sleeve_units, "Sleeve end segments overlap; reduce holes per island or increase sleeve units.");
    assert(sleeve_rotation == 0 || sleeve_rotation == 90, "Sleeve rotation must be 0 or 90 degrees.");
    assert(part_mode >= 0 && part_mode <= 4, "Part mode must be 0, 1, 2, 3, or 4.");
    assert(ruckus_interface_rotation == 0 || ruckus_interface_rotation == 90, "Ruckus interface rotation must be 0 or 90 degrees.");
    assert(ruckus_prong_shaft_diameter > 0, "Ruckus prong shaft diameter must be positive.");
    assert(ruckus_prong_shaft_height > 0, "Ruckus prong shaft height must be positive.");
    assert(ruckus_prong_cap_diameter >= ruckus_prong_shaft_diameter, "Ruckus prong cap must be at least as wide as the shaft.");
    assert(ruckus_prong_cap_height > 0, "Ruckus prong cap height must be positive.");
    assert(RUCKUS_INTERFACE_BASE_Z >= 0, "Ruckus interface base must stay at or above global z=0.");
    assert(ruckus_gusset_thickness > 0, "Ruckus gusset thickness must be positive.");
    assert(ruckus_gusset_overhang_angle > 0 && ruckus_gusset_overhang_angle < 90, "Ruckus gusset overhang angle must be between 0 and 90 degrees.");
    assert(RUCKUS_GUSSET_OUTER_X > RUCKUS_GUSSET_INNER_X, "Ruckus gusset leaves no horizontal span.");

    if (part_mode == 0) {
        homeracker_sleeve();
    } else if (part_mode == 1) {
        reference_mount();
    } else if (part_mode == 2) {
        homeracker_sleeve();
        translate([0, 0, SLEEVE_INNER_SIDE + sleeve_roof_thickness])
            rotate([0, 0, ruckus_interface_rotation])
                reference_mount();
    } else if (part_mode == 3) {
        prototype_mount();
    } else if (part_mode == 4) {
        prototype_mount();
        translate([0, 0, SLEEVE_INNER_SIDE + sleeve_roof_thickness])
            rotate([0, 0, ruckus_interface_rotation])
                reference_mount();
    }
}

model();
