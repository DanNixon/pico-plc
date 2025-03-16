include <./YAPPgenerator_v3.scad>

//---------------------------------------------------------
// This design is parameterized based on the size of a PCB.
//---------------------------------------------------------
// Note: length/lengte refers to X axis, 
//       width/breedte refers to Y axis,
//       height/hoogte refers to Z axis

/*
      padding-back|<------pcb length --->|<padding-front
                            RIGHT
        0    X-axis ---> 
        +----------------------------------------+   ---
        |                                        |    ^
        |                                        |   padding-right 
      Y |                                        |    v
      | |    -5,y +----------------------+       |   ---              
 B    a |         | 0,y              x,y |       |     ^              F
 A    x |         |                      |       |     |              R
 C    i |         |                      |       |     | pcb width    O
 K    s |         |                      |       |     |              N
        |         | 0,0              x,0 |       |     v              T
      ^ |    -5,0 +----------------------+       |   ---
      | |                                        |    padding-left
      0 +----------------------------------------+   ---
        0    X-as --->
                          LEFT
*/


//-- which part(s) do you want to print?
printBaseShell        = true;
printLidShell         = true;
printSwitchExtenders  = true;
printDisplayClips     = true;

//===================================================================
// *** PCBs ***
// Printed Circuit Boards
//-------------------------------------------------------------------
//  Default origin =  yappCoordPCB : yappCoordBoxInside[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = name
//    p(1) = length
//    p(2) = width
//    p(3) = posx
//    p(4) = posy
//    p(5) = Thickness
//    p(6) = standoff_Height = Height to bottom of PCB from the inside of the base
//             negative measures from inside of the lid to the top of the PCB
//    p(7) = standoff_Diameter
//    p(8) = standoff_PinDiameter
//   Optional:
//    p(9) = standoff_HoleSlack (default to 0.4)

//The following can be used to get PCB values elsewhere in the script - not in pcb definition. 
//If "PCB Name" is omitted then "Main" is used
//  pcbLength           --> pcbLength("PCB Name")
//  pcbWidth            --> pcbWidth("PCB Name")
//  pcbThickness        --> pcbThickness("PCB Name") 
//  standoffHeight      --> standoffHeight("PCB Name") 
//  standoffDiameter    --> standoffDiameter("PCB Name") 
//  standoffPinDiameter --> standoffPinDiameter("PCB Name") 
//  standoffHoleSlack   --> standoffHoleSlack("PCB Name") 

pcb = 
[
  ["Pico-PLC", 95.5, 154.5, 0, 0, 1.6, 5, 7, 2.75]
];

//-------------------------------------------------------------------                            
//-- padding between pcb and inside wall
paddingFront        = 2;
paddingBack         = 2;
paddingRight        = 2;
paddingLeft         = 2;

//-- Edit these parameters for your own box dimensions
wallThickness       = 2;
basePlaneThickness  = 2;
lidPlaneThickness   = 1.5;

//-- Total height of box = lidPlaneThickness 
//                       + lidWallHeight 
//--                     + baseWallHeight 
//                       + basePlaneThickness
//-- space between pcb and lidPlane :=
//--      (bottonWallHeight+lidWallHeight) - (standoffHeight+pcbThickness)
baseWallHeight      = 14;
lidWallHeight       = 10;

//-- ridge where base and lid off box can overlap
//-- Make sure this isn't less than lidWallHeight
ridgeHeight         = 5.0;
ridgeSlack          = 0.2;
roundRadius         = 3.0;

// Box Types are 0-4 with 0 as the default
// 0 = All edges rounded with radius (roundRadius) above
// 1 = All edges sqrtuare
// 2 = All edges chamfered by (roundRadius) above 
// 3 = Square top and bottom edges (the ones that touch the build plate) and rounded vertical edges
// 4 = Square top and bottom edges (the ones that touch the build plate) and chamfered vertical edges
// 5 = Chanfered top and bottom edges (the ones that touch the build plate) and rounded vertical edges
boxType             = 3;

// Set the layer height of your printer
printerLayerHeight  = 0.2;

//---------------------------
//--     C O N T R O L     --
//---------------------------
// -- Render --
renderQuality             = 8;          //-> from 1 to 32, Default = 8

// --Preview --
previewQuality            = 5;          //-> from 1 to 32, Default = 5
showSideBySide            = true;       //-> Default = true
onLidGap                  = 0;  // tip don't override to animate the lid opening
colorLid                  = "YellowGreen";   
alphaLid                  = 1;
colorBase                 = "BurlyWood";
alphaBase                 = 1;
hideLidWalls              = false;      //-> Remove the walls from the lid : only if preview and showSideBySide=true 
hideBaseWalls             = false;      //-> Remove the walls from the base : only if preview and showSideBySide=true  
showOrientation           = true;       //-> Show the Front/Back/Left/Right labels : only in preview
showPCB                   = false;      //-> Show the PCB in red : only in preview
showSwitches              = false;      //-> Show the switches (for pushbuttons) : only in preview 
showButtonsDepressed      = false;      //-> Should the buttons in the Lid On view be in the pressed position
showOriginCoordBox        = false;      //-> Shows red bars representing the origin for yappCoordBox : only in preview 
showOriginCoordBoxInside  = false;      //-> Shows blue bars representing the origin for yappCoordBoxInside : only in preview 
showOriginCoordPCB        = false;      //-> Shows blue bars representing the origin for yappCoordBoxInside : only in preview 
showMarkersPCB            = false;      //-> Shows black bars corners of the PCB : only in preview 
showMarkersCenter         = false;      //-> Shows magenta bars along the centers of all faces  
inspectX                  = 0;          //-> 0=none (>0 from Back)
inspectY                  = 0;          //-> 0=none (>0 from Right)
inspectZ                  = 0;          //-> 0=none (>0 from Bottom)
inspectXfromBack          = true;       //-> View from the inspection cut foreward
inspectYfromLeft          = true;       //-> View from the inspection cut to the right
inspectZfromBottom        = true;       //-> View from the inspection cut up
//---------------------------
//--     C O N T R O L     --
//---------------------------

//-------------------------------------------------------------------
//-------------------------------------------------------------------
// Start of Debugging config (used if not overridden in template)
// ------------------------------------------------------------------
// ------------------------------------------------------------------

//==================================================================
//  *** Shapes ***
//------------------------------------------------------------------
//  There are a view pre defines shapes and masks
//  shapes:
//      shapeIsoTriangle, shapeHexagon, shape6ptStar
//
//  masks:
//      maskHoneycomb, maskHexCircles, maskBars, maskOffsetBars
//
//------------------------------------------------------------------
// Shapes should be defined to fit into a 1x1 box (+/-0.5 in X and Y) - they will 
// be scaled as needed.
// defined as a vector of [x,y] vertices pairs.(min 3 vertices)
// for example a triangle could be [yappPolygonDef,[[-0.5,-0.5],[0,0.5],[0.5,-0.5]]];
// To see how to add your own shapes and mask see the YAPPgenerator program
//------------------------------------------------------------------

//===================================================================
// *** PCB Supports ***
// Pin and Socket standoffs 
//-------------------------------------------------------------------
//  Default origin =  yappCoordPCB : pcb[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = posx
//    p(1) = posy
//   Optional:
//    p(2) = Height to bottom of PCB from inside of base: Default = standoffHeight
//             negative measures from inside of the lid to the top of the PCB
//    p(3) = PCB Gap : Default = -1 : Default for yappCoordPCB=pcbThickness, yappCoordBox=0
//    p(4) = standoffDiameter    Default = standoffDiameter;
//    p(5) = standoffPinDiameter Default = standoffPinDiameter;
//    p(6) = standoffHoleSlack   Default = standoffHoleSlack;
//    p(7) = filletRadius (0 = auto size)
//    p(8) = Pin Length : Default = 0 -> PCB Gap + standoff_PinDiameter
//             Indicated length of pin without the half sphere tip. 
//             Example : pcbThickness() only leaves the half sphere tip above the PCB
//    n(a) = { <yappBoth> | yappLidOnly | yappBaseOnly }
//    n(b) = { <yappPin>, yappHole, yappTopPin } 
//             yappPin = Pin on Base and Hole on Lid 
//             yappHole = Hole on Both
//             yappTopPin = Hole on Base and Pin on Lid
//    n(c) = { yappAllCorners, yappFrontLeft | <yappBackLeft> | yappFrontRight | yappBackRight }
//    n(d) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside }
//    n(e) = { yappNoFillet } : Removes the internal and external fillets and the Rounded tip on the pins
//    n(f) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//    n(g) = yappSelfThreading : make the hole a self threading hole 
//             This ignores the holeSlack and would only be usefull 
//             if the opposing stand if deleted see sample in Demo_Connectors
//-------------------------------------------------------------------
pcbStands = 
[
  [8, 4, yappBackLeft, [yappPCBName, "Pico-PLC"]],
  [8, 4, yappBackRight, [yappPCBName, "Pico-PLC"]],
  [8.5, 4, yappFrontLeft, [yappPCBName, "Pico-PLC"]],
  [8.5, 4, yappFrontRight, [yappPCBName, "Pico-PLC"]],
];

//===================================================================
//  *** Connectors ***
//  Standoffs with hole through base and socket in lid for screw type connections.
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//  
//  Parameters:
//   Required:
//    p(0) = posx
//    p(1) = posy
//    p(2) = pcbStandHeight
//    p(3) = screwDiameter
//    p(4) = screwHeadDiameter (don't forget to add extra for the fillet)
//    p(5) = insertDiameter
//    p(6) = outsideDiameter
//   Optional:
//    p(7) = PCB Gap : Default = -1 : Default for yappCoordPCB=pcbThickness, yappCoordBox=0
//    p(8) = filletRadius : Default = 0/Auto(0 = auto size)
//    n(a) = { <yappAllCorners>, yappFrontLeft | yappFrontRight | yappBackLeft | yappBackRight }
//    n(b) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside }
//    n(c) = { yappNoFillet }
//    n(d) = { yappCountersink }
//    n(e) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//    n(f) = { yappThroughLid = changes the screwhole to the lid and the socket to the base}
//    n(g) = {yappSelfThreading} : Make the insert self threading specify the Screw Diameter in the insertDiameter
//-------------------------------------------------------------------
connectors =
[
];

//===================================================================
//  *** Cutouts ***
//    There are 6 cutouts one for each surface:
//      cutoutsBase (Bottom), cutoutsLid (Top), cutoutsFront, cutoutsBack, cutoutsLeft, cutoutsRight
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//                        Required                Not Used        Note
//----------------------+-----------------------+---------------+------------------------------------
//  yappRectangle       | width, length         | radius        |
//  yappCircle          | radius                | width, length |
//  yappRoundedRect     | width, length, radius |               |     
//  yappCircleWithFlats | width, radius         | length        | length=distance between flats
//  yappCircleWithKey   | width, length, radius |               | width = key width length=key depth
//                      |                       |               |  (negative indicates outside of circle)
//  yappPolygon         | width, length         | radius        | yappPolygonDef object must be
//                      |                       |               | provided
//  yappRing            | width, length, radius |               | radius = outer radius, 
//                      |                       |               | length = inner radius
//                      |                       |               | width = connection between rings
//                      |                       |               |   0 = No connectors
//                      |                       |               |   positive = 2 connectors
//                      |                       |               |   negative = 4 connectors
//  yappSphere          | width, radius         |               | Width = Sphere center distance from
//                      |                       |               |   center of depth.  negative = below
//                      |                       |               | radius = sphere radius
//----------------------+-----------------------+---------------+------------------------------------
//
//  Parameters:
//   Required:
//    p(0) = from Back
//    p(1) = from Left
//    p(2) = width
//    p(3) = length
//    p(4) = radius
//    p(5) = shape : { yappRectangle | yappCircle | yappPolygon | yappRoundedRect 
//                     | yappCircleWithFlats | yappCircleWithKey | yappSphere }
//  Optional:
//    p(6) = depth : Default = 0/Auto : 0 = Auto (plane thickness)
//    p(7) = angle : Default = 0
//    n(a) = { yappPolygonDef } : Required if shape = yappPolygon specified -
//    n(b) = { yappMaskDef } : If a yappMaskDef object is added it will be used as a mask 
//                             for the cutout.
//    n(c) = { [yappMaskDef, hOffset, vOffset, rotation] } : If a list for a mask is added 
//                              it will be used as a mask for the cutout. With the Rotation 
//                              and offsets applied. This can be used to fine tune the mask
//                              placement within the opening.
//    n(d) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside }
//    n(e) = { <yappOrigin>, yappCenter }
//    n(f) = { <yappGlobalOrigin>, yappAltOrigin } // Only affects Top(lid), Back and Right Faces
//    n(g) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//    n(h) = { yappFromInside } Make the cut from the inside towards the outside
//-------------------------------------------------------------------
cutoutsBase =
[
];

cutoutsLid =
[
  [42.645, 7.085, 10, 5, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],

  [42.685, 40.74 - 10, 12, 12, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [42.685, 40.74, 10, 5, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [42.685, 50.265, 10, 5, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [42.685, 50.265 + 10, 12, 12, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],

  [8.99, 14.07, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 24.865, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 35.66, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 46.455, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 57.23, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 68.045, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 78.84, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [8.99, 89.635, 5, 10, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],

  [87.162, 17.165, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 33.675, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 50.185, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 66.695, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 83.205, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 99.715, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 116.225, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [87.162, 132.735, 5, 15, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],

  [6.45, 113.13, 12, 18, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
  [6.45, 134.72, 12, 18, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],

  [45.185, 89, 12, 14, 2, yappRoundedRect, yappDefault, 0, yappCenter, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
];

cutoutsFront =
[
  [8.9, 2, 132, 6, 0, yappRectangle, yappDefault, 0, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
];

cutoutsBack =
[
  [9, 2, 85.725, 6, 0, yappRectangle, yappDefault, 0, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
];

cutoutsLeft =
[
  [37.56, 2, 10.16, 6, 0, yappRectangle, yappDefault, 0, yappCoordPCB, [yappPCBName, "Pico-PLC"]],
];

cutoutsRight =
[
];

//===================================================================
//  *** Snap Joins ***
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = posx | posy
//    p(1) = width
//    p(2) = { yappLeft | yappRight | yappFront | yappBack } : one or more
//   Optional:
//    n(a) = { <yappOrigin>, yappCenter }
//    n(b) = { yappSymmetric }
//    n(c) = { yappRectangle } == Make a diamond shape snap
//-------------------------------------------------------------------
snapJoins =
[
  [shellLength / 4, 5, yappLeft, yappRight, yappSymmetric],
  [5, 5, yappFront, yappBack, yappSymmetric],
];

//===================================================================
//  *** Box Mounts ***
//  Mounting tabs on the outside of the box
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = pos : position along the wall : [pos,offset] : vector for position and offset X.
//                    Position is to center of mounting screw in leftmost position in slot
//    p(1) = screwDiameter
//    p(2) = width of opening in addition to screw diameter 
//                    (0=Circular hole screwWidth = hole twice as wide as it is tall)
//    p(3) = height
//    n(a) = { yappLeft | yappRight | yappFront | yappBack } : one or more
//   Optional:
//    p(4) = filletRadius : Default = 0/Auto(0 = auto size)
//    n(b) = { yappNoFillet }
//    n(c) = { <yappBase>, yappLid }
//    n(d) = { yappCenter } : shifts Position to be in the center of the opening instead of 
//                            the left of the opening
//    n(e) = { <yappGlobalOrigin>, yappAltOrigin } : Only affects Back and Right Faces
//-------------------------------------------------------------------
boxMounts =
[
  [shellLength / 2, 3.5, 8, 4, yappLeft, yappCenter],
  [shellLength / 2, 3.5, 8, 4, yappRight, yappCenter],

  [shellWidth / 4, 3.5, 8, 4, yappBack, yappCenter],
  [3 * shellWidth / 4, 3.5, 8, 4, yappBack, yappCenter],

  [shellWidth / 4, 3.5, 8, 4, yappFront, yappCenter],
  [3 * shellWidth / 4, 3.5, 8, 4, yappFront, yappCenter],
];

//===================================================================
//  *** Light Tubes ***
//-------------------------------------------------------------------
//  Default origin = yappCoordPCB: PCB[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = posx
//    p(1) = posy
//    p(2) = tubeLength
//    p(3) = tubeWidth
//    p(4) = tubeWall
//    p(5) = gapAbovePcb
//    p(6) = { yappCircle | yappRectangle } : tubeType    
//   Optional:
//    p(7) = lensThickness (how much to leave on the top of the lid for the 
//           light to shine through 0 for open hole : Default = 0/Open
//    p(8) = Height to top of PCB : Default = standoffHeight+pcbThickness
//    p(9) = filletRadius : Default = 0/Auto 
//    n(a) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside } 
//    n(b) = { <yappGlobalOrigin>, yappAltOrigin }
//    n(c) = { yappNoFillet }
//    n(d) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//-------------------------------------------------------------------
lightTubes =
[
];

//===================================================================
//  *** Push Buttons ***
//-------------------------------------------------------------------
//  Default origin = yappCoordPCB: PCB[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = posx
//    p(1) = posy
//    p(2) = capLength 
//    p(3) = capWidth 
//    p(4) = capRadius 
//    p(5) = capAboveLid
//    p(6) = switchHeight
//    p(7) = switchTravel
//    p(8) = poleDiameter
//   Optional:
//    p(9) = Height to top of PCB : Default = standoffHeight + pcbThickness
//    p(10) = { yappRectangle | yappCircle | yappPolygon | yappRoundedRect 
//                    | yappCircleWithFlats | yappCircleWithKey } : Shape, Default = yappRectangle
//    p(11) = angle : Default = 0
//    p(12) = filletRadius          : Default = 0/Auto 
//    p(13) = buttonWall            : Default = 2.0;
//    p(14) = buttonPlateThickness  : Default= 2.5;
//    p(15) = buttonSlack           : Default= 0.25;
//    n(a) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside } 
//    n(b) = { <yappGlobalOrigin>,  yappAltOrigin }
//    n(c) = { yappNoFillet }
//    n(d) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//-------------------------------------------------------------------
pushButtons = 
[
];
             
//===================================================================
//  *** Labels ***
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//  Parameters:
//   p(0) = posx
//   p(1) = posy/z
//   p(2) = rotation degrees CCW
//   p(3) = depth : positive values go into case (Remove) negative values are raised (Add)
//   p(4) = { yappLeft, yappRight, yappFront, yappBack, yappLid, yappBase } : plane
//   p(5) = font
//   p(6) = size
//   p(7) = "label text"
//  Optional:
//   p(8) = Expand : Default = 0 : mm to expand text by (making it bolder) 
//   p(9) = Direction : { <yappTextLeftToRight>, yappTextRightToLeft, yappTextTopToBottom, yappTextBottomToTop }
//   p(10) = Horizontal alignment : { <yappTextHAlignLeft>, yappTextHAlignCenter, yappTextHAlignRight }
//   p(11) = Vertical alignment : {  yappTextVAlignTop, yappTextVAlignCenter, yappTextVAlignBaseLine, <yappTextVAlignBottom> } 
//   p(12) = Character Spacing multiplier (1.0 = normal)
//-------------------------------------------------------------------
labelsPlane =
[
];

//===================================================================
//  *** Ridge Extension ***
//    Extension from the lid into the case for adding split opening at various heights
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = pos
//    p(1) = width
//    p(2) = height : Where to relocate the seam : yappCoordPCB = Above (positive) the PCB
//                                                yappCoordBox = Above (positive) the bottom of the shell (outside)
//   Optional:
//    n(a) = { <yappOrigin>, yappCenter } 
//    n(b) = { <yappCoordPCB> | yappCoordBox | yappCoordBoxInside }
//    n(c) = { yappAltOrigin, <yappGlobalOrigin> } // Only affects Top(lid), Back and Right Faces
//    n(d) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//
// Note: Snaps should not be placed on ridge extensions as they remove the ridge to place them.
//-------------------------------------------------------------------
ridgeExtLeft =
[
];

ridgeExtRight =
[
];

ridgeExtFront =
[
];

ridgeExtBack =
[
];

//===================================================================
//  *** Display Mounts ***
//    add a cutout to the lid with mounting posts for a display
//-------------------------------------------------------------------
//  Default origin = yappCoordBox: box[0,0,0]
//
//  Parameters:
//   Required:
//    p(0) = posx
//    p(1) = posy
//    p[2] : displayWidth = overall Width of the display module
//    p[3] : displayHeight = overall Height of the display module
//    p[4] : pinInsetH = Horizontal inset of the mounting hole
//    p[5] : pinInsetV = Vertical inset of the mounting hole
//    p[6] : pinDiameter,
//    p[7] : postOverhang  = Extra distance towards outside of pins to move the post for the display to sit on - 0 = centered : pin Diameter will move the post to align to the outside of the pin (moves it half the distance specified for compatability : -pinDiameter will move it in.
//    p[8] : walltoPCBGap = Distance from the display PCB to the surface of the screen
//    p[9] : pcbThickness  = Thickness of the display module PCB
//    p[10] : windowWidth = opening width for the screen
//    p[11] : windowHeight = Opening height for the screen
//    p[12] : windowOffsetH = Horizontal offset from the center for the opening
//    p[13] : windowOffsetV = Vertical offset from the center for the opening
//    p[14] : bevel = Apply a 45degree bevel to the opening
// Optionl:
//    p[15] : rotation
//    p[16] : snapDiameter : default = pinDiameter*2
//    p[17] : lidThickness : default = lidPlaneThickness
//    n(a) = { <yappOrigin>, yappCenter } 
//    n(b) = { <yappCoordBox> | yappCoordPCB | yappCoordBoxInside }
//    n(c) = { <yappGlobalOrigin>, yappAltOrigin } // Only affects Top(lid), Back and Right Faces
//    n(d) = [yappPCBName, "XXX"] : Specify a PCB. Defaults to [yappPCBName, "Main"]
//    n(e) = {yappSelfThreading} : Replace the pins with self threading holes
//-------------------------------------------------------------------
displayMounts =
[
];

//========= HOOK functions ============================
  
// Hook functions allow you to add 3d objects to the case.
// Lid/Base = Shell part to attach the object to.
// Inside/Outside = Join the object from the midpoint of the shell to the inside/outside.
// Pre = Attach the object Pre before doing Cutouts/Stands/Connectors. 


//===========================================================
// origin = box(0,0,0)
module hookLidInside()
{
  //if (printMessages) echo("hookLidInside() ..");
  
} // hookLidInside()
  

//===========================================================
// origin = box(0,0,shellHeight)
module hookLidOutside()
{
  //if (printMessages) echo("hookLidOutside() ..");
  
} // hookLidOutside()

//===========================================================
//===========================================================
// origin = box(0,0,0)
module hookBaseInside()
{
  //if (printMessages) echo("hookBaseInside() ..");
  
} // hookBaseInside()

//===========================================================
// origin = box(0,0,0)
module hookBaseOutside()
{
  //if (printMessages) echo("hookBaseOutside() ..");
  
} // hookBaseInside()

// **********************************************************
// **********************************************************
// **********************************************************
// *************** END OF TEMPLATE SECTION ******************
// **********************************************************
// **********************************************************
// **********************************************************

//---- This is where the magic happens ----
YAPPgenerate();

//---- Render the actual PCB in the box ----
module Pcb() {
  include <pico-plc.scad>;
}

if ($preview) {
  posX = translate2Box_X(0, yappBase, [yappCoordPCB, yappGlobalOrigin, "Pico-PLC"]);
  posY = translate2Box_Y(0, yappBase, [yappCoordPCB, yappGlobalOrigin, "Pico-PLC"]);
  posZ = translate2Box_Z(0, yappBase, [yappCoordPCB, yappGlobalOrigin, "Pico-PLC"]);

  translate([posX, posY, posZ]) {
    translate([pcbLength("Pico-PLC") / 2, pcbWidth("Pico-PLC") / 2, -pcbThickness("Pico-PLC") / 2]) {
      rotate([0, 0, 90]) {
        Pcb();
      }
    }
  }
}
