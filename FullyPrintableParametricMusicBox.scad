use <MCAD/involute_gears.scad>

$fn=32;

FOR_PRINT=false;

DEBUG_GEARS=0;
	
GENERATE_MUSIC_CYLINDER=1;
GENERATE_MID_GEAR=1;
GENERATE_CRANK_GEAR=1;

GENERATE_CASE=1;

GENERATE_CRANK=0;
GENERATE_PULLEY=0;

//////////////////////////////////////
// general settings

diametral_pitch = 0.6;
gearH=3;
wall=2;

// HoldderH is the height of the axis kegel

crankAxisHolderH = 1.5;
midAxisHolderH=3;
musicAxisHolderH=3;

pulleySlack=0.4;
crankSlack=0.2;
snapAxisSlack=0.6; // for extra distance from axis to gears
axisSlack=0.3; // for crank gear axis to case

pulleySnapL=1.2; // cutout to get Pulley in
// higher tolerance makes the teeth thinner and they slip, too low tolerance jams the gears
gear_tolerance = 0.1;
// used for the distance between paralell gears that should not touch (should be slightly larger than your layer with) 
gear_gap = 0.8;
gear_min_gap = 0.1;
gear_hold_R = 4;

epsilonCSG = 0.1;

crankAxisR = 3;
crankAxisCutAway = crankAxisR*0.8;
crankLength = 25;
crankAxisCutAwayH = 5;

crankExtraH=5;
crankH=crankExtraH+2*crankAxisCutAwayH;


pulleyH=10;
pulleyR=crankAxisR+2*wall;


musicCylinderTeeth = 22;
midSmallTeeth = 8;
midBigTeeth = 19;
crankTeeth = 8;

noteAlpha = 10;
midGearAngle=-10;
crankGearAngle=42;



/// music section

// also nr of notes

teethNotes="C0 D0 E0 F0 G0 A0 B0 C1 D1 E1 F1 G1 A1 B1 C2 ";
pinNrX = 8;
pinNrY = 33;

/*
A4
B4
C4
D4
E4
F4
G4
A5
G4
F4
E4
D4
C4
B4
A4


A4
C4
E4

A4 C4 E4

C4 E4 A5

A4 C4 E4

C4 E4 G4

A4 D4 F4
*/
pins="X        X        X        X        X        X        X        X      X      X      X      X      X      X      X                       X         X         X           X X X             X X  X        X X X             X X X         X  X X  ";

teethH = 3*0.3;

pinH=1;

teethGap = max(gear_gap, pinH/(2*sqrt(2)));

pinD=1;

teethHolderW=4;
teethHolderH=7;


//// Constants 
epsilon = 0.01;
baseFrequC0 = 16.3516;
ro_PLA = 0.6* (1210 + 1430)/2; // http://de.wikipedia.org/wiki/Polylactide
E_PLA = 1.3*   1000000 *(2.5+7.8)/2; // http://www.kunststoff-know-how.de/index.php?/%C3%9Cbersicht-Biokunststoffe.html 2,5 - 7,8 GPa
gammaTooth = 1.875; // http://de.wikipedia.org/wiki/Durchschlagende_Zunge#Berechnung_der_Tonh.C3.B6he


circular_pitch = 180/diametral_pitch;

addendum = 1/diametral_pitch;


musicH=pinNrX*(wall+teethGap);

echo(musicH);

//// Derived Music stuff


pinStepX = musicH/pinNrX;
pinStepY = 360/pinNrY;

teethW = pinStepX-teethGap;
maxTeethL=TeethLen(0); // convention index 0 is lowest note
///////////////////////



musicCylinderR = (musicCylinderTeeth/diametral_pitch)/2;
midSmallR = (midSmallTeeth/diametral_pitch)/2;
midBigR = (midBigTeeth/diametral_pitch)/2;
crankR = (crankTeeth/diametral_pitch)/2;

centerForCrankGearInsertion=(midBigR+crankR)/2;





//noteExtend = wall+20;
noteExtend = teethHolderW+maxTeethL+pinH/1.5+sin(noteAlpha)*teethH; //+wall+sin(noteAlpha)*wall;

echo(sin(noteAlpha)*wall);



midGearDist = musicCylinderR+midSmallR;
crankDist = midBigR+crankR;

midGearXPos = cos(midGearAngle)*midGearDist;
midGearZPos = sin(midGearAngle)*midGearDist;

crankGearXPos = midGearXPos + cos(crankGearAngle)*crankDist;
crankGearZPos = midGearZPos + sin(crankGearAngle)*crankDist;

echo(musicCylinderR);
frameH = max(musicCylinderR, -midGearZPos+midBigR)+1.5*addendum;

gearBoxW = 2 * (gearH+gear_gap+wall) + gear_gap;


songH = musicH+teethGap;
frameW = gearBoxW + songH;



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
posXEnd = crankGearXPos + crankR + 1.5*addendum + wall;

posYEnd = tan(noteAlpha)*(noteExtendX + musicCylinderRX+posXEnd);

 



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

		// PIANO :)
		
		translate([-(noteExtendX+musicCylinderRX),-(gearH/2+gear_gap+teethGap),0]) 
			rotate([0,-noteAlpha*1,0])
			
				MusicBox();

	
		// snapaxis for crank
		MyAxisSnapHolder(h=crankAxisHolderH, x=crankGearXPos, y =gearH/2+gear_gap, z=crankGearZPos, mirr=0, extra=gear_gap+epsilonCSG);
	
	
	
		// snapaxis for music cylinder
		MyAxisSnapHolder(h=musicAxisHolderH, y =gearH/2-gear_gap, mirr=1, extra=gearH+2*gear_gap);
		MyAxisSnapHolder(h=musicAxisHolderH, y =gearH/2 +1*gear_gap +songH, extra=gear_gap+epsilonCSG, mirr=0);
	
		// snapaxis for mid gear
		MyAxisSnapHolder(h=midAxisHolderH, y =1.5*gearH, x=midGearXPos, z=midGearZPos, mirr=1);
		MyAxisSnapHolder(h=midAxisHolderH, y =gearH/2+gear_gap, x=midGearXPos, z=midGearZPos, mirr=0);
	
		difference()
		{
			// side poly extruded and rotated to be side
			rotate([-90,0,0]){
				translate([0,0,-frameW+1.5*gearH + gear_gap+wall])
					linear_extrude(height=frameW) 
						polygon(points=
[[negXEnd,0],[posXEnd,-posYEnd],[posXEnd,frameH], [negXEnd,frameH]], paths=[[0,1,2,3]]);
	
			
			}

// cutout, wall then remain
		linear_extrude(height=4*frameH, center=true) 
					polygon(points=[
[negXEnd+wall,-(0.5*gearH+2*gear_gap+songH)],
[musicCylinderR+1.5*addendum,-(0.5*gearH+songH+2*gear_gap)],
[musicCylinderR+1.5*addendum,-(0.5*gearH+2*gear_gap)],
[posXEnd-wall,-(0.5*gearH+2*gear_gap)],
[posXEnd-wall,(1.5*gearH+gear_gap)],
 [negXEnd+wall,(1.5*gearH+gear_gap)]
], paths=[[0,1,2,3,4,5,6]]);
	

		}
	}

		// cutout, make sure gears can rotate
		linear_extrude(height=4*frameH, center=true) 
					polygon(points=[
[0+1*crankAxisR,(1.5*gearH+gear_gap)],
[0+1*crankAxisR,-(2.5*gearH+gear_gap+frameW)],
[musicCylinderR+1.5*addendum,-(2.5*gearH+gear_gap+frameW)],
[musicCylinderR+1.5*addendum,(1.5*gearH+gear_gap)]], paths=[[0,1,2,3]]);


// cutout because of narrow smallgear
			linear_extrude(height=4*frameH, center=true) 
					polygon(points=[
[1*crankAxisR,-(0.5*gearH+2*gear_gap+wall)],
[1*crankAxisR,-100],
[posXEnd+1,-100],
[posXEnd+1,-(0.5*gearH+2*gear_gap+wall)]], paths=[[0,1,2,3]]);


			// Crank Gear Cutouts
			translate([crankGearXPos,0,crankGearZPos])
			{
				rotate([-90,0,0])
					cylinder(h=100, r=crankAxisR+axisSlack, center=false);



*rotate([0,180-90-max(crankGearAngle,45+noteAlpha),0]) 
				//translate([-(crankR+addendum*1.5),0,0]) 
//mirror([0,1,0]) 
rotate([90,0,0])
#linear_extrude(height=musicH/2, center=false) 
					polygon(points=[
[-(crankR+addendum*1.5),-1*frameH],
[(crankR+addendum*1.5),-1*frameH],
[(crankR+addendum*1.5),0],
[-(crankR+addendum*1.5),0]],
paths=[[0,1,2,3]]);
//cube([100,100,2*frameH]);

				rotate([0,-90-max(crankGearAngle,45+noteAlpha),0]) 
				{

					*translate([-(crankAxisR-axisSlack),0,0]) cube([2*(crankAxisR),100, centerForCrankGearInsertion]);

					
rotate([-90,0,0])
linear_extrude(height=musicH/2, center=false) 
					polygon(points=[
[-(crankAxisR+axisSlack),-centerForCrankGearInsertion],
[(crankAxisR+axisSlack),-centerForCrankGearInsertion],
[(crankAxisR),0],
[-(crankAxisR),0]],
paths=[[0,1,2,3]]);
//cube([100,100,2*frameH]);



					translate([0*(crankR+addendum*1.5),0,centerForCrankGearInsertion])
					rotate([90,0,0])
					cylinder(h=100, r=(crankR+addendum*1.5), center=false);

					translate([0*(crankR+addendum*1.5),0,centerForCrankGearInsertion])
					mirror([0,1,0])
					rotate([90,0,0])
					cylinder(h=100, r=crankAxisR+axisSlack, center=false);

				}	
			}

	}
	
	}
}
}


// music cylinder and gear
if (GENERATE_MUSIC_CYLINDER)
{

	rotate([FOR_PRINT?0:-90,0,0])
		translate([0,0,-gear_gap])
		difference()
		{
			union()
			{
				MyGear(n=musicCylinderTeeth, hPos = gearH/2, hNeg=gearH/2);
				rotate([0, 180,0]) 
translate([0,0,teethGap+gearH/2]) 
{
rotate([0,0,27]) MusicCylinder(extra=teethGap+epsilonCSG);
//cylinder(h=musicH, r = musicCylinderR);
}
				// PINS :)
			}
			MyAxisSnapCutout(h=musicAxisHolderH, z=-(gearH/2)-songH, mirr=0);
			MyAxisSnapCutout(h=musicAxisHolderH, z=gearH/2, mirr=1);
		}
}

// midGear
color([0,0,1])
if (GENERATE_MID_GEAR)
{
	translate([midGearXPos,0,midGearZPos])
		rotate([FOR_PRINT?180:-90,0,0])
			difference()
			{
			union() {
				translate([0,0,gearH]) 
				{
					difference(){
						MyGear(n=midBigTeeth, hPos = gearH/2, hNeg=gearH/2,mirr=1);
						
					}
				}
				translate([0,0,-gear_gap])
				difference()
				{
					MyGear(n=midSmallTeeth, hPos = gearH/2+gear_gap+epsilonCSG, hNeg=gearH/2, mirr=1);
				}
				
			}
			translate([0,0,-gear_gap])			
					MyAxisSnapCutout(h=midAxisHolderH, z=-(gearH/2), mirr=0);
			translate([0,0,gearH]) MyAxisSnapCutout(h=midAxisHolderH, z=(gearH/2), mirr=1);
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
					MyGear(n=crankTeeth, hPos = gearH/2, hNeg=1.5*gearH+gear_gap, mirr=0);	
				}
				MyAxisSnapCutout(h=crankAxisHolderH, z=-1.5*gearH-gear_gap);
			}
		}
}

// crank
color([0,1,0])
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



echo(1000 * LengthOfTooth(240, 0.002, E_PLA, ro_PLA));
echo(1000 * LengthOfTooth(340, 0.002, E_PLA, ro_PLA));
echo(1000 * LengthOfTooth(440, 0.002, E_PLA, ro_PLA));
echo(1000 * LengthOfTooth(540, 0.002, E_PLA, ro_PLA));
echo(1000 * LengthOfTooth(640, 0.002, E_PLA, ro_PLA));
echo(1000 * LengthOfTooth(740, 0.002, E_PLA, ro_PLA));

echo(NoteToFrequ(9, 4, 0));


//// SPECFIC functions
function TeethLen(x) = 
	1000*LengthOfTooth(NoteToFrequ(LetterToNoteIndex(teethNotes[x*3]), 
			LetterToDigit(teethNotes[x*3+1]),
			AccidentalToNoteShift(teethNotes[x*3+2])),
			teethH/1000, E_PLA, ro_PLA);



//// PLATONIC functions
// http://de.wikipedia.org/wiki/Durchschlagende_Zunge#Berechnung_der_Tonh.C3.B6he
// f [Hz]
// h m
// E N/m2
// ro kg/m3
function LengthOfTooth(f, h, E, ro) =
sqrt((gammaTooth*gammaTooth*h/(4*PI*f))*sqrt(E/(3*ro)));

function NoteToFrequ(note, octave, modification) = baseFrequC0*pow(2, octave)*pow(2, note/12);

function AccidentalToNoteShift(l) =
l=="#"?1:
l=="b"?-1:
0;

function LetterToNoteIndex(l) =
l=="C"?0:
l=="D"?2:
l=="E"?4:
l=="F"?5:
l=="G"?7:
l=="A"?9:
l=="H"?11:
l=="B"?11: // allow B and H
0;

function LetterToDigit(l) = 
l=="0"?0:
l=="1"?1:
l=="2"?2:
l=="3"?3:
l=="4"?4:
l=="5"?5:
l=="6"?6:
l=="7"?7:
l=="8"?8:
l=="9"?9:
0;





module Pin()
{
	difference()
	{
		//cylinder(h=2*pinH, r=pinStepX/2, center=true, $fn=4);
		translate([-pinStepX/2,-pinD/2,-pinH])
		cube([pinStepX+teethGap, pinD, 2*pinH],center=false);

translate([pinStepX/2,0,0])
		rotate([0,-45,0]) translate([2.0*pinStepX+pinH/2,0,0]) cube([4*pinStepX,4*pinStepX,4*pinStepX],center=true);
	}
}



module MusicCylinder(extra=0)
{
	translate([0,0,-extra]) cylinder(r = musicCylinderR, h = musicH+extra, center=false, $fn=128);
	for (x = [0:pinNrX-1], y = [0:pinNrY-1])
	{
		assign(index = y*pinNrX + x)
		{
			if (pins[index] == "X")
			{
				
				rotate([0,0, y * pinStepY])
					translate([musicCylinderR, 0, (0.5+x)*pinStepX]) rotate([0,90,0])
							Pin();
			}
		}
	}
}



module MusicBox()
{
	//mirror([0,0,1])
	translate([teethHolderW+maxTeethL,0,0])

	rotate([180,0,0])
	for (x = [0:pinNrX-1])
	{
		assign(ll = TeethLen(x))
		{
			translate([-maxTeethL, x *pinStepX, 0]) 
			{
				// teeth holder
				translate([-(teethHolderW), 0, 0]) 
					cube([teethHolderW+maxTeethL-ll, pinStepX, teethHolderH]);

				// teeth
				translate([-teethHolderW/2, teethGap,0])
				color([0,1,0])cube([maxTeethL+teethHolderW/2, teethW, teethH]);
			}
		}
	}
	
}

