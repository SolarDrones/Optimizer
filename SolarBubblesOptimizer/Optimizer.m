%SolarSight Genetic Algorithm Optimizer Version 2.0
%By: Ryan Klock, 3/3/2012

%checking if program is being called as a result of a previous run's crash
if ~exist('FaultDetector','var')||FaultDetector==0;

    %PROGRAM INITIALIZATION================================================
    %clearing memory and command screen
    clear all;
    clc;

    %checking that current folder in Z:\
    CurrentFolder=pwd;
    if ~strcmp(CurrentFolder,'Z:\');
        disp('WARNING, THE CURRENT WORKING DIRECTORY IS NOT Z:\');
        disp('Due to the nature of this program, the working folder must be mapped');
        disp('to drive Z:\.  To do this, open your desktop computer folder, select');
        disp('Map Network Drive and enter in the working folder address.  Next, run');
        disp('Matlab out of the Current Folder of Z:\');

        pause on;
        pause;
        pause off;
    end;

    %USER INTERFACING======================================================
    %zzzSolarBubblesBlock();

    %fprintf('=====================================================================\n');
    %fprintf('Welcome to the Solar Bubbles genetic algorithm optimizer v2.0\nBy: Ryan Klock on Mar. 1, 2012\n');
    %fprintf('=====================================================================\n\n');

    PopulationSize=input('Please enter the desired population size to consider: ');
    Generations=input('Please enter the desired number of generations to consider: ');
    ContinuousMutationVolatility=input('Please enter the desired continuous mutations volatility: ');
    DiscreteMutationVolatility=input('Please enter the desired discrete mutations volatility: ');
    StopMutationsGeneration=input('Please enter the desired generation at which to stop mutations: ');

    %OPTIMIZATION INITIALIZATION===========================================
    fprintf('\nInitializing pre-run processes');

    %loading boundary conditions
    fprintf('\n    -Loading optimization subspace boundaries');
    [ContinuousMaximums,ContinuousMinimums,Invariants,DiscretePossibilities]=zzzBoundaryConditions();

    %loading initial conditions
    fprintf('\n    -Loading initial population characteristics');
    [InitialContinuousCharacteristics,InitialDiscreteCharacteristic]=zzzInitialConditions();

    %creating optimization history matrix
    fprintf('\n    -Establishing performance history matrix');
    PerformanceHistory=zeros(PopulationSize,Generations);

    %evaluating initial conditions performance
    fprintf('\nCharacterizing initial generation');
    [InitialEndurance,InitialDependantCharacteristics]=zzzCharacterizer(InitialContinuousCharacteristics,InitialDiscreteCharacteristic,Invariants);
    fprintf('\n    -Initial Aircraft Characteristics:');
    fprintf('\n        Aircraft mass:             %.0f g',InitialDependantCharacteristics(1));
    fprintf('\n        Number of battery packs:   %d',InitialDependantCharacteristics(2));
    fprintf('\n        Number of solar cells:     %d',InitialDependantCharacteristics(3));
    fprintf('\n        Cruising airspeed:         %.1f m/s',InitialDependantCharacteristics(4));
    fprintf('\n        Coefficient of lift:       %.3f',InitialDependantCharacteristics(5));
    fprintf('\n        Coefficient of drag:       %.3f',InitialDependantCharacteristics(6));
    fprintf('\n        Angle of attack:           %.0f deg',InitialDependantCharacteristics(7));
    fprintf('\n        Critical transition angle: %.0f deg',InitialDependantCharacteristics(8));
    fprintf('\n        Tip stall angle:           %.0f deg',InitialDependantCharacteristics(9));
    fprintf('\n        Drivetrain power:          %.1f W',InitialDependantCharacteristics(10));
    fprintf('\n        Endurance:                 %.1f hours',InitialEndurance/3600);


    %distributing intial conditions to population
    fprintf('\n    -Disbursing intial conditions to population members');
    Endurance=ones(PopulationSize,1)*InitialEndurance;

    %CHECK THE DIMENSIONS OF THIS ARRAY (size(InitialContinuousCharacteristics,2) = 10)
    ContinuousCharacteristics=zeros(PopulationSize,size(InitialContinuousCharacteristics,2));

    DependantCharacteristics=zeros(PopulationSize,10);
    for i=(1:1:PopulationSize)
        ContinuousCharacteristics(i,:)=InitialContinuousCharacteristics;
        DiscreteCharacteristic(i)=InitialDiscreteCharacteristic;
        DependantCharacteristics(i,:)=InitialDependantCharacteristics;
    end

    %recording performance history
    fprintf('\n    -Recording intial endurance to performance history');
    PerformanceHistory(:,1)=Endurance;

    %initializing generation counter
    fprintf('\n    -Initializing generation counter');
    StartingGeneration=1;

    %alerting user of the start of optimization
    fprintf('\nBeginning optimization\n');

%==================UNEEDED==========================================
elseif FaultDetector==1
    %fault recovery alert notice and reload of the subspace boundaries
    fprintf('\n--------------------------------------------------------------------------------');
    fprintf('\nFault Recovery Success at Generation %d',StartingGeneration);
    fprintf('\n--------------------------------------------------------------------------------');
    [ContinuousMaximums,ContinuousMinimums,Invariants,DiscretePossibilities]=zzzBoundaryConditions();
    FaultDetector=0;
elseif FaultDetector==2
    %received loaded saved parameters
    fprintf('\n--------------------------------------------------------------------------------');
    fprintf('\nFile Load Success at Generation %d',StartingGeneration);
    fprintf('\n--------------------------------------------------------------------------------\n');
    [ContinuousMaximums,ContinuousMinimums,Invariants,DiscretePossibilities]=zzzBoundaryConditions();
    Generations=input('Please enter the desired number of additional generations: ');
    StopMutationsGeneration=input('Please enter the desired generation to hault mutations: ');
    FaultDetector=0;
end
%==================UNEEDED==========================================

%====================================================================================================
%PORTED TO THIS POINT
%====================================================================================================


for CurrentGeneration=(StartingGeneration:1:Generations)
%     try
        %determining offspring generation scheme
        if CurrentGeneration>=StopMutationsGeneration
            OffspringScheme='pro';
        else
            OffspringScheme='all';
        end

        %generating offspring
        [ContinuousCharacteristics,DiscreteCharacteristic]=zzzOffspringGenerator(Endurance,ContinuousCharacteristics,DiscreteCharacteristic,DiscretePossibilities,ContinuousMaximums,ContinuousMinimums,1,0.2,OffspringScheme);

        %characterizing offspring
        [Endurance,DependantCharacteristics]=zzzCharacterizer(ContinuousCharacteristics,DiscreteCharacteristic,Invariants);

        %recording performance history
        PerformanceHistory(:,CurrentGeneration+1)=Endurance;


        %=============UNNEEDED=================
        %rendering user interface
        zzzRender(ContinuousCharacteristics,DiscreteCharacteristic,PerformanceHistory,DependantCharacteristics,Invariants);
        %=============UNNEEDED=================


        %saving current parameters to file
        zzzSave('CurrentSave.txt',ContinuousCharacteristics,DiscreteCharacteristic,Endurance,DependantCharacteristics,PerformanceHistory,CurrentGeneration,Invariants,Generations)

%     catch ErrorCode
%         %initializing fault recovery actions
%         disp(ErrorCode);
%         FaultDetector=1;
%         StartingGeneration=CurrentGeneration;
%         run Optimizer;
%     end
end
