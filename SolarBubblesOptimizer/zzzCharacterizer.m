function [Endurance,DependantCharacteristics]...
    =zzzCharacterizer...
    (ContinuousCharacteristics,DiscreteCharacteristic,Invariants)

Endurance=zeros(size(ContinuousCharacteristics,1),1);
DependantCharacteristics=zeros(size(ContinuousCharacteristics,1),10);

for i=(1:1:size(ContinuousCharacteristics,1))
    %calculating structural properties of aircraft
    [Mass,BatteryCoordinates,SolarCellCoordinates]=zzzStructures(ContinuousCharacteristics(i,:),DiscreteCharacteristic(i,:),Invariants);
    NumberOfBatteryPacks=2*size(BatteryCoordinates,2);
    NumberOfSolarCells=2*size(SolarCellCoordinates,2);
    
    %calculating aerodynamic properties of the aircraft
    [CruiseSpeed,CL,CD,AngleOfAttack,StallAngle]=zzzAerodynamics(ContinuousCharacteristics(i,:),DiscreteCharacteristic(i,:),Invariants,Mass);
    WingStall=StallAngle(1);
    TipStall=StallAngle(2);
    
    %calculating the drive power required at cruise
    [DrivePowerConsumption]=zzzDrivetrain(ContinuousCharacteristics(i,:),Invariants,CD,CruiseSpeed);
    
    %calculating endurance of the aircraft
    [Endurance(i)]=zzzPower(DrivePowerConsumption,Invariants,BatteryCoordinates,SolarCellCoordinates);
    
    %entering dependant characteristics into storage matrix
    DependantCharacteristics(i,:)=[Mass NumberOfBatteryPacks NumberOfSolarCells CruiseSpeed CL CD AngleOfAttack WingStall TipStall DrivePowerConsumption];
end