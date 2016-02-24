maskname = 'spiralmatP16.png';
theta = 0;
X = 4;
Y = 0;

try
    spiral_Orig = rgb2gray(imread(maskname));
catch
    rememberdir = pwd;
    cd ..
    spiral_Orig = rgb2gray(imread(maskname));
    cd(rememberdir)
end

spiralmask1 = double(imresize(imrotate(spiral_Orig,theta,'nearest'),0.411));spiralmask1 = imcrop(spiralmask1,[length(spiralmask1)/2-1024-X,length(spiralmask1)/2-1024-Y,2047,2047])/255;

spiralmask2 = double(imresize(imrotate(spiral_Orig,theta-180,'nearest'),0.411));spiralmask2 = imcrop(spiralmask2,[length(spiralmask2)/2-1024+X,length(spiralmask2)/2-1024+Y,2047,2047])/255;

%%
fignum = round(rand*1E4);
filenameinit = 'Basler_.tiff';

[pathstr, filenameinit, ext] = fileparts(filenameinit);
filenameinit = strrep(filenameinit, '*', '');
filesort = dir([filenameinit,'*',ext]);
filename = filesort(1).name;
[~, filename, ~] = fileparts(filename);
filename = filename(1:end-4);


figure(fignum);
numfiles = numel(filesort);
newfilename = [filename,num2str(numfiles,'%0.4u'),ext];
Holo = imread(newfilename);
dynrange0 = min(Holo(:));
dynrange1 = max(Holo(:)); %max value just over 255 optimizes dynamic range
HoloFFT = log10(abs(fftshift(fft2(Holo))));
HoloFFT = (HoloFFT - min(HoloFFT(:)))/(max(HoloFFT(:))-min(HoloFFT(:)));
HoloFFT_adapthisteq = adapthisteq(HoloFFT);
figure(fignum);
ax1 = subplot(1,2,1);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)])
ax2 = subplot(1,2,2);imagesc(spiralmask1.*HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy;
linkaxes([ax1,ax2],'xy')
zoom(4)

figure(fignum+1);
ax1 = subplot(1,2,1);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)])
ax2 = subplot(1,2,2);imagesc(spiralmask2.*HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy;
linkaxes([ax1,ax2],'xy')
zoom(4)


save('spiralmasks_TEMP','spiral_Orig','spiralmask1','spiralmask2')
save('mask_TEMP','spiralmask1')
save('mask_negative_TEMP','spiralmask2')
imwrite(spiral_Orig,maskname)
imwrite(spiralmask1,'mask_TEMP.png')
imwrite(spiralmask2,'mask_negative_TEMP.png')
