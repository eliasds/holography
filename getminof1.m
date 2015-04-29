%% Get Normalized Image of first Hologram

tic

%% Setup Constants
%
ext = '.tiff';
z1 = -4.6E-3;
z2 = 5.1E-3;
zsteps = 1001;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 5.5E-6;
mag = 4.02;
maskflag = true;
createbackgroundflag = false;
saveconstantsflag = true;

%% Create Background
%
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = double(imread(filesort(1).name));

if createbackgroundflag == true;

    background=avgbg('filename','*.tiff','output','background');

else
    
    load('background.mat');
    
end

HOLO0001 = HOLO0001./background;

%% Create Mask
%
mask = ones(size(background));

if maskflag == true;
    
    mask(:,1:length(background)/2) = 0;
    
end

%% Get Imin of Normalized Image of first Hologram
%
[Imin0001, zmap0001] = imin((HOLO0001),lambda/refractindex,linspace(z1,z2,zsteps),ps/mag,'mask',mask);

figure

imagesc(Imin0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin0001 = (Imin0001 - min(Imin0001(:)))./(max(Imin0001(:)) - min(Imin0001(:)));

imwrite(uint8(Imin0001*255), 'Imin0001.png');

%% Save Constants
%
if saveconstantsflag == true;
    
    save(['imin0001constants.mat'],'ext','z1','z2','zsteps','lambda','refractindex','ps','mag','mask','Imin0001','HOLO0001');

end

%%
%
toc
