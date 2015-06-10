%% Get Normalized Image of first Hologram

tic
undock
%% Setup Constants
%
ext = '.tif';
z1 = -3.5E-3;
z2 =  3.5E-3;
zstepsize = 5E-6;
zsteps = 1+(z2-z1)/zstepsize;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 6.5E-6;
mag = 4;
zpad = 100;
cropflag = true; bottom = 2048; top = 1;
useHOLOnum = 2;
pauseflag = false;
maskflag = true;
vortflag = true;
createbackgroundflag = true;
backgroundfilerangeflag = true; backgroundfilerange = [1:2200];
saveconstantsflag = true;
iminflag = true;
bringtomeanflag = true;
z0 = 0;
z3 = 0;
z4 = 0;




%% Import Hologram
%
while useHOLOnum~=round(useHOLOnum) || useHOLOnum < 1 || useHOLOnum > 9999
    useHOLOnum = input('Invalid Hologram file number. Choose an integer between 1 and 9999: ');
end
useHOLOnumstr = num2str(useHOLOnum,'%04.0f');
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = (imread(filesort(useHOLOnum).name));

rect_xydxdy = ones(1,4); croparea = inf;
while rect_xydxdy(4) < croparea-1
    [~, rect_xydxdy] = imcrop(HOLO0001); rect_xydxdy = ceil(rect_xydxdy)

    croparea = input('How big do you want the cropped region (2048 default): ');
    toporbottom = input('Do you want to keep top or bottom? ','s');
     switch upper(toporbottom)
          
        case 'BOTTOM'
            top = rect_xydxdy(2)+rect_xydxdy(4)-croparea;
            bottom = -1+rect_xydxdy(2)+rect_xydxdy(4);
            rect_xydxdy = [top,top,croparea-1,croparea-1];
            
        case 'TOP'
            top = rect_xydxdy(2);
            bottom = -1+rect_xydxdy(2)+croparea;
            rect_xydxdy = [top,top,croparea-1,croparea-1];
         
        otherwise
            error(['Unexpected option: ' toporbottom])
     end
     
end

HOLO0001 = imcrop(HOLO0001,rect_xydxdy);

vortflag = input('Is there a Vorticella object? (y/n) ','s');
switch upper(vortflag)
    case 'Y'
        vortflag = true;
        [~, vortloc] = imcrop(HOLO0001); vortloc = ceil(vortloc);
        vortloc(3:4) = vortloc(3:4) + top - 1;
        
    case 'N'
        vortflag = false;
        
    otherwise
        error(['Unexpected option: ' vortflag])
end

HOLO0001 = double(HOLO0001);


%% Create Mask
%
zpad = 2*zpad + length(HOLO0001);
maskflag = input('Apply default mask? (y/n) ','s');
switch upper(maskflag)
    case 'Y'
        maskflag = true;
        mask = makemask(zpad, 'half');
        
    case 'N'
        maskflag = false;
        mask = 1;
        
    otherwise
        error(['Unexpected option: ' maskflag])
end


%% test zmax and zmin
%
testzmflag = true;
while testzmflag == true;
    imageprop(HOLO0001,lambda/refractindex,linspace(z1,z2,1+round((-1+zsteps)/40)),ps/mag,'mask',mask,'zpad',zpad,'real','imcrop',[256 256 1023 1023],'pause',1);
    imagepropagain = input('Do you want to run the video again? (y/n): ','s');
    switch upper(imagepropagain)
        case 'Y'
            testzmflag = true;
            z1 = input(['New z1(',num2str(z1),'): ']);
            z2 = input(['New z2(',num2str(z2),'): ']);
            zsteps = 1+(z2-z1)/zstepsize;
        case 'N'
            testzmflag = false;
        otherwise
            error(['Unexpected option: ' testzmflag])
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

imagesc(HOLO0001); colormap gray; colorbar; axis image; axis ij;title([useHOLOnumstr,pwd])

if pauseflag == true;
    
    pause;
    
end

HOLO0001norm = (HOLO0001 - min(HOLO0001(:)))./(max(HOLO0001(:)) - min(HOLO0001(:)));

imwrite(uint8(HOLO0001norm*255), ['HOLO',useHOLOnumstr,'.png']);


%% Get Imin of Normalized Image of first Hologram
%
if iminflag == false
        
    return
    
else
    
    [Imin0001, zmap0001] = imin((HOLO0001),lambda/refractindex,linspace(z1,z2,zsteps),ps/mag,'mask',mask,'zpad',zpad);
    
end

%% Save Constants
%
HOLO = HOLO0001;
Imin = Imin0001;
zmap = zmap0001;
if saveconstantsflag == true;
    
    save(['imin',useHOLOnumstr,'constants.mat'],'ext','z0','z1','z2','z3','z4','zsteps','zstepsize','lambda','refractindex','ps','mag','mask','Imin','zmap','HOLO','useHOLOnum','backgroundfilerangeflag','backgroundfilerange','cropflag','bottom','top','zpad','background','maskflag','vortflag','vortloc','bringtomeanflag','rect_xydxdy');

end

%% Plot and Save Imin
%
figure

imagesc(Imin0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin0001norm = (Imin0001 - min(Imin0001(:)))./(max(Imin0001(:)) - min(Imin0001(:)));

imwrite(uint8(Imin0001norm*255), ['Imin',useHOLOnumstr,'.png']);

%%
%
toc
