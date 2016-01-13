function [ background ] = rollingavgbg( inputFileName, avgNframes, numframesTEST )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Set Defaults and detect GPU and initial image size
tic

avgNframesDefault = 401; %for first test sample average somewhere between 200-400 frames (100 leaves streaking of slow particles, 500 makes the mean too different)
OutputPathStr = 'background';
[PathStr, firstname, ext] = fileparts(inputFileName);
firstname = strrep(firstname, '*', '');

if nargin < 2
    avgNframes = avgNframesDefault;
elseif mod(avgNframes,2) ~= 1
    avgNframes = 1+2*round(round(avgNframes)/2);
end

try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

filesort = dir([firstname,'*',ext]);
numfiles = numel(filesort);
background = double(imread(filesort(1, 1).name));
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

[m,n]=size(background);
rect = [1,1,m-1,n-1];

% Do NOT skip frames (unless you want to)
if ~exist('trimframes','var')
    trimframes = [1 numfiles 1];
    firstframe = trimframes(1);
    lastframe = trimframes(2);
    skipframes = trimframes(3);
    numframes = floor((1+lastframe-firstframe)/skipframes);
end

if nargin > 2
    numframes = numframesTEST;
end

if ~exist(['.\', OutputPathStr], 'dir') & ~isempty(['.\', OutputPathStr])
    mkdir(OutputPathStr);
else
    overwriteflag = input(['Directory named ',OutputPathStr,' already exists. Would you like to overwrite (y/n) '],'s');
    if upper(overwriteflag) ~= 'Y'
        error(['Background files in ',OutputPathStr,' already exist']);
    end
end

if gpu_num > 0;
    background=gpuArray(background);
end

wb = waitbar(0,'Creating individual background files');
for loop = 2:(avgNframes)
    L = loop*skipframes;
    background = background + double(imread(filesort(L, 1).name));
    waitbar((loop-1)/numframes,wb);
end

% Save rolling background files
background = gather(background/avgNframes);
save([OutputPathStr,'\',filesort((avgNframes+1)/2).firstname,'.mat'],'background','-v7.3');

for loop = avgNframes+1:numframes
    if gpu_num > 0;
        background=gpuArray(background*avgNframes);
    end
    L = loop*skipframes;
    background = background + double(imread(filesort(L, 1).name))-double(imread(filesort(L-avgNframes, 1).name));
    waitbar((loop-1)/numframes,wb);
    background = gather(background/avgNframes);
    save([OutputPathStr,'\',filesort(L-(avgNframes-1)/2).firstname,'.mat'],'background','-v7.3');
end

close(wb);
toc


end
