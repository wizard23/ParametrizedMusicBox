use <MCAD/involute_gears.scad>

$fn=32;

FOR_PRINT=false;

DEBUG_GEARS=false;

GENERATE_MUSIC_CYLINDER=true;
GENERATE_MID_GEAR=true;
GENERATE_CRANK_GEAR=false;

GENERATE_CASE=true;

GENERATE_CRANK=false;
GENERATE_PULLEY=false;


//pitch=2*3.1415*pitchRadius/numberTeeth;

diametral_pitch = 1;
circular_pitch = 180/diametral_pitch;

addendum = 1/diametral_pitch;


gearH=4;
wall=2;


pinH=1;

// HoldderH is the height of the axis kegel

crankAxisHolderH = 1.5;
midAxisHolderH=1.9;
musicAxisHolderH=1.9;

pulleySlack=0.4;
crankSlack=0.2;
snapAxisSlack=0.1; // for extra distance from axis to gears
axisSlack=0.3; // for crank gear axis

pulleySnapL=1.2; // cutout to get Pulley in
// higher tolerance makes the teeth thinner and they slip, too low tolerance jams the gears
gear_tolerance = 0.1;
// used for the distance between paralell gears that should not touch (should be slightly larger than your layer with) 
gear_gap = 1.0;
gear_min_gap = 0.1;
gear_hold_R = 2;

epsilonCSG = 0.1;

crankAxisR = 3;
crankAxisCutAway = crankAxisR*0.8;
crankLength = 25;
crankAxisCutAwayH = 5;

crankExtraH=5;
crankH=crankExtraH+2*crankAxisCutAwayH;


pulleyH=10;
pulleyR=crankAxisR+2*wall;


musicCylinderTeeth = 44;
midSmallTeeth = 8;
midBigTeeth = 33;
crankTeeth = 11;

musicCylinderR = (musicCylinderTeeth/diametral_pitch)/2;
midSmallR = (midSmallTeeth/diametral_pitch)/2;
midBigR = (midBigTeeth/diametral_pitch)/2;
crankR = (crankTeeth/diametral_pitch)/2;



noteExtend = wall+20;
noteAlpha = 10;


midGearAngle=-10;
crankGearAngle=30;


midGearDist = musicCylinderR+midSmallR;
crankDist = midBigR+crankR;

midGearXPos = cos(midGearAngle)*midGearDist;
midGearZPos = sin(midGearAngle)*midGearDist;

crankGearXPos = midGearXPos + cos(crankGearAngle)*crankDist;
crankGearZPos = midGearZPos + sin(crankGearAngle)*crankDist;

echo(musicCylinderR);
frameH = max(musicCylinderR, -midGearZPos+midBigR)+2*addendum;



// noteExtend in alpha angle projected to y and x-axis
noteExtendY = sin(noteAlpha)*noteExtend;
noteExtendX = cos(noteAlpha)*noteExtend;
echo(noteExtendY/musicCylinderR);
noteBeta = asin(noteExtendY/musicCylinderR);

echo(noteExtendX);
echo(noteExtendY);
echo(noteBeta);

// musicCylinderR to intersection with noteExtend
musicCylinderRX = cos(noteBeta)*musicCylinderR;




negXEnd = -(noteExtendX+musicCylinderRX);
posXEnd = crankGearXPos + crankR + 2*addendum + wall;

posYEnd = sin(noteAlpha)*(noteExtendX + musicCylinderRX+posXEnd);

 



// case shape
if (GENERATE_CASE)
{	
	intersection()
	{
		if (FOR_PRINT)
		{
			translate([0,0, 500+negXEnd*sin(noteAlpha)]) cube([1000, 1000, 1000], center=true);
		}
	rotate([FOR_PRINT?180:0, FOR_PRINT?-noteAlpha:0,0])
	{

	difference()
	{
		union()
		{
	
		// snapaxis for crank
		MyAxisSnapHolder(h=crankAxisHolderH, x=crankGearXPos, y =gearH/2, z=crankGearZPos, mirr=0, extra=gear_gap+epsilonCSG);
	
	
	
		// snapaxis for music cylinder
		MyAxisSnapHolder(h=musicAxisHolderH, y =gearH/2, mirr=1, extra=gearH+2*gear_gap);
		MyAxisSnapHolder(h=musicAxisHolderH, y =gearH/2, mirr=0);
	
		// snapaxis for mid gear
		MyAxisSnapHolder(h=midAxisHolderH, y =1.5*gearH, x=midGearXPos, z=midGearZPos, mirr=1);
		MyAxisSnapHolder(h=midAxisHolderH, y =gearH/2-gear_gap, x=midGearXPos, z=midGearZPos, mirr=0);
	
		difference()
		{
			// side poly extruded and rotated to be side
			rotate([-90,0,0]){
				translate([0,0,-(gearH/2+gear_gap+wall)])
					linear_extrude(height=2*(gearH+gear_gap+wall)) 
						polygon(points=[[negXEnd,0],[posXEnd,-posYEnd],[posXEnd,frameH], [negXEnd,frameH]], paths=[[0,1,2,3]]);
	
			
			}

// cutout, wall then remain
		linear_extrude(height=4*frameH, center=true) 
					polygon(points=[[negXEnd+wall,-(0.5*gearH+gear_gap)],


//[1.5*crankAxisR,-(0.5*gearH+gear_gap)],
//[1.5*crankAxisR,-(2.5*gearH+gear_gap)],
//[midGearXPos-1.5*crankAxisR,-(2.5*gearH+gear_gap)],
//[midGearXPos-1.5*crankAxisR,-(0.5*gearH+gear_gap)],

[posXEnd-wall,-(0.5*gearH+gear_gap)],[posXEnd-wall,(1.5*gearH+gear_gap)], [negXEnd+wall,(1.5*gearH+gear_gap)]], paths=[[0,1,2,3]]);
	
			translate([crankGearXPos,0,crankGearZPos])
			{
				rotate([-90,0,0])
					cylinder(h=100, r=crankAxisR+axisSlack, center=false);
				rotate([0,180,0]) translate([-(crankAxisR+axisSlack),0,0]) cube([2*(crankAxisR+axisSlack),100, frameH]);
			}
	translate([+500+crankGearXPos-crankR-2*addendum, -500, -500-3*crankAxisR+crankGearZPos]) cube([1000,1000,1000], center=true);
		}
	}

		// cutout, wall then remain
		linear_extrude(height=4*frameH, center=true) 
					polygon(points=[

[1*crankAxisR,(1.5*gearH+gear_gap)],
[1*crankAxisR,-(2.5*gearH+gear_gap)],
[musicCylinderR+1.5*addendum,-(2.5*gearH+gear_gap)],
[musicCylinderR+1.5*addendum,(1.5*gearH+gear_gap)]], paths=[[0,1,2,3]]);

	}


	}
}
}


// music cylinder and gear
if (GENERATE_MUSIC_CYLINDER)
{

	rotate([FOR_PRINT?0:-90,0,0])
		difference()
		{
			MyGear(n=musicCylinderTeeth, hPos = gearH/2, hNeg=gearH/2);
			MyAxisSnapCutout(h=musicAxisHolderH, z=-(gearH/2), mirr=0);
			MyAxisSnapCutout(h=musicAxisHolderH, z=gearH/2, mirr=1);
		}
}

// midGear
if (GENERATE_MID_GEAR)
{
	translate([midGearXPos,0,midGearZPos])
		rotate([FOR_PRINT?180:-90,0,0])
			union() {
				translate([0,0,gearH]) 
				{
					difference(){
						MyGear(n=midBigTeeth, hPos = gearH/2, hNeg=gearH/2-gear_gap,mirr=1);
						MyAxisSnapCutout(h=midAxisHolderH, z=(gearH/2), mirr=1);
					}
				}
				difference()
				{
					MyGear(n=midSmallTeeth, hPos = gearH/2+gear_gap+epsilonCSG, hNeg=gearH/2-gear_gap, mirr=1);
					MyAxisSnapCutout(h=midAxisHolderH, z=-(gearH/2-gear_gap), mirr=0);
				}
				
			}
}



if (GENERATE_CRANK_GEAR)
{
	// crank gear
	translate([crankGearXPos,0,crankGearZPos])
		rotate([FOR_PRINT?0:-90,0,0])
		union() {
			translate([0,0,gearH]) 
			difference()
			{
				union() {
					difference() {
						cylinder(h=gearH/2+wall+2*gear_gap+2*crankAxisCutAwayH, r=crankAxisR, center=false);
						translate([0,50+crankAxisR-crankAxisCutAway,gearH/2+wall+gear_gap+2*crankAxisCutAwayH])cube([100,100,crankAxisCutAwayH*2], center=true);
					}
					cylinder(h=gearH/2+gear_gap-gear_min_gap, r=crankR-addendum, center=false);
					MyGear(n=crankTeeth, hPos = gearH/2, hNeg=1.5*gearH, mirr=0);	
				}
				MyAxisSnapCutout(h=crankAxisHolderH, z=-1.5*gearH);
			}
		}
}

// crank
if (GENERATE_CRANK)
{
	translate([FOR_PRINT?0:crankGearXPos, FOR_PRINT?0:1.5*gearH+2*gear_gap+wall+crankH, FOR_PRINT?0:crankGearZPos])

	rotate([FOR_PRINT?0:-90,0,0])
	mirror([0,0,FOR_PRINT?0:1])
	{
		// to gear snapping
		difference() {
			cylinder(h=crankH, r=crankAxisR+crankSlack+wall,center=false);
			translate([0,0,crankH])  difference() {
				cylinder(h=4*crankAxisCutAwayH, r=crankAxisR+crankSlack,center=true);
				translate([0,50+crankAxisR+crankSlack-crankAxisCutAway,-2*crankAxisCutAwayH])cube([100,100,crankAxisCutAwayH*2], center=true);
			}
		}
		
		translate([crankLength,0,0]) 
			difference() {
				union() {
					// crank long piece
					translate([-crankLength/2,0,wall/2])
						cube([crankLength,2*(crankAxisR),wall],center=true);
					translate([-crankLength/2,0,crankExtraH/2])
							cube([crankLength,wall,crankExtraH],center=true);
					// where puley snaps/axis
					cylinder(h=crankExtraH, r=crankAxisR+pulleySlack+wall,center=false);
				}
				cylinder(h=3*crankExtraH, r=crankAxisR+pulleySlack,center=true);
				translate([50,0,0]) cube([100, 2*crankAxisR-2*pulleySnapL, 100], center=true);
			}
				
	}
}

if (GENERATE_PULLEY)
{
	translate([FOR_PRINT?0:crankGearXPos, FOR_PRINT?0:1.5*gearH+2*gear_gap+wall+crankH-crankExtraH, FOR_PRINT?0:crankGearZPos])	
	rotate([FOR_PRINT?180:-90,0,0])
	translate([crankLength,0,0]) 
	{
		// delta shaped end
		translate([0,0,-wall-gear_gap]) cylinder(h=crankAxisR+wall+gear_gap, r2=0, r1=crankAxisR+wall,center=false);
		// axis
		translate([0,0,-wall/2]) cylinder(h=crankExtraH+pulleyH+wall/2, r=crankAxisR,center=false);
		// handle
		translate([0,0,crankExtraH+gear_gap]) cylinder(h=pulleyH+gear_gap, r=crankR,center=false);
	}
}

module MyAxisSnapCutout(h, z=0, mirr=0,extra=epsilonCSG)
{
	translate([0,0,z])
	mirror([0,0,mirr])
	translate([0,0,-extra]) 
	{	
		cylinder(h=h+extra+snapAxisSlack, r1=h+extra+snapAxisSlack, r2=0, center=false);
	}
}


module MyAxisSnapHolder(h, x=0, y=0, z=0, mirr=0,extra=wall, h2=0)
{
	rotate([-90,0,0])
	mirror([0,0,mirr])
	translate([x,-z,-extra-y]) 
	{
		cylinder(h=h+extra, r1=h+extra, r2=0, center=false);
		intersection()
		{
			cylinder(h=h+extra+gear_hold_R, r1=h+extra+gear_hold_R, r2=0, center=false);
			translate([0, 0, -50 + extra -gear_min_gap])
				cube([100, 100, 100], center=true);
		}
	}
}

module MyGear(n=20, hPos, hNeg, mirr=0)
{
	if (DEBUG_GEARS)
	{
		translate([0,0,-hNeg]) cylinder(r=(n/diametral_pitch)/2, h=hPos+hNeg, center = false);
	}
	if (!DEBUG_GEARS)
	{
		HBgear(n=n, mirr=mirr, hPos=hPos, hNeg=hNeg, tol=gear_tolerance);
	}
}


// based on Emmet's herringbone gear taken from thing: TODO
module HBgear(n,hPos,hNeg,mirr=0, tol=.25)// herringbone gear
{
twistScale=50;
mirror([mirr,0,0])
translate([0,0,0])
union(){
	mirror([0,0,1])
	gear(number_of_teeth=n,
		diametral_pitch=diametral_pitch,
		gear_thickness=hNeg,
		rim_thickness=hNeg,
		hub_thickness=hNeg,
		bore_diameter=0,
		backlash=2*tol,
		clearance=2*tol,
		pressure_angle=20,
		twist=hNeg*twistScale/n,
		slices=10);
	
	gear(number_of_teeth=n,
		diametral_pitch=diametral_pitch,
		gear_thickness=hPos,
		rim_thickness=hPos,
		hub_thickness=hPos,
		bore_diameter=0,
		backlash=2*tol,
		clearance=2*tol,
		pressure_angle=20,
		twist=hPos*twistScale/n,
		slices=10);
}
}