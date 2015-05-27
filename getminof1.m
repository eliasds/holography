%% Get Normalized Image of first Hologram

tic

%% Setup Constants
%
ext = '.tif';
z1 = 1E-3;
z2 = 6.5E-3;
zsteps = 1001;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 5.5E-6;
mag = 4.02;

maskflag = true;
createbackgroundflag = true;
backgroundfilerangeflag = true; backgroundfilerange = [1:300];
saveconstantsflag = true;
iminflag = false;


%% Create Background
%
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = double(imread(filesort(1).name));

if createbackgroundflag == true;

    if backgroundfilerangeflag == true

        background=avgbg('filename',['*',ext],'output','background','filerange',backgroundfilerange);
        
    else
        
        background=avgbg('filename',['*',ext],'output','background');
                
    end

else
    
    load('background.mat');
    
end

HOLO0001 = HOLO0001./background;
HOLO0001(isnan(HOLO0001)) = nanmean(HOLO0001(:));
HOLO0001(HOLO0001 > 4*mean(HOLO0001(:))) = mean(HOLO0001(:));

%% Create Mask
%
mask = ones(size(background));

if maskflag == true;
    
    mask(:,1:length(background)/2) = 0;
    
end

%% Get Imin of Normalized Image of first Hologram
%
if iminflag == true
    
    [Imin0001, zmap0001] = imin((HOLO0001),lambda/refractindex,linspace(z1,z2,zsteps),ps/mag,'mask',mask);
    
end

%% Save Constants
%
if saveconstantsflag == true;
    
    save(['imin0001constants.mat'],'ext','z1','z2','zsteps','lambda','refractindex','ps','mag','mask','Imin0001','HOLO0001');

end

%% Plot and Save Imin
%
figure

imagesc(Imin0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin0001 = (Imin0001 - min(Imin0001(:)))./(max(Imin0001(:)) - min(Imin0001(:)));

imwrite(uint8(Imin0001*255), 'Imin0001.png');

%% Plot and Save HOLO
%
figure

imagesc(HOLO0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

HOLO0001 = (HOLO0001 - min(HOLO0001(:)))./(max(HOLO0001(:)) - min(HOLO0001(:)));

imwrite(uint8(HOLO0001*255), 'HOLO0001.png');

%%
%
toc
