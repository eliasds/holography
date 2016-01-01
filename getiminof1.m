%% Get Normalized Image of first Hologram

tic
dock
%% Setup Constants
%
ext = '.tiff';
z1 = 1.75E-3;
z2 =  7.75E-3;
zstepsize = 5E-6;
zsteps = 1+(z2-z1)/zstepsize;
lambda = 632.8E-9;
refractindex = 1.33;
ps = 5.5E-6;
mag = 4;
zpad = 200;
useHOLOnum = 1;
cropflag = true; bottom = 2048; top = 1;
pauseflag = false;
maskflag = true;
mask = 1;
% mask = mask;
vortflag = true;
vortloc = NaN;
createbackgroundflag = true;
backgroundfilerangeflag = false;
backgroundfilerange = [400:2600];
iminflag = true;
bringtomeanflag = false;
maskfile = nan;

z0 = 0;
z3 = 0;
z4 = 0;
% derstr = 0;
% thparam = 0.4;
% thlevel = 0;


% Constants to save
namesofconstants = {'ext','z0','z1','z2','z3','z4','zsteps','zstepsize','lambda','refractindex','ps','mag','mask','Imin','zmap','HOLO','useHOLOnum','backgroundfilerangeflag','backgroundfilerange','cropflag','bottom','top','zpad','background','maskflag','masktype','maskfile','vortflag','vortloc','bringtomeanflag','rect_xydxdy'};


%% Import Hologram
%
while useHOLOnum~=round(useHOLOnum) || useHOLOnum < 1 || useHOLOnum > 9999
    useHOLOnum = input('Invalid Hologram file number. Choose an integer between 1 and 9999: ');
end
useHOLOnumstr = num2str(useHOLOnum,'%04.0f');
filesort = dir(['*',ext]);

numfiles = numel(filesort);

HOLO0001 = (imread(filesort(useHOLOnum).name));

rect_xydxdy = [1 1 size(HOLO0001)-1];
croparea = length(HOLO0001)+1;
wouldyouliketocrop = true;
wouldyouliketocropinput = input('Would you like to crop a region of interest? (y/n): ','s');
switch upper(wouldyouliketocropinput)
    case 'N'
        wouldyouliketocrop = false;
    case 'Y'
        wouldyouliketocrop = true;
    otherwise
        rect_xydxdy = str2num(wouldyouliketocropinput);
        wouldyouliketocrop = false;
end
while wouldyouliketocrop == true && rect_xydxdy(4) < croparea-1
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
        figure;
        [~, vortloc] = imcrop(HOLO0001); vortloc = ceil(vortloc);
        vortloc(3:4) = vortloc(3:4) + top - 1;
%         vortloc = [891 1859 140 124];
        
    case 'N'
        vortflag = false;
        
    otherwise
        error(['Unexpected option: ' vortflag])
end

HOLO0001 = double(HOLO0001);


%% Create Mask
%
zpad = 2*zpad + length(HOLO0001);
maskflag = input('Apply a Fourier Tansform aperture mask? (y/n) ','s');
switch upper(maskflag)
    case 'Y'
        maskflag = true;
        masktype = input('Which mask do you want to use? ("KNIFE", "OPEN", "FILE", "VAR", etc.) ','s');
        switch upper(masktype)
            case 'FILE'
                maskfile = input('File name: ','s');
                mask = makemask(zpad, masktype, maskfile);
                
            case 'VAR'
                maskfile = input('Local variable name: ','s');
                mask = makemask(zpad, masktype, eval(maskfile));
                
            otherwise
                mask = makemask(zpad, masktype);
%                 mask = imresize(mask,[zpad,zpad],'nearest');
                
        end
    case 'N'
        maskflag = false;
    otherwise
        error(['Unexpected option: ' maskflag])
end

%% Create Background
%

if createbackgroundflag == true && exist('.\background.mat', 'file') > 0
    overwritebackground = input('Are you sure you want to overwrite background.mat? (y/n) ','s');
    switch upper(overwritebackground)
        case 'Y'
            createbackgroundflag = true;

        case 'N'
            createbackgroundflag = false;

        otherwise
            error(['Unexpected option: ' vortflag])
    end
end

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

HOLO0001nozeros = HOLO0001; HOLO0001nozeros(HOLO0001nozeros==0)=NaN;

if bringtomeanflag == true
    HOLO0001(HOLO0001 > 2*nanmean(HOLO0001nozeros(:))) = nanmean(HOLO0001nozeros(:));
    HOLO0001(isnan(HOLO0001)) = nanmean(HOLO0001nozeros(:));
else
    HOLO0001(HOLO0001 > 2*nanmean(HOLO0001nozeros(:))) = 2*nanmean(HOLO0001nozeros(:));
    HOLO0001(isnan(HOLO0001)) = 0;
end



%% test zmax and zmin
%
testzmflag = true;
bigzsteps = 1+round((-1+zsteps)/40);
if bigzsteps < 15
    bigzsteps = 30;
end

imagepropagain = input('Do you want to step through z? (y/n): ','s');
switch upper(imagepropagain)
    case 'N'
        testzmflag = false;
end
    
while testzmflag == true;
    figure(7312)
    imageprop(HOLO0001,lambda/refractindex,linspace(z1,z2,bigzsteps),ps/mag,'mask',mask,'zpad',zpad,'real','imcrop',[256 256 1023 1023],'pause',1);
    imagepropagain = input('Do you want to run the video again? (y/n): ','s');
    switch upper(imagepropagain)
        case 'Y'
            testzmflag = true;
            lastz1 = z1;
            lastz2 = z2;
            z1 = input(['New z1(',num2str(lastz1),'): ']);
            z2 = input(['New z2(',num2str(lastz2),'): ']);
            if isempty(z1);
                z1 = lastz1;
            end
            if isempty(z2);
                z2 = lastz2;
            end
            zsteps = 1+(z2-z1)/zstepsize;
        case 'N'
            testzmflag = false;
        otherwise
            error(['Unexpected option: ' testzmflag])
    end
end

% if cropflag == true
%     HOLO0001 = imcrop(HOLO0001,[top,top,bottom-top,bottom-top]);
% end

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
save(['imin',useHOLOnumstr,'constants.mat'],namesofconstants{:});


%% Plot and Save Imin
%
figure

imagesc(Imin0001); colormap gray; colorbar; axis image; axis ij;title(pwd)

Imin0001norm = (Imin0001 - min(Imin0001(:)))./(max(Imin0001(:)) - min(Imin0001(:)));

imwrite(uint8(Imin0001norm*255), ['Imin',useHOLOnumstr,'.png']);

%%
%
toc
dock