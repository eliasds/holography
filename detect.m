function [Imin,zmap,constants,xyzLocCentroid,th,Xauto_min,Yauto_min,Zauto_min,Ein,background] = detect(varargin)
%% Detect - Find the minimum intensity of all images in folder, detect
%           particle locations, and saves all.
%           
%           Version 2.000
%
% Features:
%   Find Minimum Intensity:
%       Crop images to reduce processing time and improve reconstruction by
%           removing bordering objects
%       Run imin to detect minimum intensity, and save Imin and zmap
%   Detect Particle Positions in X-Y-Z-T:
%       Crop again to remove Fresnel boundary effects in Imin
%       (incomplete)**Automatically determine optimal threshold parameters
%       Threshhold and morphological operators
%       (incomplete)**Remove problematic regions (like vorticella)**
%       detect particle centers in Imin, use that for Z value, and saves


%% Method attempting to show dragable cropbox of 1024 or 2048
%
% I = imread('DH_0001.tif');
% figure
% imshow(I);
% waitforbuttonpress
% point1 = get(gca,'CurrentPoint') % button down detected
% rect_xydxdy = [point1(1,1) point1(1,2) 50 100];
% [r2] = dragrect(rect_xydxdy);
% J = imcrop(I, rect_xydxdy);
% figure,imshow(J),title('Cropped Image');
% 
% figure, imshow('pout.tif');
% h = imrect;
% position = wait(h);


%% List of Default Constants
%
tic

dirname = '';
filename    = 'DH_';
ext = 'tif';
backgroundfile = 'background.mat';
constantsfile = 'constants.mat';
createIminfilesflag = false;
runparticledetectionflag = true;
gpuflag = true;
particlevideoflag = true;
earlycropflag = true;
bringtomeanflag = true;
detectbestthreshflag = true;
thparam = 0.333;
histcutoff = 0.75;
try
    load([dirname,constantsfile])
catch
    disp('Trying one directory up')
    currentdir = pwd;
    cd ..;
    try
        load([dirname,constantsfile])
    catch
        cd currentdir;
        return
    end
end
thlevel = 0.2;
derstr = 'R8D5E4';
firstframe = 151;
lastframe = 'numfiles'; %Default lastframe value
lastframe = '250';
skipframes = 1; % skipframes = 1 is default
framerate = 10;
IminPathStr = 'matfiles\';
OutputPathStr = ['analysis-',datestr(now,'yyyymmdd'),'\'];
% maxint=2; %overide default max intensity: 2*mean(Imin(:))
% mag = 4; %Magnification
% ps = 5.5E-6; % Pixel Size in meters
% refractindex = 1.33;
% lambda = 632.8E-9; % Laser wavelength in meters
% z1=1.6E-3;
% z2=7.3E-3;
% zstepsize=5e-6;
% zsteps=1+(z2-z1)/zstepsize;
% vortloc=[1180, 2110, 2.7E-3]; %location of vorticella in "cuvette in focus"
% vortloc=[1535, 2105, 0]; %location of vorticella in "vort in focus"
% zpad=2048;
% radix2=2048;
% rect_xydxdy = [vortloc(1)-512,vortloc(2)-1024,1023,1023]; %for "cuvette in focus" data
% rect_xydxdy = [1550-512,2070-1024,1023,1023]; %for "vort in focus" data
% rect_xydxdy = [2560-radix2,2160-radix2,radix2-1,radix2-1]; %bottom right
% rect_xydxdy = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
% rect_xydxdy = [114,114,1800,1800]; %temp Cropping
% rect_xydxdy = [650-512,1865-1024,1023,1023];
% rect_xydxdy = [Xceil,Yceil,Xfloor-Xceil-1,Yfloor-Yceil-1];


%% Define varargin variables
%
while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'DERSTR'
            derstr = varargin{2};
            varargin(1:2) = [];
            
        case 'THLEVEL'
            thlevel = varargin{2};
            varargin(1:2) = [];
            
        case 'BACKGROUND'
            background = varargin{2};
            varargin(1:2) = [];
            
        case 'BACKGROUNDFILE'
            backgroundfile = varargin{2};
            varargin(1:2) = [];
            
        case 'FILENAME'
            filename = varargin{2};
            varargin(1:2) = [];
            
        case 'EARLYCROP'
            earlycropflag = true;
            varargin(1:2) = [];
            
        case 'CONSTANTS'
            constantsfile = varargin{2};
            load(constantsfile);
                if ~exist('rect_xydxdy','var')
                    if ~exist('rect','var')
                        rect_xydxdy = [1 1 n m];
                    else
                        rect_xydxdy = rect;
                        clear('rect');
                    end
                end
            disp(['NOW using Constants from ',constantsfile]);
            varargin(1:2) = [];
            
        case 'VIDEO'
            varargin(1) = [];
            particlevideoflag = true;
            % vidonflag = true;
            
        case 'FPS'
            framerate = varargin{2};
            varargin(1:2) = [];
            
        case 'LASTFRAME'
            lastframe = num2str(varargin{2});
            varargin(1:2) = [];
            
        case 'FIRSTFRAME'
            firstframe = varargin{2};
            varargin(1:2) = [];
            
        case 'IMINFLAGON'
            createIminfilesflag = true;
            varargin(1) = [];
            
        case 'IMINFLAGOFF'
            createIminfilesflag = false;
            varargin(1) = [];
            
        case 'DETECTFLAGON'
            runparticledetectionflag = true;
            varargin(1) = [];
            
        case 'DETECTFLAGOFF'
            runparticledetectionflag = false;
            varargin(1) = [];
            
        case 'GPUFLAGON'
            gpuflag = true;
            varargin(1) = [];
            
        case 'GPUFLAGOFF'
            gpuflag = false;
            varargin(1) = [];
            
        case 'BRINGTOMEAN'
            bringtomeanflag = true;
            varargin(1) = [];
            
        case 'THPARAM'
            thparam = varargin{2};
            varargin(1:2) = [];
            
        case 'HISTCUTOFF'
            histcutoff = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
            
    end
end


%% Turn off some warning messages:
%
% warning('off','images:imfindcircles:warnForLargeRadiusRange');
% warning('off','images:imfindcircles:warnForSmallRadius');


%% Setup secondary constants and variables
%
Z = linspace(z1,z2,zsteps);
loop = 0;
filename = strcat(dirname,filename);
filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);
numframes = floor((eval(lastframe) - firstframe + 1)/skipframes);
xyzLocCentroid(numframes).time=[];
% Eout(numfiles).time=[];
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end


% Constants to save
namesofconstants = {'lambda','mag','maxint','ps','refractindex','zsteps','zstepsize','thlevel','vortloc','z0','z1','z2','z3','z4','rect_xydxdy','top','bottom','mask'};


% Import Background file
varnam = who('-file',backgroundfile);
background = load(backgroundfile,varnam{1});
background = background.(varnam{1});
if gpuflag == true
    background = gpuArray(background);
end


% Add some default variables if they don't exist
if ~exist('rect_xydxdy','var')
    if ~exist('rect','var')
        rect_xydxdy = [1 1 size(background)-1];
    else
        eval('rect_xydxdy = rect;'); clear('rect');
    end
    top = 1;
    bottom = length(background);
end


% Determine maximum/mean intensity
if ~exist('maxint','var')
    Ein = (double(imread([filesort(1).name]))./background);
    % Ein = gather((double(imread([filesort(1).name]))));
    % Ein = gather(double(background));
    % Ein = gather((double(imread([filesort(1).name]))./double(imread([filesort(skipframes+1).name]))));
    if earlycropflag == true
        Ein = imcrop(Ein,[top,top,bottom-top,bottom-top]);
    end
    EinNoZeros = Ein; EinNoZeros(EinNoZeros==0)=NaN;
    maxint=2*nanmean(real(EinNoZeros(:)));
end


% Options for creating Imin files
if createIminfilesflag == true;
    % Create new output Imin/zmap directory
    if ~exist(IminPathStr, 'dir')
      mkdir(IminPathStr);
    end
    % Save the constants used for current Imin data (with Imin data)
    save([IminPathStr,'constants.mat'],namesofconstants{:});
end


% Particle detection options
if runparticledetectionflag == true
    % Create new output particle analysis directory
    if ~exist(OutputPathStr, 'dir')
        mkdir(OutputPathStr);
    end
    % Initialize movie file(s)
    if particlevideoflag==true
        threshmov(1:numframes) = struct('cdata',zeros(rect_xydxdy(4)+1,rect_xydxdy(3)+1,3,'uint8'),'colormap',[]);
    end
end



%% Create Imin MAT files and run Particle Detection together
%

wb = waitbar(0/numframes,'Analysing Data for Imin and Detecting Particles');

% Main loop
for L=firstframe:skipframes:eval(lastframe)
    loop = loop + 1;
    
    
    % Create Imin files
    if createIminfilesflag == true;
        
        % import data from tif files.
        % Ein = (double(imread([filesort(L).name])));o
        %     Holo = background;
        %     background = double(imread([filesort(L+skipframes).name]));
        %     Ein = Holo./background;
        Ein = (double(imread([filesort(L).name]))./background);
        % Ein = imcrop(Ein,rect_xydxdy);
        % Ein=Ein(vortloc(2)-radix2+1:vortloc(2),vortloc(1)-radix2/2:vortloc(1)-1+radix2/2);
        % Ein=Ein(1882-768:1882+255,1353-511:1353+512);
        % Ein = (double(background));
        % Ein(isnan(Ein)) = mean(background(:));
        % Ein(Ein>maxint)=maxint;
        
        % Crop large bordering objects (reduces 
        if earlycropflag == true
            Ein = imcrop(Ein,[top,top,bottom-top,bottom-top]);
        end
        EinNoZeros = Ein; EinNoZeros(EinNoZeros==0)=NaN;
        meanint = nanmean(EinNoZeros(:));
        maxint = 2*nanmean(EinNoZeros(:));
        if bringtomeanflag == true
            Ein(Ein > maxint) = meanint;
            Ein(isnan(Ein)) = meanint;
        else
            Ein(Ein > maxint) = maxint;
            Ein(isnan(Ein)) = 0;
        end

        % Save Imin and zmap files
        [Imin, zmap] = imin(Ein,lambda/refractindex,Z,ps/mag,'zpad',zpad,'mask',mask);
        save([IminPathStr,'\',filesort(L).firstname,'.mat'],'Imin','zmap','-v7.3');


        % The following 3 lines saves cropped and scaled region of Ein
        % Ein = Ein./maxint;
        % Ein = gather(Ein);
        % imwrite(Ein,[OutputPathStr,'\',filesort(L).name]);
        
    end

    
    
    
    
    % Detect particles
    if runparticledetectionflag == true;
        
        % Load data from Imin mat files if not just computed
        if createIminfilesflag == false;
            load([IminPathStr,filesort(L).firstname,'.mat']);
        end
        
        % Detect Best Imin Threshold Level
        if detectbestthreshflag == true;
            thlevel = bestthresh( Imin, thparam, histcutoff );
        end
        
        % Secondary crop to remove Fresnel boudary effects
        Imin=imcrop(Imin,rect_xydxdy);
        zmap=imcrop(zmap,rect_xydxdy);

        % Detect Particles and Save
        [Xauto_min,Yauto_min,Zauto_min,th,th1,th2,th3] = detection(Imin, zmap, thlevel, derstr);
        xyzLocCentroid(loop).time=[Xauto_min;Yauto_min;Zauto_min]';
        
        % Add 2D particle threshold video data to struct
        if particlevideoflag==true
            threshmov(loop).cdata = uint8(th(1:1024,1:1024))*255;
            threshmov(loop).cdata(:,:,2) = threshmov(loop).cdata(:,:,1);
            threshmov(loop).cdata(:,:,3) = threshmov(loop).cdata(:,:,1);
        end

    end
    
    
    waitbar(loop/numframes,wb);
end


%% Wrap up the analysis
%
Ein=gather(Ein);
background=gather(background);
maxint=gather(maxint);
close(wb);
% Create struct containing all constants
for L = 1:length(namesofconstants)
    constants.(namesofconstants{L}) = eval(namesofconstants{L});
end


% Save particle information
daytimenow = datestr(now,'yyyymmddHHMMSS');
particlefilename = [OutputPathStr,filename(1:end-1),'-th',strrep(num2str(thlevel/10,'%1.1E'),'.',''),'_derstr',derstr,'_day',daytimenow];
% Save particle position data
if runparticledetectionflag == true;
    save([particlefilename,'.mat'], 'xyzLocCentroid')
    save([particlefilename,'constants.mat'],namesofconstants{:});
    
    % Save 2D particle threshold video
    if particlevideoflag==true
        writerObj = VideoWriter([particlefilename,'_2DthresholdVideo'],'MPEG-4');
        writerObj.FrameRate = framerate;
        open(writerObj);
        writeVideo(writerObj,threshmov);
        close(writerObj);
    end

end



toc
end



