pcb_thickness = 1.6;

module Pcb() {
  include <pico-plc.scad>;
}

module Case() {
  board_size = [154.5, 95] + [1, 1];

  height = 8;
  tray_depth = 4;

  screw_centres = [146.5, 79];
  screw_positions = [
    [screw_centres[0] / 2, screw_centres[1] / 2],
    [-screw_centres[0] / 2, screw_centres[1] / 2],
    [screw_centres[0] / 2, -screw_centres[1] / 2],
    [-screw_centres[0] / 2, -screw_centres[1] / 2],
  ];
  pcb_support_positions = [
    [-12, 0],
    [-50, 0],
    [-12, 30],
    [-50, 30],
    [35, 15],
  ];

  difference() {
    union() {
      difference() {
        translate([0, 0, -height]) {
          linear_extrude(height) {
            square(board_size + [5, 5], center = true);
          }
        }

        translate([0, 0, 0.01 - tray_depth]) {
          linear_extrude(tray_depth) {
            square(board_size, center = true);
          }
        }
      }

      translate([0, 0, -tray_depth]) {
        for(p = screw_positions) {
          translate(p) {
            cylinder(d = 10, h = abs(tray_depth) - pcb_thickness);
          }
        }
      }

      translate([0, 0, -tray_depth]) {
        for(p = pcb_support_positions) {
          translate(p) {
            cylinder(d = 10, h = abs(tray_depth) - pcb_thickness);
          }
        }
      }
    }

    translate([0, 0, -height - 1]) {
      for(p = screw_positions) {
        translate(p) {
          cylinder(d = 4, h = height + 2);
        }
      }
    }
  }
}

Case();
translate([0, 0, -pcb_thickness / 2]) {
  Pcb();
}
