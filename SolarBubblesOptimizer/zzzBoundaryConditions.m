%=======================================================================
%PORTING COMPLETE
%=======================================================================

function [ContinuousMaximums,ContinuousMinimums,Invariants,DiscretePossibilities]...
    =zzzBoundaryConditions()

%This function stores the boundary conditions, invariant constraints, and discrete characteristic possibilities for the SolarBubbles Genetic Algorithm Optimizer Version 2.0.
%By Ryan Klock, 3/4/2012
%Values last updated 10/11/2012 Brian Boomgaard (estimates)

%MAXIMUM VALUES============================================================
MaxBoom=2.0;        %Max boom length in meters extending backward from the trailing edge of the maing wing
MaxWingSpan=3.6;    %Max main wing span in meters
MaxWingChord=0.6;   %Max main wing chord in meters
MaxTaperSpan=1;     %Max main wing tapered span as a fraction of the total span
MaxWingtipChord=.5;  %Max main wingtip chord in meters
MaxDihedral=10;      %Max main wing tapered span dihedral in degrees
MaxWingTwist=4;    %Max main wing twist of tapered span in degrees
MaxHorzTailChord=.25;%Max horizontal tail chord in meters
MaxVertTailChord=.25;%Max vertical tail chord in meters
MaxBatteryCells=20; %Max number of battery cells/packs

ContinuousMaximums=[MaxBoom MaxWingSpan MaxWingChord MaxTaperSpan MaxWingtipChord ...
    MaxDihedral MaxWingTwist MaxHorzTailChord MaxVertTailChord MaxBatteryCells];

%MINIMUM VALUES============================================================
MinBoom=1.0;        %Min boom length in meters extending backward from the trailing edge of the maing wing
MinWingSpan=3.0;    %Min main wing span in meters
MinWingChord=0.0;   %Min main wing chord in meters
MinTaperSpan=0;     %Min main wing tapered span as a fraction of the total span
MinWingtipChord=.1;  %Min main wingtip chord in meters
MinDihedral=7;      %Min main wing tapered span dihedral in degrees
MinWingTwist=1;     %Min main wing twist of tapered span in degrees
MinHorzTailChord=.1;%Min horizontal tail chord in meters
MinVertTailChord=.1;%Min vertical tail chord in meters
MinBatteryCells=4;  %Min number of battery cells/packs

ContinuousMinimums=[MinBoom MinWingSpan MinWingChord MinTaperSpan MinWingtipChord ...
    MinDihedral MinWingTwist MinHorzTailChord MinVertTailChord MinBatteryCells];

%INVARIANT CONSTRAINTS=====================================================
MaxCruise=25;       %Max cruise speed in meters per second
TakeoffThrust=10;   %TakeoffThrust in Newtons (assumed maximum static thrust of motor/prop)
MaxWingLoad=5500;   %Max wing loading in grams per meter squared
PayloadMass=250;    %Payload mass in grams
PayloadPower=10.0;  %Electrical power consumed by the payload in Watts
FuselageMass=650;   %Fuselage mass in grams (including all avionics)
UnitBoomMass=120;   %Mass of 1 meter boom in grams
AvionicsPower=10;   %Electrical power consumed by the avionics in Watts
SolarSpan=0.0254;   %Spanwise length of a single solar cell in meters
SolarChord=0.0762;  %Chordwise length of a single solar cell in meters
SolarMass=3.8;    %Mass of a single solar cell, respective encapsulation, and wiring in grams
SolarEff=.27;       %Fractional efficiency of the solar cells
BatterySpan=0.2032; %Spanwise length of a single battery cell/pack in meters
BatteryChord=0.0381;%Chordwise length of a single battery cell/pack in meters
BatteryThick=0.0191;%Thickness of a single battery cell/pack in meters
BatteryMass=270;    %Mass of a single battery cell/pack in grams
BatteryCap=213840*1.1;  %Energy capacity of a battery cell/pack in Joules
HorzTailCoeff=0.5;  %Horizontal tail sizing coefficient
VertTailCoeff=0.02; %Vertical tail sizing coefficient
FuselageRad=0.0927;    %Diameter of the fuselage in meters
UnitNoseMass=1000;  %Mass of 1 meter of constant diameter fuselage
UsefulUpperWingSurfaceFraction=0.9;%Faction of main wing upper surface available for solar cell placement
SolarCellsInSeries=11;%Number of solar cells to be placed in series to achieve desired system voltage
AirfoilSplineSpacing=0.001;%Cubic spline spacing in meters for enhancing the airfoil profiles if needed
BatterySupportThickness=0.175;%Fractional thickness of airfoil profile required for structure to pass around battery packs
DriveTrainSystemMass=150;%Baseline mass of the drivetrain system in grams for nose cone sizing estimatents
UnitWingMass=1089.32;%Mass of 1 meter squared planform area wing in grams
StallSpeedSafetyFactor=1.05;%Factor of safety such that the aircraft is not on the verge of stalling during cruise
SimulationTimeStep=200;%Time increments considered during endurance simulation in seconds

Invariants=[MaxCruise TakeoffThrust MaxWingLoad PayloadMass PayloadPower FuselageMass ...
    UnitBoomMass AvionicsPower SolarSpan SolarChord SolarMass SolarEff BatterySpan ...
    BatteryChord BatteryThick BatteryMass BatteryCap HorzTailCoeff VertTailCoeff ...
    FuselageRad UnitNoseMass UsefulUpperWingSurfaceFraction SolarCellsInSeries ...
    AirfoilSplineSpacing BatterySupportThickness DriveTrainSystemMass UnitWingMass ...
    StallSpeedSafetyFactor SimulationTimeStep];

%DISCRETE PARAMETER POSSIBILITIES==========================================

%Wing Profiles saved as CSV files
DiscretePossibilities={...
    'apex16';'aquilasm';...
    'dae11';'dae21';'dae31';'dae51';...
    'df101';'df102';...
    'e66';'e67';'e68';'e193';'e205';'e214';'e231';'e387';'e392';'e407';'e431';'e432';'e433';'e434';'e435';'e582';'e583';'e584';'e585';'e587';'e642';'e668';...
    'fx60100sm';...
    'geminism';...
    'hobie';'hobiesm';...
    'hq010';'hq1012';'hq2010';'hq2012';'hq2511';'hq3011';'hq3514';...
    'naca5412';...
    'psu-90-125wl';...
    's9037';'sd7043';'sd7090';...
    'spicasm';...
    'wb13535sm'};