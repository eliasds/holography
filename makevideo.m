function [] = makevideo(inputFileName, varargin)
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

% Set Defaults and detect GPU and initial image size
tic
vidout = 0;
saveoff = 0;
framerate = 20;
outputpathstr = 'analysis';
outputFileName = 'video';
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
Ein = imread(filesort(1, 1).name);
[m,n]=size(Ein);
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
            
        case 'OUTPUTFILENAME'
            outputFileName = varargin{2};
            [outputpathstr, outputfilename, outputext] = fileparts(firstname);
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
            rect = [varargin{2}, 1023,1023];
%             rect = [1550-512,2070-1024,1023,1023];
            varargin(1:2) = [];
            
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

if ~exist(outputpathstr, 'dir')
  mkdir(outputpathstr);
end

if gpu_num > 0;
    vidout=gpuArray(vidout);
end


% Preallocate video array
clear vidout;
vidout(numframes) = struct('cdata',[],'colormap',[]);
%writerObj = VideoWriter(strcat('analysis\',filename,'_',num2str(uint8(rand*100))),vidtype);
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
    Ein = double(imread(filesort(L, 1).name));
%     Ein = imcrop(Ein,rect);
%     Ein = fp_imload(filesort(L, 1).name,'background.mat');
%     Ein = flipud(fp_imload(filesort(L, 1).name));
%     Ein = rot90(fp_imload(filesort(L, 1).name)); %also switch (m,n) in vidout
%     maxint = 2*mean(Ein(:));
    maxint = max(Ein(:));
    Ein(Ein>maxint) = maxint;
    Ein = 255.*Ein./maxint;
    
%     Eout = propagate(Ein,lambda,z,eps,zpad);
    Eout = Ein;
    vidout(loop).cdata = uint8(zeros(m,n,3));
    vidout(loop).cdata(:,:,1) = uint8(abs(Eout));
%     vidout(loop).cdata(:,:,1) = uint8(abs(Eout).*128);
%     vidout(loop).cdata(:,:,1) = uint8(abs(Eout)./256);
    vidout(loop).cdata(:,:,2) = vidout(loop).cdata(:,:,1);
    vidout(loop).cdata(:,:,3) = vidout(loop).cdata(:,:,1);
    writeVideo(writerObj,vidout(loop));
    waitbar((loop-1)/numframes,wb);
end
close(writerObj);
close(wb);

if gpu_num > 0;
    vidout=gather(vidout);
end

if saveoff == 1;
%     save([outputFileName, '.mat'],'vidout');
%    imwrite(uint8(vidout), [outputFileName, '.tif'], 'tif');
end

toc
