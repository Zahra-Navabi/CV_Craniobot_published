% Function that takes the corrected stack and the required drilling depth.
% produceses the drilling path and the dorsal surface data
 function threshold_path_planning(Path,safePix,D_path,in,Root)
% clear
% clc
% %future function inputs
% Path='C:\Users\Public\Documents\Lumedica\OctEngine\Data';
% safePix=-4; % depth of drilling for dorsal surface code
% D_path='C:\Users\User\Documents\CB III control files\drilling_paths\UMNpath2.txt';
% in=2; % number of interpolated points
% Root='C:\Users\User\Documents\CB III control files' ;

% control files
C_mat=importdata([Root,'\calibration_matrix.txt']);
OCT_pos=importdata([Root,'\imaging_position.txt']);
OCT_pos_C=importdata([Root,'\Calibration_imaging_position.txt']);

% generate the corrected input volume
latestfile=find_latestfile(Path);
Path2=[Path,'\',latestfile];
file=[Path2,'\figures\Top_view.fig'];% check if the latest scan has been already analyzed
file2=[Path2,'\Surf_file.mat'];

if isfile(file)
    data=load(file2);
    Surfs=data.Surfs;
else
    vol=Full_correct_C(Path2);
    % Find the Dorsal surface using the max gradien formula
    [~,gr,~]=gradient(vol);
    [~,dorsal_surface]=max(gr,[],1);
    dorsal_surface=squeeze(dorsal_surface);
    %  Smoothing the surface
    dorsal_surface=medfilt2(dorsal_surface,[15 15],'symmetric');
    % Adjust the orientation
    dorsal_surface=512-flip(flip(dorsal_surface),2);
    dorsal_surface=dorsal_surface';
    Surfs.Dorsal=dorsal_surface;
    save([Path,'\',latestfile,'\Surf_file.mat'],'Surfs');
    
    % Use the prodeced surface to generate the drilling path in the OCT space
    % -------------------------------------------------------------------------
    % Produce and show the top surface:
    img=Top_view_vol(vol);
end
%
choice=2;
Fig=figure;
while choice==2
    close(Fig)
    if isfile(file)
         Fig=open(file);
    else
        Fig=figure;
        imshow(img);
    end
% Take the center and the orientation of the craniotomy
    text(-15,-25,'Identify the origin and the negative y direction in the FOV and press Enter')

    % choose a reference point and axis for the drilling path on the scan surface (Bregma_Lambda)
    [X,Y]=getpts;
    Bregma=[X(1) Y(1)];
    Lambda=[X(2) Y(2)];

    % Calculating the angle of the path coordinate system with respect to the OCT image 
    R_angle=atan2((Lambda(1)-Bregma(1)),(Lambda(2)-Bregma(2)));
    
    % Interpolate uniformly 

    D_data= H_interpolate(D_path,in)';

    scaling=70; % 1 mm is 50 pixels (>>you need the updated lateral pixel resolution for that<<)
    
    % Rotate the path based on the given guiding points
    RMat=[cos(R_angle) -sin(R_angle); sin(R_angle) cos(R_angle)];
    D_dataR=RMat*D_data;
    % Scale the path from real world to OCT pixels
    D_dataBX=scaling*D_dataR(1,:)+Bregma(1);
    D_dataBY=-scaling*D_dataR(2,:)+Bregma(2);
    
    D_dataB=[D_dataBX; D_dataBY];
    hold on
    % plot the drilling path on the surface

    plot(D_dataB(1,:),D_dataB(2,:),'r');
    scatter(D_dataB(1,:),D_dataB(2,:));
    scatter(X,Y,'*');


    choice=menu('Are you happy with the placement of the drilling path?','Yes','No');
    
end

% Save the drilling path and top surface image    
parent=[Path,'\',latestfile,'\'];
mkdir(parent, 'figures');
saveas(gcf,[Path,'\',latestfile,'\figures\Top_view.fig'])
close(Fig)

% Show the 3D Dorsal surface with the planned path on it and save it
% ----------------------------------------------------------------------
D_dataBRR=round(D_dataB);
Z_data2=zeros(1,length(D_dataBRR)); 
for i=1:length(D_dataBRR)
    Z_data2(i)=Surfs.Dorsal(D_dataBRR(2,i),D_dataBRR(1,i)) + safePix; 
end
TD_path=[D_dataBRR;Z_data2];
x=1:512;
y=1:512;
z2=Surfs.Dorsal(x(:),y(:));
T=figure;
mesh(x,512-y,z2,'LineStyle','none','FaceColor','flat','FaceAlpha',0.4)
hold on
plot3(TD_path(1,:),512-TD_path(2,:),TD_path(3,:),'color','k','LineWidth',1)
% the plus 2 pixels is only for ease of showing the path and nothing to do with the calculations

parent=[Path,'\',latestfile,'\'];
mkdir(parent, 'figures');
saveas(gcf,[parent,'figures\surfaces.fig'])

close (T)

%Translate the points to the Drilling space and save them
%--------------------------------------------------------------------------

L=[0 0 0 1]';
I=eye(3);
% Calculate the transition matrix due to change in the OCT position
% compared to calibration
I2=[I;(OCT_pos-OCT_pos_C)];
tranport_M=[I2 L];
% Calculate the final transormation matrix from OCT to the Diller axis
MAT=C_mat*tranport_M;
% Place holder for the final path
%C_TD_path=zeros(length(TD_path),4);
C_TD_path=[TD_path' ones(length(TD_path),1)]*MAT;
writematrix(C_TD_path,[Root,'\C_TD_path.txt'],'Delimiter','tab');

 end
