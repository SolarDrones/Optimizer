function [ContinuousCharacteristics,DiscreteCharacteristic,Endurance,DependantCharacteristics,PerformanceHistory,CurrentGeneration,Invariants,Generations]=...
    zzzLoad(Filename)

Holder=fileread(Filename);

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        ContinuousCharacteristics=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end


for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
       SubHolder=Holder(1:i-1);
       LineCount=1;
       Index=1;
       while Index<=length(SubHolder)
           if strcmp(SubHolder(Index),';')
               DiscreteCharacteristic(LineCount,1)={SubHolder(1:Index-2)};
               SubHolder(1:Index)=[];
               LineCount=LineCount+1;
               Index=0;
           end
           Index=Index+1;
       end
       Holder(1:i)=[];
       break
    end
end


for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        Endurance=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        DependantCharacteristics=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        PerformanceHistory=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        CurrentGeneration=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        Invariants=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end

for i=(1:1:length(Holder))
    if strcmp(Holder(i),'#')
        Generations=str2num(Holder(1:i-1));
        Holder(1:i)=[];
        break
    end
end