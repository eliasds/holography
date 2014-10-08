%% Create Background Image From Average of Series
% 
% Version 2.0

function background = avgbg(varargin)

background = 0;
saveon = 0;
firstframe = 1;
try
    gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
catch err
    gpu_num = 0;
end

filename = 'DH_';
ext = '.tif';
outputFileName = 'background';

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'FILENAME'
            filename = varargin{2};
            [pathstr, filename, ext] = fileparts(filename);
            strrep(filename, '*', '');
            varargin(1:2) = [];
            
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
            varargin(1:2) = [];
            
        case 'SAVE'
            saveon = 1;
            varargin(1) = [];
            
        case 'ODD'
            varargin(1) = [];
            firstframe = 1;
            step = 2;
            
        case 'EVEN'
            varargin(1) = [];
            firstframe = 2;
            step = 2;
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);

if gpu_num > 0;
    background=gpuArray(background);
end

wb = waitbar(1/numfiles,['importing files']);
for L=firstframe:step:numfiles
    background=background+double(imread(filesort(L).name));
    waitbar(L/numfiles,wb);
end
close(wb);
background=background/numfiles;

if gpu_num > 0;
    background=gather(background);
end

if saveon == 1;
    save([outputFileName, '.mat'],'background');
    imwrite(uint8(background), [outputFileName, '.tif'], 'tif');
end
