function background = makevideo(inputFileName, varargin)
%% Create a video from any series of image inputs
% Version 3.0
% inputs:
%         temp   - description
% optional inputs:
%       'fps'        - frames per second e.g. 'fps',20 (default)
%       'outputFileName' - file name
% outputs:
%         vidout   - optional output video stored as a 3D matrix
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com


%% Set Defaults and detect GPU and initial image size
tic
saveoff = 0;
framerate = 20;
resize = 1;
background = 1;
newbackground = 0;
outputpathstr = 'analysis';
outputFileName = 'video';
backgroundFileName = 'background';
averagebgflag = false;
vidtype = 'MPEG-4';
[pathstr, firstname, ext] = fileparts(inputFileName);
firstname = strrep(firstname, '*', '');
try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

% Import first image (or AVI file if input file is already an AVI file).
if strcmpi(ext,'.avi')
%     vidin=VideoReader('Basler_acA2040-25gm__21407047__20150122_144715129.avi');
    vidin=VideoReader(inputFileName);
    numframes = vidin.NumberOfFrames;
    numfiles = numframes;
    framerate = vidin.FrameRate;
    m = vidin.Width;
    n = vidin.Height;
    vidin=VideoReader(inputFileName);
else
    filesort = dir([firstname,'*',ext]);
    numfiles = numel(filesort);
    Ein = imread(filesort(1, 1).name);
    [m,n]=size(Ein);
end
rect = [1,1,m-1,n-1];

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'CPU'
            varargin(1) = [];
            gpu_num = 0;
            
        case 'EXT'
            ext = varargin{2};
            ext = ['.', ext];
            strrep(ext, '..', '.');
            varargin(1:2) = [];
            
        case 'OUTPUT'
            outputFileName = varargin{2};
%             [outputpathstr, outputfilename, outputext] = fileparts(firstname);
            varargin(1:2) = [];
            
        case 'SAVEOFF'
            saveoff = 1;
            varargin(1) = [];
            
        case 'TRIMFRAMES'
            trimframes = varargin{2};
            if numel(trimframes) == 2;
                trimframes(3) = 1;
            end
            firstframe = trimframes(1);
            lastframe = trimframes(2);
            skipframes = trimframes(3);
            numframes = floor((1+lastframe-firstframe)/skipframes);
            backgroundFileName = ['background',num2str(firstframe),'to',num2str(lastframe),'skip',num2str(skipframes)];
            varargin(1:2) = [];
            
        case 'FPS'
            framerate = varargin{2};
            varargin(1:2) = [];
        
        case 'AVI'
            vidtype = 'Motion JPEG AVI';
            varargin(1) = [];
            
        case 'MPEG-4'
            vidtype = 'MPEG-4';
            varargin(1) = [];
            
        case 'CROP'
            if numel(varargin{2}) ~= 4
                rect = [(varargin{2}(1:2)), 1023,1023];
            else
                rect = [varargin{2}];
                rect(3:4)=rect(3:4)-1;
            end
            varargin(1:2) = [];
            
        case 'RESCALE'
            resize = varargin{2};
            varargin(1:2) = [];
            
        case 'BACKGROUND'
            background = varargin{2};
            varnam=who('-file',background);
            background=load(background,varnam{1});
            background=background.(varnam{1});
            varargin(1:2) = [];
            
        case 'AVERAGE'
            averagebgflag = true;
            varargin(1) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end


if ~exist('trimframes','var')
    trimframes = [1 numfiles 1];
    firstframe = trimframes(1);
    lastframe = trimframes(2);
    skipframes = trimframes(3);
    numframes = floor((1+lastframe-firstframe)/skipframes);
end

if ~exist(outputpathstr, 'dir') & ~isempty(outputpathstr)
  mkdir(outputpathstr);
end

% GPU can't be used with stuctures. Otherwise I would use this code:
% if gpu_num > 0;
%     vidout=gpuArray(vidout);
% end


% Preallocate video array
vidout(1:numframes) = struct('cdata',zeros(rect(4),rect(3),3,'uint8'),'colormap',[]);
if saveoff == 0;
    writerObj = VideoWriter([outputpathstr,'\',outputFileName,'_',...
        num2str(uint8(rand*100))],vidtype);
    writerObj.FrameRate = framerate;
    open(writerObj);
end

% Create Video Array
wb = waitbar(0,'Creating Video');
for loop=1:numframes
    L=loop*skipframes;
%     load(filesort(L, 1).name,'Imin'); Ein=Imin;
    if exist('vidin','var')
        Ein = double(readFrame(vidin));
    else
        Ein = double(imread(filesort(L, 1).name))./background;
    end
    newbackground = newbackground + Ein;
    Ein = imcrop(Ein,rect);
    Ein = imresize(Ein,resize);
%     Ein = fp_imload(filesort(L, 1).name,'background.mat');
%     Ein = flipud(fp_imload(filesort(L, 1).name));
%     Ein = rot90(fp_imload(filesort(L, 1).name)); %also switch (m,n) in vidout
    maxint = 2*mean(Ein(:));
%     maxint = max(Ein(:));
    Ein(Ein>maxint) = maxint;
    Ein = 255.*Ein./maxint;
    
%     Eout = propagate(Ein,lambda,z,eps,zpad);
    Eout = Ein;
%     vidout(loop).cdata = uint8(zeros(m,n,3));
    vidout(loop).cdata = uint8(abs(Eout));
%     vidout(loop).cdata(:,:,1) = uint8(abs(Eout).*128);
%     vidout(loop).cdata(:,:,1) = uint8(abs(Eout)./256);
    vidout(loop).cdata(:,:,2) = vidout(loop).cdata(:,:,1);
    vidout(loop).cdata(:,:,3) = vidout(loop).cdata(:,:,1);
    writeVideo(writerObj,vidout(loop));
    waitbar((loop-1)/numframes,wb);
end
close(writerObj);
background = newbackground/numframes;
close(wb);

if gpu_num > 0;
    vidout=gather(vidout);
end

if saveoff == 1;
%     save([outputFileName, '.mat'],'vidout');
%    imwrite(uint8(vidout), [outputFileName, '.tif'], 'tif');
end

if averagebgflag == true;
    save([backgroundFileName, '.mat'],'background');
    if max(background) > 256
        imwrite(uint16(background), [backgroundFileName,'.tif'], 'tif');
    else
        imwrite(uint8(background), [backgroundFileName,'.png'], 'png');
    end
end

toc
