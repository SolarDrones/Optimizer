function zzzRender(ContinuousCharacteristics,DiscreteCharacteristic,PerformanceHistory,DependantCharacteristics,Invariants)

%This function renders the performance history and aircraft geometries for the SolarSight Genetic Algorithm Optimizer V2.0
%By Ryan Klock, 3/7/2012

clf;
pause on;

%PLOTTING PERFORMANCE HISTORY==============================================
%determining index of unfilled elements in the performance history matrix
for i=(1:1:size(PerformanceHistory,2))
    if PerformanceHistory(1,i)==0
        break
    end
end

%plotting the performance history
subplot(3,size(ContinuousCharacteristics,1),1:size(ContinuousCharacteristics,1))
plot(0:i-2,PerformanceHistory(:,1:i-1)./3600,'-o');
title('Endurance History','FontWeight','bold');
xlabel('Generation number');
ylabel('Endurnace (hours)');

%RENDERING AIRCRAFT GEOMETRIES=============================================
%converting to older function language
Char(:,1)=ContinuousCharacteristics(:,1);
Char(:,3)=ContinuousCharacteristics(:,2);
Char(:,4)=ContinuousCharacteristics(:,3);
Char(:,5)=ContinuousCharacteristics(:,4)*100;
Char(:,6)=ContinuousCharacteristics(:,5);
Char(:,7)=ContinuousCharacteristics(:,6);
Char(:,9)=ContinuousCharacteristics(:,8);
Char(:,11)=ContinuousCharacteristics(:,9);

Lineages=size(ContinuousCharacteristics,1);
HorzTailCoeff=Invariants(18);
VertTailCoeff=Invariants(19);

%passing converted parameters to older function
for i=(1:1:size(ContinuousCharacteristics,1))
    PlotNum=size(ContinuousCharacteristics,1)+i;
    Title=['Aircraft ' num2str(i)];
    Airfoil=char(DiscreteCharacteristic(i));
    zzzGeometryPlotter(Char,i,PlotNum,Lineages,Title,HorzTailCoeff,VertTailCoeff,Airfoil);
end

%ANNOTING AIRCRAFT CHARACTERISTICS=========================================
%Caution: Men At Work

pause(0.001);
pause off;