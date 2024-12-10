%% The path generator!
% function Path_gen(Path,D_path,in,safePix,refrIdx)
% in Path gen 8 we save the config file in the data folder as well for the
% future references
%function gg=Path_gen8(Config)
function LCR_path_planning(Path,Z_offset,D_path,in,Root,CRtype,refrIdx)

% control files
C_mat=importdata([Root,'\calibration_matrix.txt']);
OCT_pos=importdata([Root,'\imaging_position.txt']);
OCT_pos_C=importdata([Root,'\Calibration_imaging_position.txt']);
% OCT_cal=load([Root,'\OCT_Cal.mat']);
% OCT_cal=OCT_cal.OCT_Cal;

in=in*0.1;

latestfile=find_latestfile(Path);
Path2=[Path,'\',latestfile];

offset=load([Path2,'\img_shift.mat']);
All_offset=offset.All_offset;   

% Save the read config file in the original data folder for future refrence
% configCopy=[Path2,'\config.mat'];
% copyfile(Config,configCopy)
% generate the corrected input volume
if CRtype==2
    file=[Path2,'\Stitched_surf_Top.mat'];
else
    file=[Path2,'\Stitched_Surf.mat'];
end
data=load(file);
Surfs=data.Stitched_surf;

file2=[Path2,'\figures\Top_view.fig'];
% Get the data from the user 

%----------- Producing the drilling path based on the user input-----------
F=figure;
choice=2; 
while choice==2  % checking whether the user is happy with the given path
    close (F)
    if isfile(file2)
        F=open(file2);
    else
     F=figure;
     imshow(Surfs.Top);
    end
set(gcf,'position',[400,200,size(Surfs.Top)]);
if CRtype~=1
    text(-15,-25,'Identify the origin and the negative y direction in the FOV and press Enter')

    % choose a reference point and axis for the drilling path on the scan surface (Bregma_Lambda)
    [X,Y]=getpts;
    Bregma=[X(1) Y(1)];
    Lambda=[X(2) Y(2)];


    % Calculating the angle of the path coordinate system with respect to the OCT image 
    R_angle=atan2((Lambda(1)-Bregma(1)),(Lambda(2)-Bregma(2)));
    
    %Define coordinate axis in pixels based on reference point 
    % AP-axis
    coordinates.Ax1=(1:512)-Bregma(1); % shift to align 0 with reference point
    
    % ML-axis
    coordinates.Ax2=(1:512)-Bregma(2); % shift to align 0 with ref

    %------------------------ The interpolation part------------------------
    % This code linearly interpolate between each two points of the given path 
    % such that the distance between each two points is always less than a
    % given distance by user. (Homogenous interpolation code)
     D_data= H_interpolate(D_path,in)';
  
    %--------------------------- Generating the path in OCT space----------------
    scaling=70; % 5 mm is 470 pixels 
    
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
else
   text(-15,-25,'select the Burr hole positions')

    % choose a reference point and axis for the drilling path on the scan surface (Bregma_Lambda)
    [X,Y]=getpts;
    D_dataB=[X';Y'];
    hold on
    scatter(D_dataB(1,:),D_dataB(2,:));
    coordinates.Ax1=(1:512)-256; % shift to align 0 with reference point
    
    % ML-axis
    coordinates.Ax2=(1:512)-256; % shift to align 0 with ref
end 

    choice=menu('Are you happy with the placement of the drilling path?','Yes','No');
end

parent=[Path,'\',latestfile,'\'];
mkdir(parent, 'figures');
saveas(gcf,[Path,'\',latestfile,'\figures\Top_view.fig'])
%close(F2) % close the top view image window

close (F)

% Gnerate the final path adding z

% Correcting ventral surface for the refractive index 
Surfs.Ventral=Surfs.Dorsal-((Surfs.Dorsal-Surfs.Ventral)./refrIdx);

%look up the Z value
D_dataBRR=round(D_dataB);
Z_data2=zeros(1,length(D_dataBRR)); 
for i=1:length(D_dataBRR)
    Z_data2(i)=Surfs.Ventral(D_dataBRR(2,i),D_dataBRR(1,i)) + Z_offset; 
end
if CRtype~=1
    TD_path=[D_dataBRR;Z_data2]; % this is the output to multiply to calibration matrix to generate pilot points
else
    % This is for the burrhole condition
    TD_pathX=[D_dataBRR(1,:);D_dataBRR(1,:);[D_dataBRR(1,2:end),D_dataBRR(1,1)]];
    TD_pathX=TD_pathX(:)';
    TD_pathY=[D_dataBRR(2,:);D_dataBRR(2,:);[D_dataBRR(2,2:end),D_dataBRR(2,1)]];
    TD_pathY=TD_pathY(:)';
    TD_pathZ=[Z_data2;Z_data2+86;[Z_data2(2:end)+86,Z_data2(1)+86]];
    TD_pathZ=TD_pathZ(:)';
    TD_path=[TD_pathX;TD_pathY;TD_pathZ];

end
    % The 3D illustration of the result
x=1:size(Surfs.Ventral,2);
y=1:size(Surfs.Ventral,1);
z=Surfs.Ventral(y(:),x(:));
z2=Surfs.Dorsal(y(:),x(:));
D=figure;
mesh(x,size(Surfs.Ventral,1)-y,z)
hold on
mesh(x,size(Surfs.Ventral,1)-y,z2,'LineStyle','none','FaceColor','flat','FaceAlpha',0.4)

plot3(TD_path(1,:),size(Surfs.Ventral,1)-TD_path(2,:),TD_path(3,:)+2,'color','k','LineWidth',1)
saveas(gcf,[Path,'\',latestfile,'\figures\surfaces.fig'])
close(D);
% -----------Display thickness data----------------
D=figure;
imagesc(coordinates.Ax1,coordinates.Ax2,Surfs.Dorsal-Surfs.Ventral)
cb=colorbar;
cb.Label.String="Thickness (pixels)";
colormap turbo
caxis([0 50])
axis([coordinates.Ax1(1) coordinates.Ax1(end) coordinates.Ax2(1) coordinates.Ax2(end)])
set(gcf,'color','w')
ax=gca;
ax.DataAspectRatio = [1 1 1]; % ensures correct aspect ratio ("axis equal" does not work here)
title('Thickness');
xlabel('Medial-lateral distance (pixels)');
ylabel('Anterior-posterior distance (pixels)');
saveas(gcf,[Path,'\',latestfile,'\figures\thickness.fig'])
%-------------------------------------------------
% Convert the generated path to driller refrence frame:
close(D);
L=[0 0 0 1]';
% Calculate the transition matrix due to change in the OCT position
% compared to calibration position
% vec=OCT_pos-OCT_pos_C;
I2=[eye(3);(OCT_pos-OCT_pos_C)];
tranport_M=[I2 L];
% Calculate the final transormation matrix from OCT to the Diller axis
%MAT=C_mat;%*tranport_M;
MAT=C_mat*tranport_M;
% Place holder for the final path
%C_All_offset=[All_offset(1:2),2*All_offset(3)];
TD_path=TD_path+All_offset;
C_TD_path=[TD_path' ones(length(TD_path),1)]*MAT;
writematrix(C_TD_path,[Root,'\C_TD_path.txt'],'Delimiter','tab');
% In the end, Make a cofig file and save all the surgery settings in it.
Large_FOV=1;
Cfile=[Path,'\',latestfile,'\config.mat'];
save(Cfile,'D_path','Z_offset','refrIdx','in',"C_mat","OCT_pos_C","OCT_pos",'CRtype','Large_FOV');
end


