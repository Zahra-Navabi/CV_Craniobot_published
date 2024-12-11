% Read OCT stack
function vol=Read_OCT(Path)
dims=[512 512 512];
fpath=[Path,'\'];
Sname='BSCAN-SGL';
const.ymin=50; % minimum pixel in the y-direction for cropping
const.ymax=256; % maximum pixel in y-direction for cropping
const.rngAx3=[const.ymin 150]; % range for cropping
const.rngAx2=[0 512]; 
const.pix2umDV=10; % um/pix, axial direction
constRng=[const.rngAx3 const.rngAx2];
refrIdx=1.45; % refractive index of skull
safePix=1; % safety pixel offset for ventral surface 
%%%% Profiling %%%%
%%%% Import, measure dorsal surface, top view %%%%
% Initialize dorsal surface
roi=[1 dims(1) const.ymin dims(2)];
dorsal_surface2=zeros(dims(1),dims(2));
% Import scans, measure dorsal surface
vol=zeros(dims);
for k=1:dims(3)
    %%% Import volume
    fNameTemp=join([fpath,Sname,'-',num2str(sprintf('%03d',k)),'.tif']);
    imTemp=imread(fNameTemp);
    vol(:,:,k)=imTemp(:,:); % convert to grayscale XX Wrong!! tiff is only having one channel!! 
end
end