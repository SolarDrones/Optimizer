function [Mass,BatteryCoordinates,SolarCellCoordinates]...
    =zzzStructures...
    (ContinuousCharacteristics,DiscreteCharacteristic,Invariants)

%This function estimates aircraft mass, battery pack layout, and solar cell layout for the SolarSight Genetic Algorithm Optimizer V2.0
%By Ryan Klock, 3/6/2012

%CHARACTERIZING WING GEOMETRY==============================================
%establishing useful parameters
UsefulUpperWingSurfaceFraction=Invariants(22);
SolarCellsInSeries=Invariants(23);

%finding upper wing surface arc length (normalized w.r.t chord)
[xWingFoil,zWingFoil]=zzzAirfoilReader(DiscreteCharacteristic);
ArcLength=0;
for i=(2:1:length(xWingFoil))
    if zWingFoil(i)<0
        break
    end
    ArcLength=ArcLength+((xWingFoil(i)-xWingFoil(i-1))^2+(zWingFoil(i)-zWingFoil(i-1))^2)^0.5;
end


%================================================================================================================================================================================================
%PORTED TO HERE (SOLAR)
%================================================================================================================================================================================================


%ARRANGING SOLAR CELLS=====================================================
%creating chord profile at increments equal to the spanwise length of a solar cell
yOfTaperStart=(ContinuousCharacteristics(2)/2)*(1-ContinuousCharacteristics(4));
SolarCellChordProfile=zeros(1,floor(ContinuousCharacteristics(2)/(2*Invariants(9))));
for i=(1:1:length(SolarCellChordProfile))
    if i*Invariants(9)<yOfTaperStart
        SolarCellChordProfile(i)=ContinuousCharacteristics(3);
    else
        SolarCellChordProfile(i)=ContinuousCharacteristics(3)-((i*Invariants(9))-(ContinuousCharacteristics(2)/2)*(1-ContinuousCharacteristics(4)))*((ContinuousCharacteristics(3)-ContinuousCharacteristics(5))/((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4)));
    end
end

%finding arclength profile from chord profile and arclength previously found
SolarCellArcProfile=ArcLength*SolarCellChordProfile;

%discretely applying solar cells in series chordwise to find rough arrangement and maximum useable number of cells
CoordinateIndex=1;
for i=(1:1:length(SolarCellArcProfile))
    CurrentY=(i-1)*Invariants(9);
    CurrentX=SolarCellChordProfile(i)*(1-UsefulUpperWingSurfaceFraction)/2+(0.25*(SolarCellChordProfile(1)-SolarCellChordProfile(i)));
    InitialArc=SolarCellArcProfile(i)*UsefulUpperWingSurfaceFraction;
    RemainingArc=InitialArc;
    while RemainingArc>Invariants(10)
        SolarCellCoordinates(1,CoordinateIndex)=CurrentX+(InitialArc-RemainingArc);
        SolarCellCoordinates(2,CoordinateIndex)=CurrentY;
        CoordinateIndex=CoordinateIndex+1;
        RemainingArc=RemainingArc-Invariants(10);
    end
end

%correcting for discrete solar cell string number
NumberOfSolarCellsOnWing=SolarCellsInSeries*floor(size(SolarCellCoordinates,2)/SolarCellsInSeries);
SolarCellCoordinates=SolarCellCoordinates(:,1:NumberOfSolarCellsOnWing);

%ARRANGING BATTERY PACKS===================================================
%finding leading edge of airfoil in profile
LeadingEdgeIndex=-1;
for i=(1:1:length(xWingFoil))
    if (xWingFoil(i)==0)&&(zWingFoil(i)==0)
        LeadingEdgeIndex=i;
        break
    end
end

%checking that leading edge was found
if LeadingEdgeIndex==-1
    fprintf('\n***error: leading edge of airfoil profile not found in file %s.dat***\n',char(DiscreteCharacteristic));
end

%seperating upper and lower surface profiles
for i=(1:1:length(xWingFoil))
    if i<LeadingEdgeIndex
        UpperProfileX(i)=xWingFoil(i);
        UpperProfileZ(i)=zWingFoil(i);
    elseif i==LeadingEdgeIndex
        UpperProfileX(i)=xWingFoil(i);
        UpperProfileZ(i)=zWingFoil(i);
        LowerProfileX(1)=xWingFoil(i);
        LowerProfileZ(1)=zWingFoil(i);
    elseif i>LeadingEdgeIndex
        LowerProfileX=[LowerProfileX xWingFoil(i)];
        LowerProfileZ=[LowerProfileZ zWingFoil(i)];
    end
end

%reversing upper surface profile from trailing edge first to leading edge first
UpperProfileX=fliplr(UpperProfileX);
UpperProfileZ=fliplr(UpperProfileZ);

%sizing surface profiles for current chord length
UpperProfileX=UpperProfileX*ContinuousCharacteristics(3);
UpperProfileZ=UpperProfileZ*ContinuousCharacteristics(3);
LowerProfileX=LowerProfileX*ContinuousCharacteristics(3);
LowerProfileZ=LowerProfileZ*ContinuousCharacteristics(3);

%generating cubic splines at known datapoint spacing from upper and lower surface profiles
SplinedUpperProfileX=0:Invariants(24):ContinuousCharacteristics(3);
SplinedUpperProfileZ=spline(UpperProfileX,UpperProfileZ,SplinedUpperProfileX);
SplinedLowerProfileX=0:Invariants(24):ContinuousCharacteristics(3);
SplinedLowerProfileZ=spline(LowerProfileX,LowerProfileZ,SplinedLowerProfileX);

% %finding chord and span location where airfoil thickness is sufficient for battery pack storage
% BatteryPacksRemainingToPlace=floor(ContinuousCharacteristics(10)/2);
% SignalToBreak=0;
% BatteryCoordinates=zeros(3,1);
% for i=(1:1:length(SplinedUpperProfileX))
%     for j=(0:Invariants(13):((ContinuousCharacteristics(2)*(1-ContinuousCharacteristics(4)))/2))
%         if ((SplinedUpperProfileZ(i)-SplinedLowerProfileZ(i))*(1-Invariants(25)))>Invariants(15)
%             BatteryPacksRemainingToPlace=BatteryPacksRemainingToPlace-1;
%             BatteryCoordinates(1,size(BatteryCoordinates,2)+1)=SplinedUpperProfileX(i);
%             BatteryCoordinates(2,size(BatteryCoordinates,2)+1)=j;
%             BatteryCoordinates(3,size(BatteryCoordinates,2)+1)=SplinedLowerProfileZ(i)+Invariants(25)/2;
%         end
%         if BatteryPacksRemainingToPlace==0
%             SignalToBreak=1;
%             break
%         end
%     end
%     if SignalToBreak
%         break
%     end
% end
% 
% %trimming extra first column value of battery coordinates matrix
% BatteryCoordinates(:,1)=[];
% 
% %finding if all battery packs were placed
% if BatteryPacksRemainingToPlace>0
%     fprintf('\n***error: unable to place all %f battery packs in wing profile\n%s.dat with wing span of %f and chord of %f,\nreducing number of battery packs to %d***\n',ContinuousCharacteristics(10),char(DiscreteCharacteristic),ContinuousCharacteristics(2),ContinuousCharacteristics(3),size(BatteryCoordinates,2));
% end
% 
% %finding number of battery packs successfully placed
% NumberOfBatteryPacksInWing=size(BatteryCoordinates,2);

%//////////////Battery Packs Determined via Wing Loading After Semi-summing Aircraft Mass Below/////////////////

%DETERMINING TAIL STRUCTURE MASS===========================================
Sref=(ContinuousCharacteristics(2)-ContinuousCharacteristics(2)*ContinuousCharacteristics(4))*ContinuousCharacteristics(3)+2*(.5*((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))*(ContinuousCharacteristics(3)+ContinuousCharacteristics(5)));
HorizontalTailArea=(Invariants(18)*ContinuousCharacteristics(3)*Sref)/ContinuousCharacteristics(1);
VerticalTailArea=(Invariants(19)*ContinuousCharacteristics(2)*Sref)/ContinuousCharacteristics(1);
HorizontalTailMass=HorizontalTailArea*Invariants(27);
VerticalTailMass=VerticalTailArea*Invariants(27);

%DETERMINING WING STRUCTURE MASS===========================================
%establishing variables in imperial units
AR=ContinuousCharacteristics(2)^2/Sref;
S_w=Sref*10.7639104;
w_fw=Invariants(16)*2*ContinuousCharacteristics(10)*0.00220462262;
A=AR;
LAMDA=0;
q=0.5*1.225*10^2*0.02089;
lamda=ContinuousCharacteristics(5)/ContinuousCharacteristics(3);
t=max(SplinedUpperProfileZ-SplinedLowerProfileZ)*3.2808399;
c=ContinuousCharacteristics(3)*3.2808399;
N_z=1.5;
W_dg=(Invariants(4)+Invariants(6)+Invariants(7)*ContinuousCharacteristics(1))*0.00220462262;

W_wing=0.036*S_w^0.758*w_fw^0.0035*(A/(cos(LAMDA)^2))^0.6*q^0.006*lamda^0.04*((100*t/c)/cos(LAMDA))^-0.3*(N_z*W_dg)^0.49;

%converting wing weight back to SI units
MassOfWing=W_wing*453.59237;

%SUMMING COMPONENT MASSES==================================================
SemiMass=...
    MassOfWing+...                                      %mass of the wing in grams
    2*(NumberOfSolarCellsOnWing*Invariants(11))+...     %mass of the solar cells on both wings in grams
    Invariants(4)+...                                   %mass of the payload in grams
    Invariants(6)+...                                   %mass of the neccessary fuselage in grams
    ContinuousCharacteristics(1)*Invariants(7)+...      %mass of the tail boom in grams
    HorizontalTailMass+...                              %mass of the horizontal stabilizer in grams
    VerticalTailMass;                                   %mass of the vertical stabilizer in grams

NumberOfatteryPacksInWing=0;
WingLoad=SemiMass/Sref;

while (WingLoad<Invariants(3))&&((2*NumberOfatteryPacksInWing)<ContinuousCharacteristics(10))
    NumberOfatteryPacksInWing=NumberOfatteryPacksInWing+1;
    WingLoad=(SemiMass+(2*NumberOfatteryPacksInWing*Invariants(16)))/Sref;
end

BatteryCoordinates=zeros(3,NumberOfatteryPacksInWing);

Mass=...
    SemiMass+...                                        %previously found aircraft semi-mass
    (2*NumberOfatteryPacksInWing*Invariants(16));       %mass of the battery packs in both wings