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
% rect = [point1(1,1) point1(1,2) 50 100];
% [r2] = dragrect(rect);
% J = imcrop(I, rect);
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
filename    = 'Basler_acA2040-25gm_';
ext = 'tiff';
backgroundfile = 'background.mat';
createIminfilesflag = false;
runparticledetectionflag = true;
% mag = 4; %Magnification
% ps = 5.5E-6; % Pixel Size in meters
% refractindex = 1.33;
% lambda = 632.8E-9; % Laser wavelength in meters
% z1=1.6E-3;
% z2=7.3E-3;
% stepsize=5e-6;
% steps=1+(z2-z1)/stepsize;
% vortloc=[1180, 2110, 2.7E-3]; %location of vorticella in "cuvette in focus"
% vortloc=[1535, 2105, 0]; %location of vorticella in "vort in focus"
% thlevel = 0.0005;
dilaterode = [3,8];
derstr = 'D1E0R8D1D1';
% zpad=2048;
% radix2=2048;
firstframe = 1;
lastframe = 'numfiles';
% lastframe = '300';
skipframes = 1; % skipframes = 1 is default
% IminPathStr = 'matfiles-5imgBG';
IminPathStr = 'matfiles';
OutputPathStr = 'analysis-20150414';
% maxint=2; %overide default max intensity: 2*mean(Imin(:))
% test=1;
load([dirname,'constants.mat'])
% thlevel = 0.08;

Z=linspace(z1,z2,steps);
% rect = [vortloc(1)-512,vortloc(2)-1024,1023,1023]; %for "cuvette in focus" data
% rect = [1550-512,2070-1024,1023,1023]; %for "vort in focus" data
% rect = [2560-radix2,2160-radix2,radix2-1,radix2-1]; %bottom right
% rect = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
% rect = [1,1,2047,2047]; %temp Cropping
% rect = [650-512,1865-1024,1023,1023];
% rect = [Xceil,Yceil,Xfloor-Xceil-1,Yfloor-Yceil-1];

% ps = ps / mag; % Effective Pixel Size in meters
% lambda = lambda / refractindex; % Effective laser wavelength in meters

% 
% warning('off','images:imfindcircles:warnForLargeRadiusRange');
% warning('off','images:imfindcircles:warnForSmallRadius');



%% Create Dilate and Erode Parameters
for L = 1:numel(dilaterode)
    eval(['disk',int2str(L-1),' = morphshape(dilaterode(L));'])
%     disk{L} = morphshape(dilaterode(L)); % more efficient code
end


%%
filename = strcat(dirname,filename);
filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);
numframes = floor((eval(lastframe) - firstframe + 1)/skipframes);
LocCentroid(numframes).time=[];
Eout(numfiles).time=[];
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end


%
varnam=who('-file',backgroundfile);
background=load(backgroundfile,varnam{1});
background=gpuArray(background.(varnam{1}));

if ~exist(OutputPathStr, 'dir')
  mkdir(OutputPathStr);
end

if ~exist(IminPathStr, 'dir')
  mkdir(IminPathStr);
end


% for L=1:1:numfiles
% %     Holo = imread([filesort(L).name]);
%     Holo = double(gpuArray(imread([filesort(L).name])))./background;
%     Ein = imcrop(Holo,rect);
%     maxint = 2*mean(Ein(:));
%     Ein(Ein>maxint) = maxint;
%     Ein = Ein./maxint;
%     Ein = gather(Ein);
%     imwrite(Ein,['1024\',filesort(L).name]);
% end

%

Ein = gather((double(imread([filesort(1).name]))./background));
% Ein = gather((double(imread([filesort(1).name]))));
% Ein = gather(double(background));
% Ein = gather((double(imread([filesort(1).name]))./double(imread([filesort(skipframes+1).name]))));
if ~exist('maxint','var')
    maxint=2*mean(real(Ein(:)));
end

if exist('test','var')
    numfiles=test;
end



%% Determine optimal threshold (thlevel) from first Imin
%{
% Holo_0001 = (double(imread([filesort(L).name]))./background);
% [Imin_0001, ~] = imin(Holo_0001,lambda/refractindex,Z,ps/mag,zpad);
Imin0001 = imcrop(Imin,rect);
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
    'ps', 'refractindex', 'steps', 'stepsize', 'thlevel', 'vortloc',...
    'z0', 'z1', 'z2', 'z3', 'z4')

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
    %     Ein = imcrop(Ein,rect);
        % Ein=Ein(vortloc(2)-radix2+1:vortloc(2),vortloc(1)-radix2/2:vortloc(1)-1+radix2/2);
        %Ein=Ein(1882-768:1882+255,1353-511:1353+512);
        %Ein = (double(background));
        %Ein(isnan(Ein)) = mean(background(:));
        Ein(Ein>maxint)=maxint;

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
        
        Imin=imcrop(Imin,rect);
        zmap=imcrop(zmap,rect);

        % 
        %% Detect Particles and Save
        [Xauto_min,Yauto_min,Zauto_min] = detection(Imin, zmap, thlevel, disk0, disk1, derstr);
        LocCentroid(loop).time=[Xauto_min;Yauto_min;Zauto_min]';
    end
    waitbar(loop/numframes,wb);
end

Ein=gather(Ein);
background=gather(background);
maxint=gather(maxint);
close(wb);
if runparticledetectionflag == true;
    save([OutputPathStr,'\',filename(1:end-1),'-th',num2str(thlevel,'%10.0E'),'_dernum',[num2str(dilaterode(1),2),'-',num2str(dilaterode(2),2)],'_day',num2str(round(now*1E5)),'.mat'], 'LocCentroid')
end
toc
%}


%% Create Imin MAT files only
%{

save([IminPathStr,'/','constants.mat'], 'lambda', 'mag', 'maxint',...
    'ps', 'refractindex', 'steps', 'stepsize', 'thlevel', 'vortloc',...
    'z0', 'z1', 'z2', 'z3', 'z4')

loop = 0;
wb = waitbar(0/numframes,'Analysing Data for Imin');
for L=firstframe:skipframes:eval(lastframe)
    loop = loop + 1;
    % import data from tif files.
    % Ein = (double(imread([filesort(L).name])));
    Ein = (double(imread([filesort(L).name]))./background);
    Ein = imcrop(Ein,rect);
    %Ein = (double(background));
    %Ein(isnan(Ein)) = mean(background(:));
    Ein(Ein>maxint)=maxint;

    
    [Imin, zmap] = imin(Ein,lambda/refractindex,Z,ps/mag,zpad);
    save([IminPathStr,'\',filesort(L).firstname,'.mat'],'Imin','zmap','-v7.3');
    
    
    % The following 3 lines saves cropped and scaled region of Ein
%     Ein = Ein./maxint;
%     Ein = gather(Ein);
%     imwrite(Ein,[OutputPathStr,'\',filesort(L).name]);


    waitbar(loop/numframes,wb);
end

Ein=gather(Ein);
background=gather(background);
maxint=gather(maxint);
close(wb);
toc
%}

% %% Thresholding and Morphological Operators
% %
% function [Xauto,Yauto,Zauto_centroid,Zauto_mean,Zauto_min] = detection(Imin, zmap, thlevel, dilaterode);
% th = Imin<thlevel;
% disk1 = strel('disk', dilatenum, 0);
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = bwlabel(th,4);
% autodetstruct = regionprops(th,'Centroid','PixelIdxList');
% xy = [autodetstruct.Centroid];
% Xauto = xy(1:2:end);
% Yauto = xy(2:2:end);
% 
% %Linear Interpolation Method, using 4 pixels nearest centroid(X-Y) to
% %determine z-depth. more acurate centroid method
% Zauto_centroid = interp2(1:size(zmap,2),1:size(zmap,1),zmap,Xauto,Yauto);
% 
% %Determine mean Z-value from all pixels in region (biasing errors)
% Zauto_mean=zeros(size(Xauto));
% 
% %Depth of Minimum intensity pixel
% Zauto_min=zeros(size(Xauto));
% for i = 1:numel(autodetstruct)
%     idx = autodetstruct(i).PixelIdxList;
%     Zauto_mean(i) = mean(zmap(idx));
%     
%     particlepixels = Imin(idx);
%     [~,minidx] = min(particlepixels);
%     Zauto_min(i) = zmap(idx(minidx));
% end




%% Detect Particles and Save
%{
loop = 0;
wb = waitbar(0/numframes,'Locating Particle Locations from Data');
%for L=1:numframes
for L=firstframe:skipframes:eval(lastframe)
    loop = loop + 1;


    % load data from mat files.
    load([IminPathStr,'/',filesort(L).firstname,'.mat']);
    Imin=imcrop(Imin,rect);
    zmap=imcrop(zmap,rect);
    % 
    %% Detect Particles and Save
    [Xauto_min,Yauto_min,Zauto_min] = detection(Imin, zmap, thlevel, disk0, disk1, derstr);
    LocCentroid(loop).time=[Xauto_min;Yauto_min;Zauto_min]';
    %
    %
    waitbar(loop/numframes,wb);
end

close(wb);
save([OutputPathStr,'/',filename(1:end-1),'-th',num2str(thlevel,'%10.0E'),'_dernum',num2str(dilaterode,2),'_day',num2str(round(now*1E5)),'.mat'], 'LocCentroid')
%}
toc
