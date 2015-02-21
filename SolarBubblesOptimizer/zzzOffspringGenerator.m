%PORTED

function [OffspringContinuousCharacteristics,OffspringDiscreteCharacteristic]...
    =zzzOffspringGenerator(...
    FiguresOfMerit,ContinuousCharacteristics,DiscreteCharacteristic,...
    DiscretePossibilities,ContinuousMaximums,ContinuousMinimums,...
    ContinuousMutationVolatility,DiscreteMutationVolatility,Mode)

%This function generates offspring characteristics from parent characteristics based upon figures of merit and quasi-random mutations to simulate the process of genetic evolution.
%By Ryan Klock, 3/3/2011

%PREPROCESSING=============================================================
if (strcmp(Mode,'all')||strcmp(Mode,'pro'))
    %creating index list of parents based on figures of merit
    MeritHolder=FiguresOfMerit;
    MeritIndex=zeros(1,length(FiguresOfMerit));
    CheckValue=min(FiguresOfMerit)-1;
    for i=(1:1:length(FiguresOfMerit))
        [~,index]=max(MeritHolder);
        MeritIndex(i)=index;
        MeritHolder(index)=CheckValue;
    end

    %creating offspring characteristics holder matrices
    OffspringContinuousCharacteristics=zeros(size(ContinuousCharacteristics));
 

%++++++++++ONLY USING THIS CASE ++++++++++++++++++++++++++++++++++++++++    
elseif strcmp(Mode,'mut')
    %creating offspring as direct copies from parents
    OffspringContinuousCharacteristics=ContinuousCharacteristics;
    OffspringDiscreteCharacteristic=DiscreteCharacteristic;
    
else
    fprintf('\n***error: unknown mode entered to offspring generator***\n');
end



%GENERATING OFFSPRING FROM PARENTS BASED ON FIGURES OF MERIT===============
if (strcmp(Mode,'all')||strcmp(Mode,'pro'))
    %extrapolating single offspring from top two parents
    OffspringContinuousCharacteristics(1,:)=ContinuousCharacteristics(MeritIndex(1),:)+0.5*(ContinuousCharacteristics(MeritIndex(1),:)-ContinuousCharacteristics(MeritIndex(2),:));
    OffspringDiscreteCharacteristic(1,1)=DiscreteCharacteristic(MeritIndex(1));

    %interpolating remaining offspring from parents
    for i=(2:1:length(FiguresOfMerit))
        OffspringContinuousCharacteristics(i,:)=ContinuousCharacteristics(MeritIndex(i-1),:)-0.5*(ContinuousCharacteristics(MeritIndex(i-1),:)-ContinuousCharacteristics(MeritIndex(i),:));
        OffspringDiscreteCharacteristic(i,1)=DiscreteCharacteristic(MeritIndex(i-1));
    end
end

%CHECKING CONTINUOUS CHARACTERISTIC BOUNDARIES=============================
for i=(1:1:size(OffspringContinuousCharacteristics,1))
    for j=(1:1:size(OffspringContinuousCharacteristics,2))
        if OffspringContinuousCharacteristics(i,j)>ContinuousMaximums(j)
            OffspringContinuousCharacteristics(i,j)=ContinuousMaximums(j);
        elseif OffspringContinuousCharacteristics(i,j)<ContinuousMinimums(j)
            OffspringContinuousCharacteristics(i,j)=ContinuousMinimums(j);
        end
    end
end

%INDUCING MUTATIONS IN OFFSPRING===========================================
if (strcmp(Mode,'all')||strcmp(Mode,'mut'))
    %inducing continuous characteristic mutations
    for i=(1:1:size(OffspringContinuousCharacteristics,1))
        for j=(1:1:floor(exprnd(ContinuousMutationVolatility)))
            MutateIndex=unidrnd(size(OffspringContinuousCharacteristics,2),1);
            OffspringContinuousCharacteristics(i,MutateIndex)=ContinuousMinimums(MutateIndex)+rand*(ContinuousMaximums(MutateIndex)-ContinuousMinimums(MutateIndex));
        end
    end

    %inducing discrete characteristic mutations
    for i=(1:1:size(OffspringDiscreteCharacteristic,1))
        if 0<floor(exprnd(DiscreteMutationVolatility))
            DiscreteMutationPossibilityIndex=unidrnd(size(DiscretePossibilities,1));
            OffspringDiscreteCharacteristic(i)=DiscretePossibilities(DiscreteMutationPossibilityIndex);
        end
    end
end

%Add mutations to the continuous characteristics
%Add mutations to the discrete characteristic
%Check the mutations against the boundry condition