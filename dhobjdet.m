function [Imin,zmap,constants,xyzLoc,particlefilename,th,th_all,Xauto,Yauto,Zauto,Ein,background,threshmov] = dhobjdet(varargin)
%% dhobjdet - Digital Holography Object Detect:
%             Find the minimum intensity of all images in folder, detect
%             particle locations, and saves all.
%           
%             Daniel Shuldman <elias.ds@gmail.com>
%             Version 2.100
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
%
% Options:
%         DERSTR
%         THLEVEL
%         BACKGROUND
%         BACKGROUNDFILE
%         FILENAME
%         EARLYCROP
%         LATECROP
%         CONSTANTS
%         VIDEO
%         FPS
%         LASTFRAME
%         FIRSTFRAME
%         SKIPFRAMES
%         IMINFLAGON
%         IMINFLAGOFF
%         DETECTFLAGON
%         DETECTFLAGOFF
%         GPUFLAGON
%         GPUFLAGOFF
%         BRINGTOMEAN
%         THPARAM
%         MINMEAN


%% List of Default Constants
%
tic

dirname = '';
filename    = 'Basler_';
ext = 'tiff';
backgroundfile = 'background.mat';
constantsfile = 'constants.mat';
createIminfilesflag = false;
runparticledetectionflag = true;
gpuflag = true;
particlevideoflag = true;
earlycropflag = false;
earlycropregion = [0 0 0 0];
detectcropflag = false;
bringtomeanflag = false;
detectbestthreshflag = true;
greyoutflag = false;
greyoutregion = [0 0 0 0];
resizeflag = false;
resizeval = 4;
% maxint=2; %overide default max intensity: 2*mean(Imin(:))
% mag = 4; %Magnification
% ps = 5.5E-6; % Pixel Size in meters
% refractindex = 1.33;
% lambda = 632.8E-9; % Laser wavelength in meters
z1=1.6E-3;
z2=7.3E-3;
zstepsize=5e-6;
zsteps=1+(z2-z1)/zstepsize;
top = 1;
bottom = 1024;
rect_xydxdy = [1,1,1023,1023];
thlevel = 0.2;
thparam = 0.333;
derstr = 'R8D5E4';
minmean = 'MIN';
firstframe = 1;
lastframenumfiles = true;
% lastframe = '250';
skipframes = 1; % skipframes = 1 is default
framerate = 20;
IminPathStr = 'iminfiles\';
OutputPathStr = ['analysis-',datestr(now,'yyyymmdd'),'\'];
clear xyzLoc

try
    load([dirname,constantsfile])
catch
    disp('There is no constants.mat file in this directory.')
    exitearly = input('Would you like to continue with default parameters? (y/n): ','s');
    if isequal(upper(exitearly),'Y')
    else
        error('Exiting Function')
    end
end




%% Define varargin variables
%
while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'DERSTR'
            derstr = varargin{2};
            varargin(1:2) = [];
            
        case 'THLEVEL'
            detectbestthreshflag = false;
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
            [dirname, filename, ext] = fileparts(filename);
            varargin(1:2) = [];
            
        case 'EARLYCROP'
            earlycropflag = true;
            earlycropregion = varargin{2};
            varargin(1:2) = [];
            
        case {'DETECTIONCROP','LATECROP'}
            detectcropflag = true;
            if numel(varargin{2}) ~= 4
                rect_xydxdy_copy = [(varargin{2}(1:2)), 1023,1023];
            else
                rect_xydxdy_copy = [varargin{2}];
            end
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
            lastframenumfiles = false;
            lastframe = varargin{2};
            varargin(1:2) = [];
            
        case 'FIRSTFRAME'
            firstframe = varargin{2};
            varargin(1:2) = [];
            
        case 'SKIPFRAMES'
            skipframes = varargin{2};
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
            detectbestthreshflag = true;
            thparam = varargin{2};
            varargin(1:2) = [];
            
        case 'MINMEAN'
            minmean = varargin{2};
            varargin(1:2) = [];
            
        case 'RESIZE'
            resizeflag = true;
            resizeval = varargin{2};
            varargin(1:2) = [];
            
        case 'GREYOUT'
            greyoutflag = true;
            greyoutregion = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
            
    end
end

%% Setup secondary constants and variables
%
% Constants to save
namesofconstants = {'xyzLoc','OutputPathStr','particlefilename','lambda','mag','maxint','ps','refractindex','zsteps','zstepsize','thlevel','vortloc','z0','z1','z2','z3','z4','rect_xydxdy','top','bottom','mask','derstr','thparam','th','th_all','minmean','earlycropregion','earlycropflag','detectcropflag','greyoutregion','greyoutflag'};
[~,nocorder] = sort(lower(namesofconstants));
namesofconstants = namesofconstants(nocorder);


Z = linspace(z1,z2,zsteps);
loop = 0;


% List files to import
filename = strcat(dirname,filename);
filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);
if lastframenumfiles == true
    lastframe = numfiles;
end
numframes = floor((lastframe - firstframe + 1)/skipframes);
xyzLoc(numframes).time=[];
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end
% Import Hologram file
HoloFile = [filesort(1, 1).name];
varnam = who('-file',HoloFile);

% Change Default Crop Parameters
if detectcropflag == true
    rect_xydxdy = rect_xydxdy_copy;
%     earlycropregion = [top,top,bottom-top,bottom-top];
end


% Determine maximum/mean intensity
if ~exist('maxint','var')
    Ein = load([filesort(L, 1).name],varnam{1});
    Ein = Ein.(varnam{1});
    if earlycropflag == true
        Ein = imcrop(Ein,earlycropregion);
%         Ein = imcrop(Ein,[top,top,bottom-top,bottom-top]);
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
for L=firstframe:skipframes:lastframe
    loop = loop + 1;
    
    
    % Create Imin files
    if createIminfilesflag == true;
        
        if isequal(ext,'.mat')
            % import data from *.mat files.
            Ein = load([filesort(L, 1).name],varnam{1});
            Ein = Ein.(varnam{1});
        else
            % import data from *.tif files.
            Ein = (double(imread([filesort(L, 1).name])));
            Ein = Holo./background;
        end
        
        if greyoutflag == true; %Remove problem regions like Vorticella
            [m2,~] = size(greyoutregion);
            for L2 = 1:m2
                Ein(greyoutregion(L2,2):greyoutregion(L2,2)+greyoutregion(L2,4)+1,greyoutregion(L2,1):greyoutregion(L2,1)+greyoutregion(L2,3)+1) = mean(Ein(:));
            end
        end
        
        % Crop large bordering objects (reduces 
        if earlycropflag == true
            Ein = imcrop(Ein,earlycropregion);
        end
        
        % Normalize Image and Remove NaNs
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

        
        if resizeflag == true
            Ein = imresize(Ein,resizeval);
        end
        
        % Save Imin and zmap files
        if gpuflag == true;
            [Imin, zmap] = imin(Ein,lambda/refractindex,Z,ps/mag,'zpad',zpad,'mask',mask);
        else
            [Imin, zmap] = imin(Ein,lambda/refractindex,Z,ps/mag,'cpu','zpad',zpad,'mask',mask);
        end
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
            thlevel = bestthresh( Imin, thparam );
        end
        
        % Secondary crop to remove Fresnel boundary effects
        Imin=imcrop(Imin,rect_xydxdy);
        zmap=imcrop(zmap,rect_xydxdy);

        % Detect Particles and Save
        [Xauto,Yauto,Zauto,th,th_all] = detection3(Imin, zmap, thlevel, derstr, minmean);
        xyzLoc(loop).time = [Xauto*ps/mag;Yauto*ps/mag;Zauto]';
        
        % Add 2D particle threshold video data to struct
        if particlevideoflag == true
            threshmov(loop).cdata = uint8(imresize(th,[512 512]))*255;
            threshmov(loop).cdata(:,:,2) = threshmov(loop).cdata(:,:,1);
            threshmov(loop).cdata(:,:,3) = threshmov(loop).cdata(:,:,1);
        end

    end
    
    
    waitbar(loop/numframes,wb);
end


%% Wrap up the analysis
%
% Ein=gather(Ein);
% background=gather(background);
maxint=gather(maxint);
close(wb);


% Save constants and particle information
daytimenow = datestr(now,'yyyymmddHHMMSS');
particlefilename = [filename(1:end-1),'-th',strrep(num2str(thlevel/10,'%1.1E'),'.',''),'_derstr',derstr,'_day',daytimenow];
% Create struct containing all constants
for L = 1:length(namesofconstants)
    constants.(namesofconstants{L}) = eval(namesofconstants{L});
end
if runparticledetectionflag == true;
    save([OutputPathStr,particlefilename,'.mat'],namesofconstants{:})
end
if createIminfilesflag == true;
    % Save the constants used for current Imin data (with Imin data)
    save([IminPathStr,'constants.mat'],namesofconstants{:});
end
    
% Save 2D particle threshold video
if runparticledetectionflag == true && particlevideoflag == true
    writerObj = VideoWriter([OutputPathStr,particlefilename,'_2DthresholdVideo'],'MPEG-4');
    writerObj.FrameRate = framerate;
    open(writerObj);
    writeVideo(writerObj,threshmov);
    close(writerObj);
end



toc2

end


