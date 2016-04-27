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
saveoff = false;
framerate = 15;
resize = 1;
background = 1;
newbackground = 0;
outputpathstr = 'analysis';
outputFileName = 'video';
backgroundFileName = 'background';
rollingbgflag = false;
averagebgflag = false;
usebgflag = false;
vortflag = false;
fftflag = false;
skipframesflag = false;
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
    for L = 1:numfiles
        [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
            fileparts([filesort(L).name]);
    end
    if strcmpi(ext,'.mat')
%         varnam = who('-file',(filesort(1, 1).name));
%         Ein = load((filesort(1, 1).name),varnam{1});
%         Ein = Ein.(varnam{1});
        Ein = varextract(filesort(1, 1).name);
    else
        Ein = imread(filesort(1, 1).name);
    end
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
            saveoff = true;
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
            
        case 'SKIPFRAMES'
            skipframesflag = true;
            skipframesvalue = varargin{2};
            backgroundFileName = ['background_skip',num2str(skipframesvalue)];
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
            
        case {'CROP','IMCROP'}
            if numel(varargin{2}) ~= 4
                rect = [(varargin{2}(1:2)), 1023,1023];
            else
                rect = [varargin{2}];
            end
            varargin(1:2) = [];
            
        case 'RESCALE'
            resize = varargin{2};
            varargin(1:2) = [];
            
        case 'BACKGROUND'
            usebgflag = true;
            background = varargin{2};
            varnam=who('-file',background);
            background=load(background,varnam{1});
            background=background.(varnam{1});
            varargin(1:2) = [];
            
        case 'AVERAGE'
            averagebgflag = true;
            varargin(1) = [];
            
        case 'VORTFLAG'
            vortflag = true;
            vortloc = varargin{2};
            varargin(1:2) = [];
            
        case {'ROLLINGBACKGROUND','ROLLINGBG'}
            rollingbgflag = true;
            varargin(1) = [];
            
        case 'FFT'
            fftflag = true;
            varargin(1) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

% Do NOT skip frames (unless you want to)
if ~exist('trimframes','var')
    trimframes = [1 numfiles 1];
    firstframe = trimframes(1);
    lastframe = trimframes(2);
    skipframes = trimframes(3);
    numframes = floor((1+lastframe-firstframe)/skipframes);
end

if skipframesflag == true;
    skipframes = skipframesvalue;
    numframes = floor((1+lastframe-firstframe)/skipframes);
end

if ~exist(['.\', outputpathstr], 'dir') && ~isempty(['.\', outputpathstr])
  mkdir(outputpathstr);
end

if usebgflag == true && vortflag == true
    background(vortloc(2):vortloc(2)+vortloc(4),vortloc(1):vortloc(1)+vortloc(3)) = mean(background(:));
end

% GPU can't be used with stuctures. Otherwise I would use this code:
% if gpu_num > 0;
%     vidout=gpuArray(vidout);
% end


% Preallocate video array
Ein = imcrop(Ein,rect);
Ein = imresize(Ein,resize);
[m,n]=size(Ein);
vidout(1:numframes) = struct('cdata',zeros(n,m,3,'uint8'),'colormap',[]);
if saveoff == false;
    writerObj = VideoWriter([outputpathstr,'\',outputFileName,'_',...
        num2str(uint8(rand*100))],vidtype);
    writerObj.FrameRate = framerate;
    open(writerObj);
end

% Create Video Array
wb = waitbar(0,'Creating Video');
for L = firstframe:skipframes:lastframe
%     load(filesort(L, 1).name,'Imin'); Ein=Imin;
    if rollingbgflag == true
%         varnam = who('-file',['background\',(filesort(L, 1).firstname),'.mat']);
%         background = load(['background\',(filesort(L, 1).firstname),'.mat'],varnam{1});
%         background = background.(varnam{1});
        background = varextract(['background\',(filesort(L, 1).firstname),'.mat']);
    end
    if exist('vidin','var')
        Ein = single(readFrame(vidin));
    elseif strcmpi(ext,'.mat')
%         varnam = who('-file',(filesort(L, 1).name));
%         Ein = load((filesort(L, 1).name),varnam{1});
%         Ein = Ein.(varnam{1});
        Ein = varextract(filesort(L, 1).name);
    else
        Ein = single(imread(filesort(L, 1).name))./background;
    end
    newbackground = newbackground + Ein;
    Ein = imcrop(Ein,rect);
    if fftflag == true
        EinFFT = log10(abs(fftshift(fft2(Ein))));
        minFFTlog = min(EinFFT(:));
        maxFFTlog = max(EinFFT(:));
        EinFFT = (EinFFT - minFFTlog)/(maxFFTlog - minFFTlog);
        EinFFT = 255*adapthisteq(EinFFT);
        EinFFT = imresize(EinFFT,resize);
    end
    Ein = imresize(Ein,resize);
    
    maxint = 2*mean(Ein(:));
%     maxint = max(Ein(:));
    Ein(Ein>maxint) = maxint;
    Ein = 255.*Ein./maxint;
    
%     Eout = propagate(Ein,lambda,z,eps,zpad);
    if fftflag == true
        Eout = cat(2,Ein,EinFFT);
    else
        Eout = Ein;
    end
    vidout(L).cdata = uint8(abs(Eout));
    vidout(L).cdata(:,:,2) = vidout(L).cdata(:,:,1);
    vidout(L).cdata(:,:,3) = vidout(L).cdata(:,:,1);
    writeVideo(writerObj,vidout(L));
    waitbar((L-firstframe)/numframes,wb);
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

toc2

