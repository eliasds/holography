%% Blind Deconvolution Code
%Loading in Data: Real Data (20140402-Vort-20um)
ps = 6.5E-6;
mag = 5; %Magnification
eps = ps / mag; %Effective Pixel Size in meters
lambda = 632.8E-9; %laser wavelength in meters
refractindex = 1.33;

a=0E-3;
b=6E-3;
c=31;
Zin=linspace(a,b,c);
Zout=Zin; 
radix2=2048;
zpad=2048;

%Real Data Hologram + Backgorund Subtraction
img_hologram = imread('D:/shuldman/github/holography/deconvolution/20140402-Vort-20um/DH_0030.tif');
hologram = rgb2gray(demosaic(img_hologram, 'rggb'));
background = load('D:/shuldman/github/holography/deconvolution/20140402-Vort-20um/background.mat');
hologram = im2double((hologram(1:2048, 1:2048)))./ im2double(background.background(1:2048, 1:2048));

%Propagate Hologram
[hologram_field] = propagate(hologram,lambda,Zout,eps,zpad);

%% Crop Smaller Area from Hologram Field
hologram_field_small_bgsub = hologram_field(919:919+1023, 252:252+1023,:);
psf_field = hologram_field(547-128:547+128, 437-128:437+128,:);
psf_init = ones(18,18,18); %No initial guess for PSF

bgholo = mean(hologram_field_small_bgsub,3);
bgpsf = mean(psf_field,3);
[blind_obj, blind_psf] = deconvblind(abs(hologram_field_small_bgsub),psf_init);