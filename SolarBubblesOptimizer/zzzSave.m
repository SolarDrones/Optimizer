function zzzSave(Filename,ContinuousCharacteristics,DiscreteCharacteristic,Endurance,DependantCharacteristics,PerformanceHistory,CurrentGeneration,Invariants,Generations)

%This function saves the parameters of the SolarSight Genetic Optimization Code V2.0
%By Ryan Klock, 3/10/2012

SaveFile=fopen(Filename,'w');

[row,col]=size(ContinuousCharacteristics);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(ContinuousCharacteristics(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(DiscreteCharacteristic);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',char(DiscreteCharacteristic(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(Endurance);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(Endurance(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(DependantCharacteristics);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(DependantCharacteristics(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(PerformanceHistory);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(PerformanceHistory(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(CurrentGeneration);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(CurrentGeneration(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(Invariants);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(Invariants(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');

[row,col]=size(Generations);
for i=(1:1:row)
    for j=(1:1:col)
        fprintf(SaveFile,'%s,',num2str(Generations(i,j)));
    end
    fprintf(SaveFile,';');
end
fprintf(SaveFile,'#');