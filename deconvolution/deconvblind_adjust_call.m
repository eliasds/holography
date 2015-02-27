%% Blind Deconvolution Code
%Loading in Data: Real Data (20140402-Vort-20um)
%
ps = 5.5E-6;
mag = 4; %Magnification
eps = ps / mag; %Effective Pixel Size in meters
lambda = 632.8E-9; %laser wavelength in meters
refractindex = 1.33;

z1 = -3E-3;
z2 = 3E-3;
steps = 301;
Zin = linspace(z1,z2,steps);
Zout = Zin; 
radix2 = 2048;
zpad = 1024;
% filename = '20150223-KnifeEdgeLeftAperture_20umDiamPartLowDens_Mag4_Exp50_FPS01_RealAndVirtual';
filename = 'Mie512px_5part_Init';

%Real Data Hologram + Backgorund Subtraction
% img_hologram = imread('D:/shuldman/github/holography/deconvolution/20140402-Vort-20um/DH_0030.tif');
% hologram = rgb2gray(demosaic(img_hologram, 'rggb'));
% background = load('D:/shuldman/github/holography/deconvolution/20140402-Vort-20um/background.mat');
% hologram = im2double((hologram(1:2048, 1:2048)))./ im2double(background.background(1:2048, 1:2048));
% load('D:\shuldman\simulations\20150223-KnifeEdgeLeftAperture_20umDiamPartLowDens_Mag4_Exp50_FPS01_RealAndVirtual.mat')
load('D:\shuldman\Dropbox\simulation\3Ddeconvolution\HoloPSFtrials\CodedPSF\Mie512px_5part_Init.mat','Holo');
PSF3D_Init = load('D:\shuldman\simulations\coded3DPSF 512.mat','PSF3D'); PSF3D_Init = PSF3D_Init.PSF3D;
% PSF3D_Init = abs(PSF3D);
% PSF3D_Init = ones(512,512,301);
mask = ones(2*size(Holo));
mask(:,1:2*length(Holo)/2-1) = 0;

%Propagate Hologram to create 3D field
% [hologram_field] = propagate(hologram,lambda/refractindex,Zout,ps/mag,'zpad',zpad,'mask',mask,'CPU');
Holo3D_Init = (propagate(Holo,lambda/refractindex,Zout,ps/mag,'zpad',zpad,'mask',mask,'CPU'));

%% Crop Smaller Area from Hologram Field
% hologram_field_small_bgsub = hologram_field(919:919+1023, 252:252+1023,:);
% psf_field = hologram_field(547-128:547+128, 437-128:437+128,:);
% psf_init = ones(18,18,18); %No initial guess for PSF
% bgholo = mean(hologram_field_small_bgsub,3);
% bgpsf = mean(psf_field,3);
% [blind_obj, blind_psf] = deconvblind(abs(hologram_field_small_bgsub),psf_init);

%}

tic
load gong.mat;
[J,PSF3D] = deconvblind_adjust({Holo3D_Init},{PSF3D_Init},100);
save([filename,'_100Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);
[J,PSF3D] = deconvblind_adjust(J,PSF3D,100);
save([filename,'_200Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);
[J,PSF3D] = deconvblind_adjust(J,PSF3D,100);
save([filename,'_300Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);
[J,PSF3D] = deconvblind_adjust(J,PSF3D,100);
save([filename,'_400Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);
[J,PSF3D] = deconvblind_adjust(J,PSF3D,100);
save([filename,'_500Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);
[J,PSF3D] = deconvblind_adjust(J,PSF3D,100);
save([filename,'_600Iterations.mat'],'J','PSF3D','-v7.3');
toc
soundsc(y);