%% Surface generating using the thresholding method
% The function input is only the stack path, it will save the Dorsal, Top
% and Ventral=dorsal surfaces
% test data
function gg=top_thresh(Path)
 vol=Full_correct_C(Path);
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
    Surfs.Ventral=dorsal_surface;

    img=Top_view_vol(vol);
    Surfs.Top=img;
    Surfs.Dorsal(Surfs.Dorsal>500)=nan;
    Surfs.Ventral(Surfs.Ventral>500)=nan;
    Surfs.Top(isnan(Surfs.Dorsal))=nan;
    save([Path,'\Surf_file_thresh.mat'],'Surfs');
    gg=1;
end

