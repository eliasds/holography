function [ background ] = rollingbg( inputFileName, avgNframes, numframesTEST )
%rollingbg.m: Creates a background image for each hologram frame
%   Sum N/2 frames before current frame and N/2 frames after current frame
%   and divide the result by N. Do this for (NumberOfFrames-N)
%   Do not include current frame in this calculation.
%%  SHOULD I INCLUDE THE OPTION TO EXCLUDE SOME FRAMES BEFORE AND AFTER CURRENT FRAME? 
%%
tic

avgNframesDefault = 400; %for first test sample average somewhere between 200-400 frames (100 leaves streaking of slow particles, 500 makes the mean too different)
OutputPathStr = 'background';
[PathStr, firstname, ext] = fileparts(inputFileName);
firstname = strrep(firstname, '*', '');

if nargin < 2
    avgNframes = avgNframesDefault;
elseif mod(avgNframes,2) ~= 0
    avgNframes = 2*round(round(avgNframes)/2);
end

gpu_num = gpuUseful; %Determines if there is a CUDA enabled GPU

[filesort,numfiles] = filesortstruct([firstname,'*',ext]);
background = double(imread(filesort(1, 1).name));

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
    numframes = numframesTEST+avgNframes;
end

if ~exist(['.\', OutputPathStr], 'dir') && ~isempty(['.\', OutputPathStr])
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
% Create rolling background for first frame
for loop = 2:(avgNframes/2)
    L = loop*skipframes;
    background = background + double(imread(filesort(L, 1).name));
    waitbar((loop-1)/numframes,wb);
end
for loop = (avgNframes/2+2):(avgNframes+1)
    L = loop*skipframes;
    background = background + double(imread(filesort(L, 1).name));
    waitbar((loop-1)/numframes,wb);
end

% Save rolling background file for first frame
background = gather(background/avgNframes);
save([OutputPathStr,'\',filesort(avgNframes/2+1).firstname,'.mat'],'background','-v7.3');

% Create and Save rolling background file for remaining frames
for loop = avgNframes+2:numframes
    background = background*avgNframes;
    if gpu_num > 0;
        background = gpuArray(background);
    end
    L = loop*skipframes;
    background = background + double(imread(filesort(L-avgNframes/2-1, 1).name));
    background = background + double(imread(filesort(L, 1).name));
    background = background - double(imread(filesort(L-avgNframes-1, 1).name));
    background = background - double(imread(filesort(L-avgNframes/2, 1).name));
    waitbar((loop-1)/numframes,wb);
    background = gather(background/avgNframes);
    save([OutputPathStr,'\',filesort(L-avgNframes/2).firstname,'.mat'],'background','-v7.3');
end

close(wb);
toc2


end
