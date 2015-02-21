function zzzGeometryPlotter(Char,i,PlotNum,Lineages,Title,HorzTailCoeff,VertTailCoeff,Airfoil)

%Plotting fuselage===============================
subplot(3,Lineages,PlotNum);
axis equal;
hold on;
title(Title,'FontWeight','bold');
RingSpacing=0.05;
FuseRad=0.09;
ConeLen=0.25;
t=[1:10:360];
x=[-ConeLen:RingSpacing:0 0:RingSpacing:Char(i,4) Char(i,4):RingSpacing:(Char(i,4)+Char(i,1))];
for j=(1:1:length([-ConeLen:RingSpacing:0]));
    LocalRad=sqrt(FuseRad^2*(1-(x(j)^2/ConeLen^2)));
    z=[cos(t*(pi/180))].*LocalRad;
    y=[sin(t*(pi/180))].*LocalRad;
    plot3((ones(1,length(z))*x(j)),y,z);
end;
for j=(length([-ConeLen:RingSpacing:0])+1:1:length([0:RingSpacing:Char(i,4)]));
    LocalRad=FuseRad;
    z=[cos(t*(pi/180))].*LocalRad;
    y=[sin(t*(pi/180))].*LocalRad;
    plot3((ones(1,length(z))*x(j)),y,z);
end;
count=1;
for j=(length([0:RingSpacing:Char(i,4)])+1:1:length(x));
    LocalRad=FuseRad-FuseRad*(count/length(x));
    count=count+1;
    z=[cos(t*(pi/180))].*LocalRad;
    y=[sin(t*(pi/180))].*LocalRad;
    plot3((ones(1,length(z))*x(j)),y,z);
end;

%Plotting Wing===================================
RibSpacing=0.1;
[xWingFoil,zWingFoil]=zzzAirfoilReader(Airfoil);

%finding leading edge of airfoil in profile
LeadingEdgeIndex=-1;
for j=(1:1:length(xWingFoil))
    if (xWingFoil(j)==0)&&(zWingFoil(j)==0)
        LeadingEdgeIndex=j;
        break
    end
end

%checking that leading edge was found
if LeadingEdgeIndex==-1
    fprintf('\n***error: leading edge of airfoil profile not found in file %s.dat in zzzGeometryPlotter.m***\n',Airfoil);
end

%seperating upper and lower surface profiles
for j=(1:1:length(xWingFoil))
    if j<LeadingEdgeIndex
        UpperProfileX(j)=xWingFoil(j);
        UpperProfileZ(j)=zWingFoil(j);
    elseif j==LeadingEdgeIndex
        UpperProfileX(j)=xWingFoil(j);
        UpperProfileZ(j)=zWingFoil(j);
        LowerProfileX(1)=xWingFoil(j);
        LowerProfileZ(1)=zWingFoil(j);
    elseif j>LeadingEdgeIndex
        LowerProfileX(j-LeadingEdgeIndex+1)=xWingFoil(j);
        LowerProfileZ(j-LeadingEdgeIndex+1)=zWingFoil(j);
    end
end

%reversing upper surface profile from trailing edge first to leading edge first
UpperProfileX=fliplr(UpperProfileX);
UpperProfileZ=fliplr(UpperProfileZ);

%sizing surface profiles for current chord length
xU=UpperProfileX*Char(i,4);
zU=UpperProfileZ*Char(i,4);
xL=LowerProfileX*Char(i,4);
zL=LowerProfileZ*Char(i,4);

y=[0:RibSpacing:Char(i,3)/2.0];
ChordProfile=ones(1,length(y));
HalfSpan=Char(i,3)/2.0;
TaperFrac=Char(i,5)/100.0;
TaperStart=HalfSpan-(HalfSpan*TaperFrac);
for j=(1:1:length(ChordProfile));
    if y(j)<=TaperStart;
        ChordProfile(j)=Char(i,4);
    else
        ChordProfile(j)=Char(i,4)-((Char(i,4)-Char(i,6))/(HalfSpan*TaperFrac))*(y(j)-TaperStart);
    end;
end;

for j=(1:1:length(y));
    if y(j)<=TaperStart;
        plot3(xU*ChordProfile(j),ones(1,length(xU))*y(j),zU*Char(i,4)+FuseRad);
        plot3(xL*ChordProfile(j),ones(1,length(xL))*y(j),zL*Char(i,4)+FuseRad);
        plot3(xU*ChordProfile(j),ones(1,length(xU))*-y(j),zU*Char(i,4)+FuseRad);
        plot3(xL*ChordProfile(j),ones(1,length(xL))*-y(j),zL*Char(i,4)+FuseRad);
    else
        plot3(xU*ChordProfile(j)+(Char(i,4)-ChordProfile(j))*0.25,ones(1,length(xU))*y(j),zU*Char(i,4)+FuseRad+(y(j)-TaperStart)*tan(Char(i,7)*pi/180));
        plot3(xL*ChordProfile(j)+(Char(i,4)-ChordProfile(j))*0.25,ones(1,length(xL))*y(j),zL*Char(i,4)+FuseRad+(y(j)-TaperStart)*tan(Char(i,7)*pi/180));
        plot3(xU*ChordProfile(j)+(Char(i,4)-ChordProfile(j))*0.25,ones(1,length(xU))*-y(j),zU*Char(i,4)+FuseRad+(y(j)-TaperStart)*tan(Char(i,7)*pi/180));
        plot3(xL*ChordProfile(j)+(Char(i,4)-ChordProfile(j))*0.25,ones(1,length(xL))*-y(j),zL*Char(i,4)+FuseRad+(y(j)-TaperStart)*tan(Char(i,7)*pi/180));
    end;
end;

%Plotting horizontal tail========================
RibSpacing=0.05;
WingNACA='0012';

t=str2double(WingNACA(3:4))/100.0;
c=1;
x=(0:c/100.0:c);

m=str2double(WingNACA(1))/100.0;
p=str2double(WingNACA(2))/10.0;

yt=(t/0.2)*c*(0.296*(x/c).^(1/2)-0.1260*(x/c)-0.3516*(x/c).^2+0.2843*(x/c).^3-0.1015*(x/c).^4);
yc=zeros(1,length(yt));
index=1;
for j=(0:c/100.0:p*c);
    yc(index)=m*(x(index)/(p^2))*(2*p-x(index)/c);
    index=index+1;
end;
for j=(p*c+c/100.0:c/100.0:c);
    yc(index)=m*((c-x(index))/((1-p)^2))*(1+x(index)/c-2*p);
    index=index+1;
end;
theta=[atan(diff(yc)./diff(x)) 0];

xU=x-yt.*sin(theta);
zU=yc+yt.*cos(theta);
xL=x+yt.*sin(theta);
zL=yc-yt.*cos(theta);

Sref=((Char(i,3)-(Char(i,3)*(Char(i,5)/100)))*Char(i,4))...
        +(0.5*Char(i,3)*(Char(i,5)/100)*(Char(i,4)+Char(i,6)));
CurrentHorzTailSpan=(HorzTailCoeff*Char(i,4)*Sref)...
        /((Char(i,1)+(3/4)*Char(i,4))*Char(i,9));
CurrentVertTailHeight=(VertTailCoeff*Char(i,3)*Sref)...
        /((Char(i,1)+(3/4)*Char(i,4))*Char(i,11));

y=[0:RibSpacing:CurrentHorzTailSpan/2.0];

for j=(1:1:length(y));
    plot3(xU*Char(i,9)+(Char(i,1)+(0.75)*Char(i,4)),ones(1,length(xU))*y(j),zU*Char(i,9));
    plot3(xL*Char(i,9)+(Char(i,1)+(0.75)*Char(i,4)),ones(1,length(xL))*y(j),zL*Char(i,9));
    plot3(xU*Char(i,9)+(Char(i,1)+(0.75)*Char(i,4)),ones(1,length(xU))*-y(j),zU*Char(i,9));
    plot3(xL*Char(i,9)+(Char(i,1)+(0.75)*Char(i,4)),ones(1,length(xL))*-y(j),zL*Char(i,9));
end;

%Plotting vertical tail==========================
RibSpacing=0.05;
WingNACA='0012';
t=str2double(WingNACA(3:4))/100.0;

c=1;
x=(0:c/100.0:c);

m=str2double(WingNACA(1))/100.0;
p=str2double(WingNACA(2))/10.0;

yt=(t/0.2)*c*(0.296*(x/c).^(1/2)-0.1260*(x/c)-0.3516*(x/c).^2+0.2843*(x/c).^3-0.1015*(x/c).^4);
yc=zeros(1,length(yt));
index=1;
for j=(0:c/100.0:p*c);
    yc(index)=m*(x(index)/(p^2))*(2*p-x(index)/c);
    index=index+1;
end;
for j=(p*c+c/100.0:c/100.0:c);
    yc(index)=m*((c-x(index))/((1-p)^2))*(1+x(index)/c-2*p);
    index=index+1;
end;
theta=[atan(diff(yc)./diff(x)) 0];

xU=x-yt.*sin(theta);
zU=yc+yt.*cos(theta);
xL=x+yt.*sin(theta);
zL=yc-yt.*cos(theta);

y=[-CurrentVertTailHeight/2.0:RibSpacing:CurrentVertTailHeight/2.0];

for j=(1:1:length(y));
    plot3(xU*Char(i,11)+(Char(i,1)+(0.75)*Char(i,4)),zU*Char(i,11),ones(1,length(xU))*y(j));
    plot3(xL*Char(i,11)+(Char(i,1)+(0.75)*Char(i,4)),zL*Char(i,11),ones(1,length(xL))*y(j));
end;

hold off;