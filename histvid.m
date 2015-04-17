%% Display Histogram Movie

undock
fignum = 4157;
handle=figure(fignum); set(handle, 'Position', [100 100 1024 512])

InputPathStr='D:\shuldman\20150325\10mmCuvetteHalfwayIn_MaxParticlesTrial2\matfiles\';
filename    = 'Basler_acA2040-25gm_';
InputExt = 'mat';
OutputExt = 'png';
OutputPathStr = 'thlevel1E-1\';


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

hist_str1 = ['load([InputPathStr,filesort(L).name], ''Imin'');'];
hist_str2 = ['figure(fignum); h = histogram(Imin,nbins);', ...
    'title([''Frame#:'',num2str(L),''   (time in AU)'']);'];

L = 1;
eval(hist_str1)
nbins = length(Imin);
eval(hist_str2)
% axis([0,ceil(max(Imin(:))),0,nbins*10]);
axis([0,ceil(max(Imin(:)))/20,0,nbins*10/100]);
histaxis = axis;
for L = 2:length(filesort)
   eval(hist_str1)
   eval(hist_str2)
   axis(histaxis)
%     [bincount,edges] = histcounts(Imin0001(:),nbins);
   drawnow
end
