%% Homogeneous interpolation function
function New_vertices= H_interpolate(D_path,in)
% clear
% clc
% %future inputs
% %---------------
% D_path='C:\Users\User\Documents\CB III control files\drilling_paths\4mmCR.txt'; % drilling points path
% in=2;
 in=0.1*in;% maximum acceptable distance in hundred micro meters
% Import the drillin path 
p=importdata(D_path);
p=[p p(:,1)]; % Add the first point to the end of the path,Make the drilling path a closed loop
x=p(1,:)'; y=p(2,:)';
   % The points being shitfed down by one  
        points_start=[x(end) y(end);[x y]];
   % The point series being shifted up by one
        points_end=[[x y];x(1) y(1)];

   % Calculating the distance between each consequative point
        Dist=vecnorm(points_start-points_end,2,2);
   % Calculating how many points is needed between each two points
        Points_count_mat=ceil(Dist/in);
    
   % placeholders for new points in the path
        X_new=nan(length(points_start),max(Points_count_mat));
        Y_new=nan(length(points_start),max(Points_count_mat));
 %   
   % Linear interpolation for each two given path points
        for i=1:length(points_end)
            % Number of interpolation point needed between two points
            pts=1:Points_count_mat(i);
            % Interpolating in X and Y direction (the new interpolated points are produced in new cloumns)
            X_new(i,:)=[((-points_start(i,1)+points_end(i,1))/Points_count_mat(i))*pts+points_start(i,1) zeros(1,max(Points_count_mat)-Points_count_mat(i))];
            Y_new(i,:)=[((-points_start(i,2)+points_end(i,2))/Points_count_mat(i))*pts+points_start(i,2) zeros(1,max(Points_count_mat)-Points_count_mat(i))];
        end

    % Reshaping the matrices into a vector
        X_new2=reshape(X_new',numel(X_new),1);
        Y_new2=reshape(Y_new',numel(Y_new),1);
        % Remove the empthy spaces 
        X_new2(X_new2==0)=[];
        Y_new2(Y_new2==0)=[];
        New_vertices=[X_new2 Y_new2];
end
