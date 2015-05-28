%% Get Normalized Image of first Hologram

tic

%% Setup Constants
%
ext = '.tif';
z1 = 0.7E-3;
z2 = 7.1E-3;
zsteps = 1001;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 6.5E-6;
mag = 4.02;
zpad = 100;

cropflag = true; bottom = 2040; top = 1;
useHOLOnum = '1500';
pauseflag = false;
maskflag = true;
createbackgroundflag = false;
backgroundfilerangeflag = true; backgroundfilerange = [1000:2000];
saveconstantsflag = true;
iminflag = true;
bringtomeanflag = false;



%% Create Background
%
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = double(imread(filesort(str2num(useHOLOnum)).name));

if createbackgroundflag == true;

    if backgroundfilerangeflag == true

        background=avgbg('filename',['*',ext],'output',['background',num2str(backgroundfilerange(1)),'to',num2str(backgroundfilerange(end))],'filerange',backgroundfilerange);
        
    else
        
        background=avgbg('filename',['*',ext],'output','background');
                
    end

else
    
    load('background.mat');
    
end

HOLO0001 = HOLO0001./background;
if cropflag == true
    HOLO0001 = imcrop(HOLO0001,[top,top,bottom-top,bottom-top]);
end
HOLO0001nozeros = HOLO0001; HOLO0001nozeros(HOLO0001nozeros==0)=NaN;

if bringtomeanflag == true
    HOLO0001(HOLO0001 > 2*nanmean(HOLO0001nozeros(:))) = nanmean(HOLO0001nozeros(:));
    HOLO0001(isnan(HOLO0001)) = nanmean(HOLO0001nozeros(:));
else
    HOLO0001(HOLO0001 > 2*nanmean(HOLO0001nozeros(:))) = 2*nanmean(HOLO0001nozeros(:));
    HOLO0001(isnan(HOLO0001)) = 0;
end

%% Plot and Save HOLO
%
figure

imagesc(HOLO0001); colormap gray; colorbar; axis image; axis ij;title([useHOLOnum,pwd])

if pauseflag == true;
    
    pause;
    
end

HOLO0001norm = (HOLO0001 - min(HOLO0001(:)))./(max(HOLO0001(:)) - min(HOLO0001(:)));

imwrite(uint8(HOLO0001norm*255), ['HOLO',useHOLOnum,'.png']);

%% Create Mask
%
zpad = 2*zpad + length(HOLO0001);

mask = ones(zpad);

if maskflag == true;
    
    mask(:,1:zpad/2) = 0;
    
end

%% Get Imin of Normalized Image of first Hologram
%
if iminflag == false
        
    return
    
else
    
    [Imin0001, zmap0001] = imin((HOLO0001),lambda/refractindex,linspace(z1,z2,zsteps),ps/mag,'mask',mask,'zpad',zpad);
    
end

%% Save Constants
%
if saveconstantsflag == true;
    
    save(['imin',useHOLOnum,'constants.mat'],'ext','z1','z2','zsteps','lambda','refractindex','ps','mag','mask','Imin0001','zmap0001','HOLO0001','useHOLOnum','backgroundfilerangeflag','backgroundfilerange','cropflag','bottom','top','zpad','background');

end

%% Plot and Save Imin
%
figure

imagesc(Imin0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin0001norm = (Imin0001 - min(Imin0001(:)))./(max(Imin0001(:)) - min(Imin0001(:)));

imwrite(uint8(Imin0001norm*255), ['Imin',useHOLOnum,'.png']);

%%
%
toc
