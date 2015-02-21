function [CruiseSpeed,CL,CD,AngleOfAttack,StallAngle]...
    =zzzAerodynamics...
    (ContinuousCharacteristics,DiscreteCharacteristic,Invariants,Mass)

%This function determines the aerodynamic characteristic of a given aircraft for the SolarSight Genetic Algorithm Optimizer V2.0
%By Ryan Klock, 3/6/2012

%GENERATING DRAG POLAR FOR AIRFOIL=========================================
%deleting old polar files
delete CurrentWingPolar.pol;
delete CurrentTipPolar.pol;

%calculating Reyolds Number (10m/s characteristic speed, current chord is characteristic length, kinemaitc viscosity of air at 70F and 1 atm(source: Wolfram Alpha))
Sref=(ContinuousCharacteristics(2)-ContinuousCharacteristics(2)*ContinuousCharacteristics(4))*ContinuousCharacteristics(3)+2*(.5*((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))*(ContinuousCharacteristics(3)+ContinuousCharacteristics(5)));
WingReynoldsNumber=(10*ContinuousCharacteristics(3))/(1.478e-5);
TipReynoldsNumber=(10*ContinuousCharacteristics(5))/(1.478e-5);

%creating run file for XFoil
try
    XFoilWingRun=fopen('XFoilWingRun.run','w');
    XFoilTipRun=fopen('XFoilTipRun.run','w');
catch ErrorCode
    fprintf('\n***error: failed to open XFoilWingRun.run or XFoilTipRun.run in zzzAerodynamics function, retrying***\n');
    disp(ErrorCode);
    XFoilWingRun=fopen('XFoilWingRun.run','w');
    XFoilTipRun=fopen('XFoilTipRun.run','w');
end

%=======================================================================================================
%FIX THE PARSING PROBLEMS
%=======================================================================================================

%writing untapered wing section analysis run
fprintf(XFoilWingRun,'load %s.dat\n',char(DiscreteCharacteristic));
fprintf(XFoilWingRun,'pane\n');
fprintf(XFoilWingRun,'oper\n');
fprintf(XFoilWingRun,'visc\n');
fprintf(XFoilWingRun,'%s\n',num2str(WingReynoldsNumber));
fprintf(XFoilWingRun,'vpar\n');
fprintf(XFoilWingRun,'n\n');
fprintf(XFoilWingRun,'11\n\n');
fprintf(XFoilWingRun,'p\n');
fprintf(XFoilWingRun,'CurrentWingPolar.pol\n');
fprintf(XFoilWingRun,'\n');
fprintf(XFoilWingRun,'aseq -2 10 .5\n');
fprintf(XFoilWingRun,'\n');
fprintf(XFoilWingRun,'quit\n');

fclose(XFoilWingRun);

%writing wing tip analysis run for interpolation along tapered section
fprintf(XFoilTipRun,'load %s.dat\n',char(DiscreteCharacteristic));
fprintf(XFoilTipRun,'pane\n');
fprintf(XFoilTipRun,'oper\n');
fprintf(XFoilTipRun,'visc\n');
fprintf(XFoilTipRun,'%s\n',num2str(TipReynoldsNumber));
fprintf(XFoilTipRun,'vpar\n');
fprintf(XFoilTipRun,'n\n');
fprintf(XFoilTipRun,'11\n\n');
fprintf(XFoilTipRun,'p\n');
fprintf(XFoilTipRun,'CurrentTipPolar.pol\n');
fprintf(XFoilTipRun,'\n');
fprintf(XFoilTipRun,'aseq -2 10 .5\n');
fprintf(XFoilTipRun,'\n');
fprintf(XFoilTipRun,'quit\n');

fclose(XFoilTipRun);

%running XFoil for wing midsection drag polar
[status,~]=dos('Z:\xfoilP4.exe < .\XFoilWingRun.run');
if status~=0;
    fprintf('\n***XFoild crash detected while running XFoilWingRun.run***\n');
end;

%running XFoil for wing tip drag polar
[status,~]=dos('Z:\xfoilP4.exe < .\XFoilTipRun.run');
if status~=0;
    fprintf('\n***XFoild crash detected while running XFoilTipRun.run***\n');
end;

%extracting drag polars and stall angles from XFoil outputted files
[WingCLs,WingCDs,WingStall]=zzzAerodynamics_PolarReader('CurrentWingPolar.pol');
[TipCLs,TipCDs,TipStall]=zzzAerodynamics_PolarReader('CurrentTipPolar.pol');
StallAngle=[WingStall TipStall];

%determining parabolic drag polars centered on the sectional maximum lift to drag ratio
WingLDs=WingCLs./WingCDs;
[~,MaxRatioIndex]=max(WingLDs);

if length(WingLDs)>=3
    if MaxRatioIndex==1
        MaxRatioIndex=2;
    elseif MaxRatioIndex==length(WingLDs)
        MaxRatioIndex=length(WingLDs)-1;
    end
    avlWingCLs=WingCLs(MaxRatioIndex-1:MaxRatioIndex+1);
    avlWingCDs=WingCDs(MaxRatioIndex-1:MaxRatioIndex+1);
    WingDragPolarEstablished=1;
else
    WingDragPolarEstablished=0;
end

TipLDs=TipCLs./TipCDs;
[~,MaxRatioIndex]=max(TipLDs);

if length(TipLDs)>=3
    if MaxRatioIndex==1
        MaxRatioIndex=2;
    elseif MaxRatioIndex==length(TipLDs)
        MaxRatioIndex=length(TipLDs)-1;
    end
    avlTipCLs=TipCLs(MaxRatioIndex-1:MaxRatioIndex+1);
    avlTipCDs=TipCDs(MaxRatioIndex-1:MaxRatioIndex+1);
    TipDragPolarEstablished=1;
else
    TipDragPolarEstablished=0;
end

%DETERMINING MAXIMUM LIFT TO DRAG RATIO FOR AIRCRAFT=======================
%determining tail span and height
HorizontalTailArea=(Invariants(18)*ContinuousCharacteristics(3)*Sref)/ContinuousCharacteristics(1);
VerticalTailArea=(Invariants(19)*ContinuousCharacteristics(2)*Sref)/ContinuousCharacteristics(1);
CurrentHorzTailSpan=HorizontalTailArea/ContinuousCharacteristics(8);
CurrentVertTailHeight=VerticalTailArea/ContinuousCharacteristics(9);

%creating .fsl fuselage file
try
    fdat=fopen('Current.fsl','w');
catch ErrorInfo
    fdat=fopen('Current.fsl','w');
    warning(ErrorInfo);
end;

fprintf(fdat,'CurrentOptimizationItterationFuselage\n');
fprintf(fdat,'%.2f 0\n',(ContinuousCharacteristics(3)+ContinuousCharacteristics(1)));
fprintf(fdat,'%.2f -0.04\n',(ContinuousCharacteristics(3)+0.25));
fprintf(fdat,'%.2f -0.04\n',(0.25));
fprintf(fdat,'0 0\n');
fprintf(fdat,'%.2f 0.04\n',(0.25));
fprintf(fdat,'%.2f 0.04\n',(ContinuousCharacteristics(3)+0.25));
fprintf(fdat,'%.2f 0\n',(ContinuousCharacteristics(3)+ContinuousCharacteristics(1)));

fclose(fdat);

%creating .avl file
try
    favl=fopen('Current.avl','w');
catch ErrorInfo
    favl=fopen('Current.avl','w');
    warning(ErrorInfo);
end;
    
%file header information
fprintf(favl,'CurrentOptimizationItteration\n\n');

fprintf(favl,'#This file is computer generated for the purpose of determining the drag polar of an aircraft\n\n');

fprintf(favl,'#Mach\n0.026\n');%Assumed approx 10 m/s at sea level
fprintf(favl,'#iYsym iZsym Zsym\n0 0 0\n');
Sref=(ContinuousCharacteristics(2)-ContinuousCharacteristics(2)*ContinuousCharacteristics(4))*ContinuousCharacteristics(3)+2*(.5*((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))*(ContinuousCharacteristics(3)+ContinuousCharacteristics(5)));
fprintf(favl,'#Sref Cref Bref\n%f %f %f\n',Sref,ContinuousCharacteristics(3),ContinuousCharacteristics(2));
fprintf(favl,'#Xref Yref Zref\n0 0 0\n');
fprintf(favl,'#CDp\n0.02\n');%Assumed comparable to Lockheed Constellation, http://en.wikipedia.org/wiki/Zero-lift_drag_coefficient
fprintf(favl,'#------------------------------------------------------------\n');

%fuselage information
fprintf(favl,'BODY\n');
fprintf(favl,'Fuselage\n');
fprintf(favl,'100 1.0\n\n');

fprintf(favl,'TRANSLATE\n');
fprintf(favl,'-0.25 0 -0.04\n\n');

fprintf(favl,'BFILE\n');
fprintf(favl,'Current.fsl\n\n');

fprintf(favl,'#------------------------------------------------------------\n');

%main wing information
fprintf(favl,'SURFACE\n');
fprintf(favl,'Main Wing\n\n');

fprintf(favl,'#Nchord Cspace Nspan Sspace\n');
fprintf(favl,'12 1.0 20 -2.0\n\n');

fprintf(favl,'YDUPLICATE\n');
fprintf(favl,'0.0\n\n');

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'0 0 0 %f 0\n\n',ContinuousCharacteristics(3));

fprintf(favl,'AFILE\n');
fprintf(favl,'%s.dat\n\n',char(DiscreteCharacteristic));

if WingDragPolarEstablished&&TipDragPolarEstablished
    fprintf(favl,'CDCL\n');
    fprintf(favl,'%f %f %f %f %f %f\n\n',avlWingCLs(1),avlWingCDs(1),avlWingCLs(2),avlWingCDs(2),avlWingCLs(3),avlWingCDs(3));
end

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'0 %f 0 %f 0\n\n',((ContinuousCharacteristics(2)/2)-((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))),ContinuousCharacteristics(3));

fprintf(favl,'AFILE\n');
fprintf(favl,'%s.dat\n\n',char(DiscreteCharacteristic));

if WingDragPolarEstablished&&TipDragPolarEstablished
    fprintf(favl,'CDCL\n');
    fprintf(favl,'%f %f %f %f %f %f\n\n',avlWingCLs(1),avlWingCDs(1),avlWingCLs(2),avlWingCDs(2),avlWingCLs(3),avlWingCDs(3));
end

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'0 %f %f %f %f\n\n',(ContinuousCharacteristics(2)/2),(((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))*tan(ContinuousCharacteristics(6)*pi/180)),ContinuousCharacteristics(5),ContinuousCharacteristics(7));

fprintf(favl,'AFILE\n');
fprintf(favl,'%s.dat\n\n',char(DiscreteCharacteristic));

if TipDragPolarEstablished&&WingDragPolarEstablished
    fprintf(favl,'CDCL\n');
    fprintf(favl,'%f %f %f %f %f %f\n\n',avlTipCLs(1),avlTipCDs(1),avlTipCLs(2),avlTipCDs(2),avlTipCLs(3),avlTipCDs(3));
end

fprintf(favl,'#------------------------------------------------------------\n');

%horizontal tail information
fprintf(favl,'SURFACE\n');
fprintf(favl,'Horizontal stabilizer\n\n');

fprintf(favl,'#Nchord Cspace Nspan Sspace\n');
fprintf(favl,'5 1.0 5 -2.0\n\n');

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'%f 0 0 %f 0\n\n',(ContinuousCharacteristics(1)+ContinuousCharacteristics(3)), ContinuousCharacteristics(8));

fprintf(favl,'NACA\n');
fprintf(favl,'0012\n\n');

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'%f %f 0 %f 0\n\n',(ContinuousCharacteristics(1)+ContinuousCharacteristics(3)), (CurrentHorzTailSpan/2), ContinuousCharacteristics(8));

fprintf(favl,'NACA\n');
fprintf(favl,'0012\n\n');

fprintf(favl,'YDUPLICATE\n');
fprintf(favl,'0.0\n\n');

fprintf(favl,'#------------------------------------------------------------\n');

%vertical tail information
fprintf(favl,'SURFACE\n');
fprintf(favl,'Vertical stabilizer\n\n');

fprintf(favl,'#Nchord Cspace Nspan Sspace\n');
fprintf(favl,'5 1.0 5 -2.0\n\n');

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'%f 0 %f %f 0\n\n',(ContinuousCharacteristics(1)+ContinuousCharacteristics(3)), (-CurrentVertTailHeight/2), ContinuousCharacteristics(9));

fprintf(favl,'NACA\n');
fprintf(favl,'0012\n\n');

fprintf(favl,'SECTION\n');
fprintf(favl,'#Xle Yle Zle Chord Ainc\n');
fprintf(favl,'%f 0 %f %f 0\n\n',(ContinuousCharacteristics(1)+ContinuousCharacteristics(3)), (CurrentVertTailHeight/2), ContinuousCharacteristics(9));

fprintf(favl,'NACA\n');
fprintf(favl,'0012\n\n');

fprintf(favl,'#------------------------------------------------------------\n');

%closing .avl file
fclose(favl);

BestLDratio=0;
BestCL=0;
BestCD=999;
for CurrentAlpha=(0:1:15);
    %Creating .run file
    try
        frun=fopen('Current.run','w');
    catch ErrorInfo
        frun=fopen('Current.run','w');
        warning(ErrorInfo);
    end;

    fprintf(frun,'LOAD Current.avl\n');%loads file
    fprintf(frun,'PLOP\ng\n\n');%disbles avl graphics
    fprintf(frun,'OPER\n');%opens operation menu
%     fprintf(frun,'g\n');%opens geometry rendering (part of displaying geometry if desired)
%     fprintf(frun,'ca\n');%adds camber lines (part of displaying geometry if desired)
%     fprintf(frun,'\n');%returns to operation menu (part of displaying geometry if desired)
    fprintf(frun,'c1\n');%opens level case constraints
    fprintf(frun,'v\n10\n');%sets cruise speed to 10m/s
    fprintf(frun,'d\n1.225\n');%sets air density to 1.225kg/m^3
    fprintf(frun,'g\n9.81\n');%sets gravitational acceleration to 9.81m/s^2
    fprintf(frun,'\n');%returns to operation menu
    fprintf(frun,'a\n');%opens constraints menu for alpha
    fprintf(frun,'a\n');%selects alpha as new constraint
    fprintf(frun,'%f\n',CurrentAlpha);%sets alpha to be constrained to the current itteraion's alpha value

    fprintf(frun,'x\n');%runs case

%     fprintf(frun,'t\n');%opens Trefftz plane (part of displaying geometry if desired)
    fprintf(frun,'\n');%returns to operations menu
    fprintf(frun,'\nq\n');%closes avl

    %Closing the .run file
    fclose(frun);
    
    %Executing AVL case run
    [status,output]=dos('Z:\avl.exe < .\Current.run');
    
    if status~=0;
        fprintf('\n***AVL crash detected***\n')
    end;
    
    CLindex=strfind(output,'CLtot =');
    CDindex=strfind(output,'CDtot =');
    CL=str2num(output(CLindex+7:CLindex+17));
    CD=str2num(output(CDindex+7:CDindex+17));
    try%//////////////////////////////
        LDratio=CL/CD;
    catch ErrorCode%//////////////////
        output%///////////////////////
        DiscreteCharacteristic%///////
        CL%///////////////////
        CD%///////////////////
        LDratio=CL/CD;%///////////////
    end%//////////////////////////////
    
    if LDratio>BestLDratio;
        BestLDratio=LDratio;
        BestCL=CL;
        BestCD=CD;
    else
        break;
    end;
end

CruiseSpeed=Invariants(28)*sqrt((2*(Mass/1000)*9.81)/(BestCL*1.225*Sref));
CL=BestCL;
CD=BestCD;
AngleOfAttack=CurrentAlpha-1;%subtracting extra itteration of the optimum angle of attack finder loop

% if AngleOfAttack>StallAngle(1)
%     fprintf('\n***error: optimal angle of attack exceeds airfoil sectional stall angle***\n');
% elseif AngleOfAttack>StallAngle(2)
%     fprintf('\n***error: optimal angle of attack exceeds sectional tip stall angle***\n');
% end