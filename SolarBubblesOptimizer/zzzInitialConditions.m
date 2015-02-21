%======================================================================
%FULLY PORTED
%======================================================================

function [InitialContinuousCharacteristics,InitialDiscreteCharacteristic]...
    =zzzInitialConditions()

%This function holds the initial conditions for the SolarSight Genetic Optimization Algorithm V2.0.
%By Ryan Klock, 3/4/2012
%Values last edited 10/11/2012 Brian Boomgaard (estimated)

%CONTINUOUS CHARACTERISTICS================================================
BoomLength=1.6;        %Boom length in meters extending backward from the trailing edge of the main wing
WingSpan=3.3;           %Wing span in meters
WingChord=0.37084;        %Wing chord in meters
TaperedSpan=.432348;       %Fractional portion of the wing tapered
WingtipChord=0.25;       %Wingtip chord in meters
Dihedral=5;             %Wing tapered section dihedral in degrees
WingTwist=2;            %Wing twist of tapered section in degrees
HorzTailChord=0.15;     %Horizontal tail chord in meters
VertTailChord=0.15;     %Vertical tail chord in meters
NumBatteryCells=10;     %Number of battery cells

InitialContinuousCharacteristics=[BoomLength WingSpan WingChord TaperedSpan ...
    WingtipChord Dihedral WingTwist HorzTailChord VertTailChord NumBatteryCells];

%DISCRETE CHARACTERISTICS==================================================
WingFoil={'naca5412'};

InitialDiscreteCharacteristic=WingFoil;