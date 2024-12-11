%% stitching code to read the last 4 stacks and generate the stitched version
% the code gets the previously generated surfaces aas input and generates
% the stitched version, save them in the last directory
function All_offset=Surf_stitch_4(Path0)

Root='C:\Users\User\Documents\CB III control files' ;
OCT_pos=importdata([Root,'\imaging_position.txt']);
%OCT_pos_C=importdata([Root,'\Calibration_imaging_position.txt']); %this should be replaced witt the calibration of the OCT position if they are not the same

OCT_cal=load([Root,'\OCT_Cal.mat']);
OCT_cal=OCT_cal.OCT_Cal;

% Define the relative translation in cartesian space
move=[2 2 -2 -2;2.25 -2.25 -2.25 2.25;zeros(1,4)]';

% read the last 4 surfaces
dirc = dir(Path0);
dirc = dirc(~cellfun(@isfolder,{dirc(:).name}));
dirc=dirc(cell2mat({dirc(:).isdir}));
%
[~,I1] = maxk([dirc(:).datenum],4);
I1=sort(I1,"ascend");
% check if the Surface hase laready been generated:
file=[Path0,dirc(I1(4)).name,'\Stitched_surf_Top.mat'];
 if ~isfile(file)
surfs=cell(1,length(I1));
if ~isempty(I1)
    for i=1:length(I1)
        latestfile=dirc(I1(i)).name;
        Path=[Path0,'\',latestfile];
        if isfile([Path,'\Surf_file_thresh.mat'])
            surfs{i}=load([Path,'\Surf_file_thresh.mat']);
        else
            top_thresh(Path);
            surfs{i}=load([Path,'\Surf_file_thresh.mat']);
        end
    end
end

% Also delete the edges
eg=25;

mask=nan(size(surfs{i}.Surfs.Dorsal));
mask(eg:end-eg,eg:end-eg)=1;
for i=1:4
surfs{i}.Surfs.Dorsal=surfs{i}.Surfs.Dorsal.*mask;
surfs{i}.Surfs.Ventral=surfs{i}.Surfs.Ventral.*mask;
surfs{i}.Surfs.Top=surfs{i}.Surfs.Top.*mask;
end
T_pix=zeros(3,4);
for i=1:4
      %temp=-[move(i,:)+OCT_pos 1]*OCT_cal+[OCT_pos_C 1]*OCT_cal;
      temp=-[move(i,:)+OCT_pos 1]*OCT_cal+[OCT_pos 1]*OCT_cal;
      T_pix(:,i)=temp(1:3);
end
X_shift=3;
T_pix(1,1:2)=T_pix(1,1:2)-X_shift;
T_pix(1,3:4)=T_pix(1,3:4)+2*X_shift;    
Y_shift=0;
T_pix(2,1:4)=T_pix(2,1:4)-Y_shift;
T_pix(2,2:3)=T_pix(2,2:3)+2*Y_shift;
% Traslate vectors

T_pix=round(T_pix);
% Calculate the overall offset and change each transformed matrix
% accordingly
All_offset=min(T_pix,[],2);
All_offset(All_offset>0)=0; % if no negative translation, then no offset is needed

% Calculating offset for each stack---->>> caviat here about the rounding
% process
offset=zeros(3,4);
for i=1:4 
offset(:,i)=T_pix(:,i)-All_offset;
end

% assign a large sum nan matrix
Size=max([size(surfs{1}.Surfs.Dorsal)',size(surfs{2}.Surfs.Dorsal)',size(surfs{3}.Surfs.Dorsal)',size(surfs{4}.Surfs.Dorsal)'],[],2)+max(offset(1:2,:),[],2);

% Add the stacks to the big one
i=2;
j=1;
S_mat=nan(Size(i),Size(j),3,4);

for n=[1,2,3,4]
    S_mat(1+offset(i,n):size(surfs{n}.Surfs.Dorsal,1)+offset(i,n),1+offset(j,n):size(surfs{n}.Surfs.Dorsal,2)+offset(j,n),1,n)=surfs{n}.Surfs.Dorsal+offset(3,n);
    S_mat(1+offset(i,n):size(surfs{n}.Surfs.Ventral,1)+offset(i,n),1+offset(j,n):size(surfs{n}.Surfs.Ventral,2)+offset(j,n),2,n)=surfs{n}.Surfs.Ventral+offset(3,n);
    S_mat(1+offset(i,n):size(surfs{n}.Surfs.Top,1)+offset(i,n),1+offset(j,n):size(surfs{n}.Surfs.Top,2)+offset(j,n),3,n)=surfs{n}.Surfs.Top;
end

% Average all in one stack
div=double(~isnan(S_mat));
div=sum(div,4);
gray_sum=sum(S_mat,4,"omitnan")./div;
gray_sum(gray_sum==0)=nan;  
% img=gray_sum;
% topvol=reshape(img(:,:,3),size(img,1),size(img,2));
% figure; imshow(mat2gray(topvol))

% Save the newely genertaed surface in the last folder
% Save the new surfaces
Stitched_surf.Dorsal=squeeze(gray_sum(:,:,1));
Stitched_surf.Ventral=squeeze(gray_sum(:,:,2));
Stitched_surf.Top=squeeze(gray_sum(:,:,3));

save([Path,'\Stitched_surf_Top.mat'],"Stitched_surf");
save([Path,'\img_shift.mat'],"All_offset")
 end
end