%% Blind Deconvolution Code
%Loading in Data: Real Data (20140402-Vort-20um)
%{
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
% Call fft editing function
% Holo=fftedit(Holo);
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
%
% maskFn=@mask;
filename0 = 'Sim_Mie512px_5part_RealParticleField_Inverse';
filename1 = 'KnifeEdgeExpData_SimPSF_RealParticleFieldNormInvert';
filename2 = 'KnifeEdgeExpData_SimPSF_RealParticleFieldNormInvertPos';
tic
load gong.mat;
% [J,PSF3D] = deconvblind({Holo3D_Init},{PSF3D_Init},10);
% save([filename0,'_10Iterations.mat'],'J','PSF3D','-v7.3');
% [Jreal,PSF3Dreal] = deconvblind({Holo3D_Init},{PSF3D_Init},10);
% save([filename1,'_10Iterations.mat'],'Jreal','PSF3Dreal','-v7.3');
% [Jpos,PSF3Dpos] = deconvblind({Holo3D_InitPOS},{PSF3D_InitPOS},10);
% save([filename2,'_10Iterations.mat'],'Jpos','PSF3Dpos','-v7.3');
% toc
% try soundsc(y); catch ME; end;
M=30;
for L = [50 100 200];
%     [J,PSF3D] = deconvblind(J,PSF3D,L-M);
%     save([filename0,'_',num2str(L),'Iterations.mat'],'J','PSF3D','-v7.3');
%     [Jreal,PSF3Dreal] = deconvblind(Jreal,PSF3Dreal,L-M);
%     save([filename1,'_',num2str(L),'Iterations.mat'],'Jreal','PSF3Dreal','-v7.3');
    [Jpos,PSF3Dpos] = deconvblind(Jpos,PSF3Dpos,L-M);
    save([filename2,'_',num2str(L),'Iterations.mat'],'Jpos','PSF3Dpos','-v7.3');
    toc
    try soundsc(y); catch ME; end;
    M=L;
end

%{
[J,PSF3D] = deconvblind(J,PSF3D,100,maskFn);
save([filename,'_900Iterations.mat'],'J','PSF3D','-v7.3');
toc
try soundsc(y); catch ME; end;



%% fsfds

%function HoloOut=fftedit(Ein)
[m,n]=size(Ein);  M=m;  N=n;
zpad=1024;
M=zpad;
N=zpad;
aveborder=mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)'));
Ein_pad=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
Ein_pad(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=Ein;
HoloFFT = fftshift(fft2(Ein_pad));
mfft = HoloFFT(63,334);
HoloFFT2=HoloFFT;
HoloFFT2(1:130,400:650)=mfft;
HoloFFT2(924:1024,350:650)=mfft;
HoloFFT2(296:305,498:503)=mfft;
HoloFFT2(403:408,502:510)=mfft;
HoloFFT2(617:624,516:522)=mfft;
HoloFFT2(722:729,523:527)=mfft;
HoloFFT2=HoloFFT2.*mask;
Eout_pad=ifft2(ifftshift(HoloFFT2));
HoloOut=Eout_pad(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2);
%}
