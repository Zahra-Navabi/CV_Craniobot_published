%Top_view function
function img=Top_view_vol(vol)

%%%% Construct top view image %%%%
imRecon=reshape(sum(vol,1),size(vol,2),size(vol,3));
% changing the surraounding to the same color as mean for adjusted colors
Cval=mean(imRecon(200:300,200:300),'all');
imRecon(imRecon<Cval*0.3)=Cval;
% imRecon(isnan(imRecon))=Cval;
%clear vol
imRecon=imadjust(rescale(imRecon)); % Initial rescale from [0,1] and contrast increase

% calculate ranges for contrast shifting based on mean +/- stdev
imAve=mean2(imRecon); imStdev=std2(imRecon); 
n=3; % set ranges to n stdevs above & below mean
if imAve-n*imStdev<0 % min must not be below zero
    rngMin=0;
else
    rngMin=imAve-n*imStdev;
end
if imAve+n*imStdev>1 % max must not be above 1
    rngMax=1;
else
    rngMax=imAve+n*imStdev;
end
%clear imStdev imAve

% smooth contrast, preserving strong edges
edgeThresh=0.1; amnt=-0.8; 
imRecon=localcontrast(single(imRecon),edgeThresh,amnt); 

% adjust contrast range again & curve to lighten images
gamma=0.6; 
imTopView=imadjust(imRecon,[rngMin rngMax],[],gamma); 
clear imRecon

% correct orientation for consistency with other plots
% imTopView=imTopView(end:-1:1,end:-1:1)';
imTopView=mat2gray(imTopView);
%%% Start of original block 2 code
%figure
%imshow(imTopView)
%set(gcf,'position',[500,300,size(vol,2),size(vol,3)]);
img=flip(flip(imTopView),2);
img=img';
end
