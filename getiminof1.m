%% Get Normalized Image of first Hologram

tic

%% Setup Constants
%
ext = '.tif';
z1 = -3E-3;
z2 =  3.5E-3;
zstepsize = 10E-6;
zsteps = 1+(z2-z1)/zstepsize;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 6.5E-6;
mag = 4;
zpad = 100;
cropflag = true; bottom = 2048; top = 1;
useHOLOnum = '0001';
pauseflag = false;
maskflag = true;
createbackgroundflag = true;
backgroundfilerangeflag = false; backgroundfilerange = [1000:2000];
saveconstantsflag = true;
iminflag = true;
bringtomeanflag = false;



%% Import Hologram
%
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = (imread(filesort(str2num(useHOLOnum)).name));

[~, rect_xydxdy] = imcrop(HOLO0001); rect_xydxdy = ceil(rect_xydxdy)

croparea = input('How big do you want the cropped region? ');
toporbottom = input('Do you want to keep top, bottom, left or right? ','s');
if toporbottom == 'bottom'
    top = rect_xydxdy(2)+rect_xydxdy(4)-croparea;
    bottom = -1+rect_xydxdy(2)+rect_xydxdy(4);
    rect_xydxdy = [top,top,croparea-1,croparea-1];
end

HOLO0001 = double(imcrop(HOLO0001,rect_xydxdy));


%% Create Mask
%
zpad = 2*zpad + length(HOLO0001);

if maskflag == true;
    
    mask = makemask(length(zpad), 'half');
    
end

%% test zmax and zmin
%
testzmflag = true;
while testzmflag == true;
    imageprop(HOLO0001,lambda/refractindex,linspace(z1,z2,1+round((-1+zsteps)/10)),ps/mag,'mask',mask,'real','imcrop',[256 256 1023 1023]);
    imagepropagain = input('Do you want to run the video again? (y/n): ','s');
    if imagepropagain == 'y'
        testzmflag = true;
        z1 = input(['New z1(',num2str(z1),'): ']);
        z2 = input(['New z2(',num2str(z2),'): ']);
        zsteps = 1+(z2-z1)/zstepsize;
    else
        testzmflag = false;
    end
end



%% Create Background
%
if createbackgroundflag == true;

    if backgroundfilerangeflag == true

        background=avgbg('filename',['*',ext],'output',['background',num2str(backgroundfilerange(1)),'to',num2str(backgroundfilerange(end))],'filerange',backgroundfilerange);
        
    else
        
        background=avgbg('filename',['*',ext],'output','background');
                
    end

else
    
    load('background.mat');
    
end

background = imcrop(background,rect_xydxdy);

HOLO0001 = HOLO0001./background;
% if cropflag == true
%     HOLO0001 = imcrop(HOLO0001,[top,top,bottom-top,bottom-top]);
% end
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
