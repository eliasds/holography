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
filename    = 'DH_';
backgroundfile = 'background.mat';
M=7.3; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
lambda=632.8E-9/1.33; %laser wavelength in meters
a=0E-3;
b=2E-3;
c=401;
Zin=linspace(a,b,c);
Zout=Zin;
zpad=2048;
%maxint=2.5; %overide default max intensity: 2*mean(Imin(:))
%test=40;
radix2=1024;
rect = [1550-512,2070-1024,1023,1023];
vortloc=[1200,2160]; %location of vorticella in "cuvette in focus"
%vortloc=[1550,2160]; %location of vorticella in "vort in focus"
thlevel = 0.0002;
dilaterode=2;


filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
for L = 1:numfiles
    [filesort(L).path, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

%{
varnam=who('-file',backgroundfile);
background=load(backgroundfile,varnam{1});
background=gpuArray(background.(varnam{1}));

for L=1:1:numfiles
%     Holo = imread([filesort(L).name]);
    Holo = double(gpuArray(imread([filesort(L).name])))./background;
    Ein = imcrop(Holo,rect);
    maxint = 2*mean(Ein(:));
    Ein(Ein>maxint) = maxint;
    Ein = Ein./maxint;
    Ein = gather(Ein);
    imwrite(Ein,['1024\',filesort(L).name]);
end

%

% Ein = gather((double(imread([filesort(1).name]))./background));
Ein = gather((double(imread([filesort(1).name]))));
% Ein = gather(double(background));
if ~exist('maxint')
    maxint=2*mean(Ein(:));
end

if exist('test')
    numfiles=test;
end

Eout(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for i=1:1:numfiles

    % import data from tif files.
    % Ein = (double(imread([filesort(i).name])));
    Holo = (double(imread([filesort(i).name]))./background);
    Ein = imcrop(Holo,rect);
    % Ein=Ein(vortloc(2)-radix2+1:vortloc(2),vortloc(1)-radix2/2:vortloc(1)-1+radix2/2);
    %Ein=Ein(1882-768:1882+255,1353-511:1353+512);
    %Ein = (double(background));
    %Ein(isnan(Ein)) = mean(background(:));
    Ein(Ein>maxint)=maxint;
    
    [Imin, zmap] = imin(Ein,lambda,Zout,eps,zpad);
    save(filesort(i).mat,'Imin','zmap','-v7.3');
    
    waitbar(i/numfiles,wb);
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




%% Detect Particle Centroids and Save
%
locationxyz(numfiles).time=[];
wb = waitbar(1/numfiles,['Locating Particle Locations from Data']);
for L=1:numfiles % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(L).firstname,'.mat']);
    % 
    [Xauto,Yauto,Zauto_centroid,Zauto_mean,Zauto_min] = detection(Imin, zmap, thlevel, dilaterode);
    locationxyz(L).time=[Xauto;Yauto;Zauto_centroid;Zauto_mean;Zauto_min]';
    %
    %
    waitbar(L/numfiles,wb);
end

close(wb);
toc

save(strcat(filename(1:end-1),'-',num2str(thlevel*10000,2),'th_',num2str(dilatenum,2),'di','.mat'), 'locationxyz')


