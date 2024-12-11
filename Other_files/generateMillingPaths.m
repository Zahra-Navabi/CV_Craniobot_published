
%% Simple drilling path generation
clear
clc
openfig("Back_ground.fig")
hold on
X_0=525;
Y_0=450;
X_s=80;
Y_s=80;

%old path edit 
 old_path=importdata('C:\Users\User\Documents\CB III control files\drilling_paths\Gigapixel_V1.txt');
% X=0;
% Y=0;
% R=1.75; 
% R=R*X_s;
% Y=Y*Y_s+Y_0;
% X=X*X_s+X_0;
%  viscircles([X Y],R)
old_path(1,:)=old_path(1,:).*X_s+X_0;
old_path(2,:)=-old_path(2,:).*Y_s+Y_0;
plot(old_path(1,:),old_path(2,:))

xline(X_s*0+X_0,'r--');xline(-1*X_s+X_0,'--');xline(1*X_s+X_0,'--');xline(2*X_s+X_0,'--');xline(-2*X_s+X_0,'--');xline(3*X_s+X_0,'--');xline(-3*X_s+X_0,'--');xline(4*X_s+X_0,'--');xline(-4*X_s+X_0,'--');
yline(0*Y_s+Y_0,'r--');yline(-1*Y_s+Y_0,'--');yline(1*Y_s+Y_0,'--');yline(2*Y_s+Y_0,'--');yline(-2*Y_s+Y_0,'--');yline(3*Y_s+Y_0,'--');yline(-3*Y_s+Y_0,'--');yline(4*Y_s+Y_0,'--');yline(-4*Y_s+Y_0,'--');yline(5*Y_s+Y_0,'--');yline(6*Y_s+Y_0,'--')
title('dont make a concave polygon or the path fails')

 ROI= drawpolyline;
 path=ROI.Position';
 %return the target points to before scaling 
 Path(1,:)=(path(1,:)-X_0)./X_s;
 Path(2,:)=-(path(2,:)-Y_0)./Y_s;
% Now interpolate the points to generate points  
if length(path)<3
    f = msgbox("fewrer than 3 points are not acceptable for drilling path");
else
 name= inputdlg("drilling path name","save name");
 writematrix(Path,['C:\Users\User\Documents\CB III control files\drilling_paths\',char(name),'.txt']);
 close all
end
%% Skull thinning path generation

clear
clc
figure;
xline(0,'--');xline(-1,'--');xline(1,'--');xline(2,'--');xline(-2,'--');xline(3,'--');xline(-3,'--');xline(4,'--');xline(-4,'--');
yline(0,'--');yline(-1,'--');yline(1,'--');yline(2,'--');yline(-2,'--');yline(3,'--');yline(-3,'--');yline(4,'--');yline(-4,'--');
title('dont make a concave polygon or the path fails')
    xlim([-3 3])
    ylim([-3 3])
[X,Y]=getpts;
polygon=[X,Y];

% the distance between each pass
d=0.08;

%
polygon=[polygon;X(1) Y(1)];
% Find the top and bottom vertices of the polygon
[~,inmax]=max(polygon);
[~,inmin]=min(polygon);
h=polygon(inmax(2),2);
% From there generate parallel lines with distance of 
Len=polygon(inmax(2),2)-polygon(inmin(2),2);
turns=floor(Len/d);
rec=floor(turns/2); % for each rectangle
lines=h*ones(1,turns);
steps=0:1:turns-1;
lines2=lines-d*steps;

Yall=repelem(lines2,2);
%while covered>d
    % Find the intersection of the y=covered and the polygon (go a rectangel of two lines each time)
    x1=polygon(inmax(1),1)+0.01;
    x2=polygon(inmin(1),1)-0.01;
    % Generate the path:
    % batchs of 4 points:
    Xp=[x1 x2 x2 x1];
    Xall=repmat(Xp,1,rec);
    if length(Yall)>length(Xall)
         Xall=[Xall x1 x2];
    end
    [xi ,yi]=polyxpoly(polygon(:,1),polygon(:,2),Xall,Yall);
    % switch the order of the dues to make a path
    % Find the number fo *4 indicies
    in4=floor(length(xi)/4);
    for i=1:in4
        [xrep,yrep]=Switch([xi(4*i),xi(4*i+1)],[yi(4*i),yi(4*i+1)]);
        xi(4*i)=xrep(1);
        xi(4*i+1)=xrep(2);
        yi(4*i)=yrep(1);
        yi(4*i+1)=yrep(2);
    end

    hold on
    mapshow(polygon(:,1),polygon(:,2),'DisplayType','polygon','LineStyle','none')

    mapshow(Xall,Yall,'Marker','+')
    mapshow(xi,yi,'DisplayType','point','Marker','o')
    xlim([-3 3])
    ylim([-3 3])
figure;plot(xi,yi)
    xlim([-3 3])
    ylim([-3 3])
    path=[xi,yi]';
% Now interpolate the points to generate points  
 writematrix(path, "path.txt");

 %% switch direction
function [X,Y]=Switch(X1,Y1)
   X=flip(X1);
   Y=flip(Y1);
end