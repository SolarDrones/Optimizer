function [CLs,CDs,Stall]=zzzAerodynamics_PolarReader(Filename)

%This function parses the output drag polar file from XFoil for the SolarSight Genetic Algorithm Optimization V2.0
%By Ryan Klock, 3/7/2012

%extracting file contents to string
FileStream=fileread(Filename);

%searching and extracting for critical stall angle
for i=(1:1:length(FileStream))
    if strcmp(FileStream(i:i+8),'Ncrit =  ')
        Stall=str2num(FileStream(i+10:i+14));
        FileStream(1:i+14)=[];
        break
    end
end

try
    %trimming column headers
    for i=(1:1:length(FileStream))
        if regexp(FileStream(i),'\d')
            FileStream(1:i-1)=[];
            break
        end
    end

    %extracting CL and CD values
    HolderMatrix=str2num(FileStream);
    while isempty(HolderMatrix)
        FileStream(1)=[];
        HolderMatrix=str2num(FileStream);
    end
    CLs=HolderMatrix(:,2);
    CDs=HolderMatrix(:,3);

    %transposing vectors
    CLs=CLs';
    CDs=CDs';
    
catch ErrorCode
    %if drag polar file is empty, then a null result is returned
    CLs=0;
    CDs=0;
    
    %notifying user of empty drag polar
    fprintf('\n***error: drag polar file empty***\n');
    disp(ErrorCode);
end