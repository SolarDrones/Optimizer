function [Endurance]...
    =zzzPower...
    (DrivePowerConsumption,Invariants,BatteryCoordinates,SolarCellCoordinates)

%This function determines the power characteristics and flight endurance of an aircraft for the SolarSight Genetic Algorithm Optimizer V2.0
%By Ryan Klock, 3/7/2012

%PREPROCESS OPERATIONS=====================================================
NumberOfBatteryPacks=2*size(BatteryCoordinates,2);
NumberOfSolarCells=2*size(SolarCellCoordinates,2);
Timestep=Invariants(29);

Endurance=0;
StillFlying=1;
DayCount=0;                 %Starting flight of morning of first day

MaxDayCount=5;              %Number of days of sun to simulate before "blackout endurance" (days)
MaxDayCount=MaxDayCount-1;  %Correction for starting on the 0th day

PeakSunlight=650;           %Sunlight energy with sun directly above (W/m^2)
                            %(assuming sinusiodal sun motion)
                            %(roughly 500 in summer, 83 in winter for MI)

%Calculating starting energy (assuming start with full charge on batteries)
Energy=NumberOfBatteryPacks*Invariants(17);

%ENDURANCE SIMULATION======================================================
while StillFlying;
    %Calculating energy loss
    Energy=Energy-...
        Timestep*(DrivePowerConsumption+...
            Invariants(5)+...
            Invariants(8));
    
    %Calculating number of days past
    DayCount=floor(Endurance/(24*60*60));
    
    %Calculating energy gain
    if DayCount<=MaxDayCount;
        if (sin(Endurance*pi/(12*60*60)))>0;
            Energy=Energy+...
                (PeakSunlight*sin(Endurance*pi/(12*60*60))*NumberOfSolarCells*Invariants(12)*Invariants(9)*Invariants(10)*Timestep);
        end;
    end;
    
    %Checking if battery capacity exceeded
    if Energy>NumberOfBatteryPacks*Invariants(17);
        Energy=NumberOfBatteryPacks*Invariants(17);
    end;
    
    %Checking if aircraft still flying
    if Energy<=0;
        StillFlying=0;
    end;
    
    DayCount=floor(Endurance/(24*60*60));
    Endurance=Endurance+Timestep;    
end;