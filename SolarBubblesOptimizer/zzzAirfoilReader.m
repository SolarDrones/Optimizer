%FULLY PORTED

function [xWingFoil,zWingFoil]=zzzAirfoilReader(DiscreteCharacteristic)

%This function opens and reads airfoil profile data files
%By Ryan Klock, 3/6/2012

%opening airfoil profile data file
try
    AirfoilFile=fileread([char(DiscreteCharacteristic) '.dat']);
catch ErrorCode
    fprintf('\n***error: failed to open airfoil profile data file %s.dat***\n',char(DiscreteCharacteristic));
    disp(ErrorCode);
end

%removing title line from string
for i=(1:1:length(AirfoilFile))
    if regexp(AirfoilFile(i),'\n')
        AirfoilFile(1:i)=[];
        break
    end
end

%extracting numeric data from file string
Holder='';
for i=(1:1:length(AirfoilFile))
    if regexp(AirfoilFile(i),'\d')
        Holder=[Holder AirfoilFile(i)];
    elseif regexp(AirfoilFile(i),'\.')
        Holder=[Holder AirfoilFile(i)];
    elseif regexp(AirfoilFile(i),'-')
        Holder=[Holder AirfoilFile(i)];
    elseif regexp(AirfoilFile(i),'\n')
        Holder=[Holder ';'];
    else
        Holder=[Holder ' '];
    end;
end

%converting file string to numerals for output
xzValues=str2num(Holder);
xWingFoil=xzValues(:,1);
zWingFoil=xzValues(:,2);
xWingFoil=xWingFoil';
zWingFoil=zWingFoil';
