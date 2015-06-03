% crop images first to reduce processing time (or later to increase presision)
% imin to detect minimum intensity
% save Imin and zmap
% crop now if cropping wasn't performed earlier
% threshhold and morphological operators
% remove problematic regions (like vorticella)
% detect particle centers
% save

%% Method attempting to show dragable cropbox of 1024 or 2048

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


%% PD_IMINSAVE_GPU - Find the minimum intensity of all images in folder and saves them
% 
% Version 1.0


clear all
tic

dirname = '';
filename    = 'DH_';
ext = 'tif';
backgroundfile = 'background.mat';
createIminfilesflag = false;
runparticledetectionflag = true;
gpuflag = true;
vidonflag = false;
cropflag = true;
bringtomeanflag = true;
load([dirname,'constants.mat'])
thlevel = 0.2;
derstr = 'R8D5E4';
firstframe = 101;
lastframe = 'numfiles'; %Default lastframe value
lastframe = '300';
skipframes = 1; % skipframes = 1 is default
framerate = 10;
IminPathStr = 'matfiles';
OutputPathStr = ['analysis-',num2str(year(date)),num2str(month(date),'%05.2u'),num2str(day(date),'%05.2u')];
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


Z=linspace(z1,z2,zsteps);    

%% Turn off these warning messages:
% warning('off','images:imfindcircles:warnForLargeRadiusRange');
% warning('off','images:imfindcircles:warnForSmallRadius');


%% List raw image filenames
filename = strcat(dirname,filename);
filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);
numframes = floor((eval(lastframe) - firstframe + 1)/skipframes);
xyzLocCentroid(numframes).time=[];
Eout(numfiles).time=[];
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

%% Import Background file
varnam=who('-file',backgroundfile);
background=load(backgroundfile,varnam{1});
background=background.(varnam{1});
if gpuflag == true
    background=gpuArray(background);
end

%% Create new output directories
if ~exist(OutputPathStr, 'dir')
  mkdir(OutputPathStr);
end

if ~exist(IminPathStr, 'dir')
  mkdir(IminPathStr);
end

%% Add some default variables if they don't exist
if ~exist('rect_xydxdy','var')
    if ~exist('rect','var')
        rect_xydxdy = [1 1 size(background)-1];
    else
        eval('rect_xydxdy = rect;'); clear('rect');
    end
    top = 1;
    bottom = length(background);
end

%% Initialize movie file
mov(1:numframes) = struct('cdata',zeros(rect_xydxdy(4)+1,rect_xydxdy(3)+1,3,'uint8'),'colormap',[]);

Ein = (double(imread([filesort(1).name]))./background);
% Ein = gather((double(imread([filesort(1).name]))));
% Ein = gather(double(background));
% Ein = gather((double(imread([filesort(1).name]))./double(imread([filesort(skipframes+1).name]))));
if cropflag == true
    Ein = imcrop(Ein,[top,top,bottom-top,bottom-top]);
end
EinNoZeros = Ein; EinNoZeros(EinNoZeros==0)=NaN;
if ~exist('maxint','var')
    maxint=2*nanmean(real(EinNoZeros(:)));
end





%% Determine optimal threshold (thlevel) from first Imin
%{
% Holo_0001 = (double(imread([filesort(L).name]))./background);
% [Imin_0001, ~] = imin(Holo_0001,lambda/refractindex,Z,ps/mag,zpad);
Imin0001 = imcrop(Imin,rect_xydxdy);
nbins = round(sqrt(numel(Imin0001)));
[bincount,edges] = histcounts(Imin0001(:),nbins);
figure(6);histogram(Imin0001(:),nbins)
nbins=500;
bincount = bincount(1:nbins);
edges = edges(1:nbins);
[M I] = min(bincount(1:nbins))
figure(7);plot(edges,bincount)
I2 = round(I/2);
th_new = edges(I2)
axis([0,max(edges),0,5000]);

figure(10);bincount6 = smooth(bincount,'lowess');plot(edges,bincount6)
[M I] = min(bincount6(1:nbins))
I2 = round(I/10);
th_new = edges(I2)
axis([0,max(edges),0,5000]);
%}

%% Create Imin MAT files and run Particle Detection together
%

save([IminPathStr,'/','constants.mat'], 'lambda', 'mag', 'maxint',...
    'ps', 'refractindex', 'zsteps', 'zstepsize', 'thlevel', 'vortloc',...
    'z0', 'z1', 'z2', 'z3', 'z4','rect_xydxdy','top','bottom')

loop = 0;
wb = waitbar(0/numframes,'Analysing Data for Imin and Detecting Particles');
for L=firstframe:skipframes:eval(lastframe)
    loop = loop + 1;
    if createIminfilesflag == true;
        % import data from tif files.
        % Ein = (double(imread([filesort(L).name])));o
    %     Holo = background;
    %     background = double(imread([filesort(L+skipframes).name]));
    %     Ein = Holo./background;
        Ein = (double(imread([filesort(L).name]))./background);
    %     Ein = imcrop(Ein,rect_xydxdy);
        % Ein=Ein(vortloc(2)-radix2+1:vortloc(2),vortloc(1)-radix2/2:vortloc(1)-1+radix2/2);
        %Ein=Ein(1882-768:1882+255,1353-511:1353+512);
        %Ein = (double(background));
        %Ein(isnan(Ein)) = mean(background(:));
%         Ein(Ein>maxint)=maxint;
        
        if cropflag == true
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

        [Imin, zmap] = imin(Ein,lambda/refractindex,Z,ps/mag,'zpad',zpad,'mask',mask);
        save([IminPathStr,'\',filesort(L).firstname,'.mat'],'Imin','zmap','-v7.3');


        % The following 3 lines saves cropped and scaled region of Ein
    %     Ein = Ein./maxint;
    %     Ein = gather(Ein);
    %     imwrite(Ein,[OutputPathStr,'\',filesort(L).name]);
    end

    if runparticledetectionflag == true;
        if createIminfilesflag == false;
            % load data from mat files.
            load([IminPathStr,'/',filesort(L).firstname,'.mat']);
        end
        
        
        Imin=imcrop(Imin,rect_xydxdy);
        zmap=imcrop(zmap,rect_xydxdy);

        % 
        %% Detect Particles and Save
        [Xauto_min,Yauto_min,Zauto_min,th,th1,th2,th3] = detection(Imin, zmap, thlevel, derstr);
        xyzLocCentroid(loop).time=[Xauto_min;Yauto_min;Zauto_min]';
        
            if vidonflag==true
                mov(loop).cdata = uint8(th3(1:1024,1:1024))*255;
                mov(loop).cdata(:,:,2) = mov(loop).cdata(:,:,1);
                mov(loop).cdata(:,:,3) = mov(loop).cdata(:,:,1);
            end

    end
    waitbar(loop/numframes,wb);
end

Ein=gather(Ein);
background=gather(background);
maxint=gather(maxint);
close(wb);
if runparticledetectionflag == true;
    save([OutputPathStr,'\',filename(1:end-1),'-th',num2str(thlevel,'%10.0E'),'_dernum',[num2str(dilaterode(1),2),'-',num2str(dilaterode(2),2)],'_day',num2str(round(now*1E5)),'.mat'], 'xyzLocCentroid')
    save([OutputPathStr,'\',filename(1:end-1),'-th',num2str(thlevel,'%10.0E'),'_dernum',[num2str(dilaterode(1),2),'-',num2str(dilaterode(2),2)],'_day',num2str(round(now*1E5)),'constants.mat'], 'lambda', 'mag', 'maxint',...
        'ps', 'refractindex', 'zsteps', 'zstepsize', 'thlevel', 'vortloc',...
        'z0', 'z1', 'z2', 'z3', 'z4','rect_xydxdy','top','bottom')
end

if vidonflag==true
    writerObj = VideoWriter([OutputPathStr,'\',filename(1:end-1),'-th',num2str(thlevel,'%10.0E'),'_dernum',[num2str(dilaterode(1),2),'-',num2str(dilaterode(2),2)],'_day',num2str(round(now*1E5)),'_2DthresholdVideo'],'MPEG-4');
    writerObj.FrameRate = framerate;
    open(writerObj);
    writeVideo(writerObj,mov);
    close(writerObj);
end

toc



