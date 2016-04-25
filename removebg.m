function [ Holo ] = removebg( BgFileName, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Set Defaults and detect GPU and initial image size
tic

% avgNframesDefault = 401; %for first test sample average somewhere between 200-400 frames (100 leaves streaking of slow particles, 500 makes the mean too different)
BgPathStr = 'background\';
OutputPathStr = 'holofiles\';
HoloExt = '.tiff';
BgExt = '.mat';
[~, firstname, ~] = fileparts(BgFileName);
firstname = strrep(firstname, '*', '');
skipframes = 1;
firstframe = 1;
testflag = false;


try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

filesort = dir([BgPathStr,firstname,'*',BgExt]);
numfiles = numel(filesort);
lastframe = numfiles;
for La = 1:numfiles
    [filesort(La).pathstr, filesort(La).firstname, filesort(La).ext] = ...
        fileparts([filesort(La).name]);
    %filesort(i).matname=strcat(filesort(L).matname,'.mat');
end
% Import Background file
backgroundfile = [BgPathStr,filesort(1, 1).name];
varnam = who('-file',backgroundfile);

background = load([BgPathStr,filesort(1, 1).name],varnam{1});
background = background.(varnam{1});
[m,n] = size(background);
cropregion = [1,1,m-1,n-1];

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'TEST'
            testflag = true;
            numframesTEST = varargin{2};
            varargin(1:2) = [];
            
        case {'CROP', 'IMCROP'}
            cropregion = varargin{2};
            varargin(1:2) = [];
            
        case 'FIRSTFRAME'
            firstframe = varargin{2};
            varargin(1:2) = [];
            
        case 'SKIPFRAMES'
            skipframes = varargin{2};
            varargin(1:2) = [];
            
        case 'LASTFRAME'
            lastframe = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])

    end
end

numframes = floor((1+lastframe-firstframe)/skipframes);
if testflag == true;
    numframes = numframesTEST;
    lastframe = (numframes-1)*skipframes+firstframe;
end

if ~exist(['.\', OutputPathStr], 'dir') && ~isempty(['.\', OutputPathStr])
    mkdir(OutputPathStr);
else
    overwriteflag = input(['Directory named ',OutputPathStr,' already exists. Would you like to overwrite (y/n) '],'s');
    if upper(overwriteflag) ~= 'Y'
        error(['Hologram files in ',OutputPathStr,' already exist']);
    end
end

wb = waitbar(0,'Removing background');
for La = firstframe:skipframes:lastframe
    background = load([BgPathStr,filesort(La, 1).name],varnam{1});
    background = background.(varnam{1});
%     if gpu_num > 0;
%         background=gpuArray(background);
%     end
    HoloIn = single(imread([filesort(La, 1).firstname,HoloExt]));
    Holo = HoloIn./background;
    Holo = imcrop(Holo,cropregion);
%     Holo = gather(Holo);
    save([OutputPathStr,filesort(La).firstname,'.mat'],'Holo','-v7.3');
    waitbar((La-firstframe+1)/numframes,wb);
end


close(wb);

toc2

end
