% Full correcting a 3D scan
function Vout=Full_correct_C(Path)
% 
% clear
% clc
% Path='D:\test';
% path to the images just taken
%Path=[Path,'\',latestfile];
C=20;
load('correctio_coef.mat');
vol=Read_OCT(Path);
stack=nan(512,512,512);
dX=Value.dX;
dY=Value.dY;
Lam=Value.Lam;
P1=Value.P1;
P2=Value.P2;
%
    newimg2=nan(512,size(stack,2)+C+20,size(stack,3)+C+20);
    % Correct the radial distortion for each Z slice image
    for x=1:512
      for y=1:512
        rd2=(x-dX)^2+(y-dY)^2;
        yu=floor(dX+(x-dX)/(1+rd2*Lam));
        xu=floor(dY+(y-dY)/(1+rd2*Lam));
        stack(:,xu,yu)=vol(:,y,x);
      end
    end
    % Correct the corrected slice for tangental distortion
    XD=0;
    DY=0;
    Lnt=length(stack);
    for x=1:Lnt
        for y=1:Lnt
            x1=x-dX-XD;
            y1=y-dY-DY;
            Yu=floor(x1+dX+XD+P1*(2*x1^2)+2*P2*x1*y1);
            Xu=floor(y1+dY+DY+P2*(2*y1^2)+2*P1*x1*y1); 
            newimg2(:,Xu+C,Yu+C)=stack(:,y,x);
        end
    end
%
W2=newimg2;
Y = ndnanfilter(newimg2,'rectwin',[0,2,2]);
Y(isnan(Y))=0;
sub=Y.*isnan(newimg2);
 W2(isnan(W2))=0;
final=W2+sub;

% crop the 3D stack
clc
%cuboid=[X-start z-start y-start x-length z-length y-length]
cuboid=[(size(final,2)-512)/2+2 1 (size(final,3)-512)/2+10 511 511 511];
Vout=imcrop3(final,cuboid);
%volshow(Vout);
end
% test=mat2gray(squeeze(Vout(135,:,:)))  ;
% figure; imshow(test);


%% Test what you got on an actual scan
% clc
% figure; sliceViewer(vol,'SliceDirection','Y')
% figure;sliceViewer(final,'SliceDirection','Y')

