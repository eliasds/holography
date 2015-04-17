%% Save thesholded images from Imin

InputPathStr='D:\shuldman\20150325\10mmCuvetteHalfwayIn_MaxParticlesTrial2\matfiles\';
filename    = 'Basler_acA2040-25gm_';
thlevel = 0.0;
dilaterode = [3,8];
InputExt = 'mat';
OutputExt = 'png';
OutputPathStr = 'thlevel0\';

%% Create Dilate and Erode Parameters
for L = 1:numel(dilaterode)
    eval(['disk',int2str(L-1),' = morphshape(dilaterode(L));'])
%     disk{L} = morphshape(dilaterode(L)); % more efficient code
end

if ~exist([InputPathStr,OutputPathStr], 'dir')
  mkdir([InputPathStr,OutputPathStr]);
end
filename = strcat(InputPathStr,filename);
filesort = dir([filename,'*.',InputExt]);
for L = 1:length(filesort)
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

wb = waitbar(0/length(filesort),'Creating Thresholded Images from Imin');
for L = 1:length(filesort)
    load([InputPathStr,filesort(L).name], 'Imin');
    [thImin] = imin2img( Imin, thlevel );
%     thImin = bwareaopen(thImin, 8);
%     thImin = imdilate(thImin,disk1);
%     thImin = imerode(thImin,disk0);
    imwrite(uint8(255-Imin*255), [InputPathStr,OutputPathStr,filesort(L).firstname,'.',OutputExt]);
    waitbar(L/length(filesort),wb);
end
close(wb);

