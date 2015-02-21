function [DrivePowerConsumption]...
    =zzzDrivetrain...
    (ContinuousCharacteristics,Invariants,CD,CruiseSpeed)

%This function determines the power consumption of the drivetrain subsystem while the aircraft is at steady level cruise.
%By Ryan Klock, 3/7/2012

DrivetrainEfficiency=0.58;      %assumed fractional efficiency of the overall drivetrain subsystem

Sref=(ContinuousCharacteristics(2)-ContinuousCharacteristics(2)*ContinuousCharacteristics(4))*ContinuousCharacteristics(3)+2*(.5*((ContinuousCharacteristics(2)/2)*ContinuousCharacteristics(4))*(ContinuousCharacteristics(3)+ContinuousCharacteristics(5)));
Drag=CD*0.5*1.225*CruiseSpeed^2*Sref;

%checking that required thrust does not exceed the maximum static thrust at takeoff
if Drag>Invariants(2)
    fprintf('\n***error: thrust required at cruise exceeds maximum static thrust at takeoff***\n');
end

%calculating power consumption by the drivetrain subsystem
DrivePowerConsumption=(Drag*CruiseSpeed)/DrivetrainEfficiency;