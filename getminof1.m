%% Get Normalized Image of first Hologram

ext = '.tiff';
z1 = -2.5E-3;
z2 = 2.5E-3;
zsteps = 501;

tic
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO = double(imread(filesort(1).name));

background=avgbg('filename','*.tiff','output','background');

HOLO = HOLO./background;

%% Get Imin of Normalized Image of first Hologram

[Imin, zmap] = imin((HOLO),lambda/refractindex,linspace(z1,z2,zsteps),ps/mag,'mask',mask);

imagesc(Imin); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin = (Imin - min(Imin(:)))./(max(Imin(:)) - min(Imin(:)));

imwrite(uint8(Imin*255), 'Imin0001.png');
toc
