% crop images first to reduce processing time (or later to increase
% presision)
% imin to detect minimum intensity
% save Imin and zmap
% crop now if cropping wasn't performed earlier
% threshhold
% remove problematic regions (like vorticella)
% detect particle centers
% save

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
background = 'background.mat';
M=7.3; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
lambda=632.8E-9/1.33; %laser wavelength in meters
a=0E-3;
b=2E-3;
c=401;
Zin=linspace(a,b,c);
Zout=Zin;
zpad=2048;
%maxint=6; %overide default max intensity: 2*mean(Imin(:))
%test=40;
radix2=1024;
rect = [1550-512,2070-1024,1023,1023];
vortloc=[1200,2160]; %location of vorticella in "cuvette in focus"
%vortloc=[1550,2160]; %location of vorticella in "vort in focus"



filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
for i = 1:numfiles
    [filesort(i).path, filesort(i).matname, filesort(i).ext] =fileparts([filesort(i).name]);
    filesort(i).mat=strcat(filesort(i).matname,'.mat');
end
varnam=who('-file',background);
background=load(background,varnam{1});
background=gpuArray(background.(varnam{1}));

%Ein = gather((double(imread([filesort(1).name]))./background));
Ein = gather((double(imread([filesort(1).name]))));
%Ein = gather(double(background));
if exist('maxint')<1
    maxint=2*mean(Ein(:));
end

if exist('test')
    numfiles=test;
end

Eout(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for i=1:100:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    % Ein = (double(imread([filesort(i).name])));
    Ein = (double(imread([filesort(i).name]))./background);
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

