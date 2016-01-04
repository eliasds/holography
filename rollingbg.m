function [ background3D ] = rollingbg( inputFileName, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Set Defaults and detect GPU and initial image size
tic
pis = 799;
saveoff = false;
framerate = 25;
resize = 1;
background = 1;
newbackground = 0;
lastbackground = 0;
avgNframes = 99;
outputpathstr = 'analysis';
outputFileName = 'video';
backgroundFileName = 'background3D';
averagebgflag = false;
usebgflag = false;
vortflag = false;
vidtype = 'MPEG-4';
[pathstr, firstname, ext] = fileparts(inputFileName);
firstname = strrep(firstname, '*', '');
try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

filesort = dir([firstname,'*',ext]);
numfiles = numel(filesort);
Holo = imread(filesort(1, 1).name);
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Holo = imcrop(Holo,[1,1,pis,pis]);

%%
[m,n]=size(Holo);
rect = [1,1,m-1,n-1];

% Do NOT skip frames (unless you want to)
if ~exist('trimframes','var')
    trimframes = [1 numfiles 1];
    firstframe = trimframes(1);
    lastframe = trimframes(2);
    skipframes = trimframes(3);
%     numframes = floor((1+lastframe-firstframe)/skipframes);
numframes = 600;
end

if ~exist(['.\', outputpathstr], 'dir') & ~isempty(['.\', outputpathstr])
  mkdir(outputpathstr);
end

% Preallocate video array
% vidout(1:numframes) = struct('cdata',zeros(n,m,3,'uint8'),'colormap',[]);
vidout = zeros(n,m,numframes,'uint8');
background3D = zeros(n,m,numframes,'double');
% if gpu_num > 0;
%     vidout=gpuArray(vidout);
% end

% Create Video Array
wb = waitbar(0,'Creating Video A');
for loop = 1:numframes
    L = loop*skipframes;
    Holo = uint8(imread(filesort(L, 1).name));
    %%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Holo = imcrop(Holo,[1,1,pis,pis]);

%%
    vidout(:,:,loop) = Holo;
    if loop <= avgNframes
        newbackground = newbackground + double(Holo);
    end
    if loop > numframes-avgNframes
        lastbackground = lastbackground + double(Holo);
    end
    waitbar((loop-1)/numframes,wb);
end
close(wb);

background3D(:,:,1:(avgNframes+1)/2) = repmat(newbackground/avgNframes,[1,1,(avgNframes+1)/2]);
background3D(:,:,numframes-(avgNframes-1)/2:numframes) = repmat(lastbackground/avgNframes,[1,1,(avgNframes+1)/2]);
midbackground = newbackground;

loop2 = 0;
wb = waitbar(0,'Creating Video B');
for loop = 1+(avgNframes+1)/2:numframes-(avgNframes+1)/2
    loop2 = loop2 + 1;
    L = loop*skipframes;
%     Holo = uint8(imread(filesort(L, 1).name));
%     vidout(:,:,loop) = Holo;
    midbackground = midbackground + double(vidout(:,:,loop2+avgNframes)) - double(vidout(:,:,loop-(avgNframes+1)/2));
    background3D(:,:,loop) = midbackground/avgNframes;
    waitbar((loop2-1)/(numframes-avgNframes),wb);
end
close(wb);


vidout = double(vidout)./background3D;
maxint = 2*mean(vidout(:));
vidout(vidout>maxint) = maxint;
vidout = 255.*vidout./maxint;
vidout = uint8(vidout);
% clear background3D

writerObj = VideoWriter([outputpathstr,'\',outputFileName,'_',...
        num2str(uint8(rand*100))],vidtype);
    writerObj.FrameRate = framerate;
    open(writerObj);
    
vidoutstruct(1:numframes) = struct('cdata',zeros(n*resize,m*resize,3,'uint8'),'colormap',[]);
wb = waitbar(0,'Creating Video C');
for loop = 1:numframes
    vidoutstruct(loop).cdata = imresize(vidout(:,:,loop),resize);
    vidoutstruct(loop).cdata(:,:,2) = vidoutstruct(loop).cdata(:,:,1);
    vidoutstruct(loop).cdata(:,:,3) = vidoutstruct(loop).cdata(:,:,1);
    writeVideo(writerObj,vidoutstruct(loop));
    waitbar((loop-1)/numframes,wb);
end
close(writerObj);
close(wb);

if gpu_num > 0;
    vidout=gather(vidout);
end
    
end

