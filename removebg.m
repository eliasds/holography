function [ Holo ] = removebg( BgFileName, numframesTEST )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Set Defaults and detect GPU and initial image size
tic

% avgNframesDefault = 401; %for first test sample average somewhere between 200-400 frames (100 leaves streaking of slow particles, 500 makes the mean too different)
BgPathStr = 'background';
OutputPathStr = 'holofiles';
HoloExt = '.tiff';
BgExt = '.mat';
[PathStr, firstname, ext] = fileparts(BgFileName);
firstname = strrep(firstname, '*', '');
skipframes = 1;

% Do NOT skip frames (unless you want to)
% if ~exist('trimframes','var')
%     trimframes = [1 numfiles 1];
%     firstframe = trimframes(1);
%     lastframe = trimframes(2);
%     skipframes = trimframes(3);
%     numframes = floor((1+lastframe-firstframe)/skipframes);
% end

try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

filesort = dir([BgPathStr,'/',firstname,'*',ext]);
numfiles = numel(filesort);
numframes = numfiles;
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(L).matname,'.mat');
end
% Import Background file
backgroundfile = [BgPathStr,'/',filesort(1, 1).name];
varnam = who('-file',backgroundfile);

% [m,n]=size(background);
% rect = [1,1,m-1,n-1];

if nargin > 1
    numframes = numframesTEST;
end

if ~exist(['.\', OutputPathStr], 'dir') & ~isempty(['.\', OutputPathStr])
    mkdir(OutputPathStr);
else
    overwriteflag = input(['Directory named ',OutputPathStr,' already exists. Would you like to overwrite (y/n) '],'s');
    if upper(overwriteflag) ~= 'Y'
        error(['Hologram files in ',OutputPathStr,' already exist']);
    end
end

wb = waitbar(0,'Removing background');
for loop = 1:numframes
    L = loop*skipframes;
    background = load([BgPathStr,'/',filesort(L, 1).name],varnam{1});
    background = background.(varnam{1});
%     if gpu_num > 0;
%         background=gpuArray(background);
%     end
    HoloIn = single(imread([filesort(L, 1).firstname,HoloExt]));
    Holo = HoloIn./background;
%     Holo = gather(Holo);
    save([OutputPathStr,'/',filesort(L).firstname,'.mat'],'Holo','-v7.3');
    waitbar((loop-1)/numframes,wb);
end


close(wb);

toc

end
