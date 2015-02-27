%% Create Background Image From Average of Series
% 
% Version 2.0

function background = avgbg(varargin)

background = 0;
saveon = 0;
count = 0;
firstframe = 1;
step = 1;
mosaic = false;
rgbcode = 'rggb';
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
            filename = strrep(filename, '*', '');
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
            saveon = 1;
            outputFileName = varargin{2};
            varargin(1:2) = [];
            
        case 'ODD'
            varargin(1) = [];
            firstframe = 1;
            step = 2;
            
        case 'EVEN'
            varargin(1) = [];
            firstframe = 2;
            step = 2;
            
        case 'DEMOSAIC'
            mosaic = true;
            rgbcode = varargin{2};
            varargin(1:2) = [];
            
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
    if mosaic == true;
        background = background+double(rgb2gray(demosaic(imread(filesort(L).name),rgbcode)));
    else
        background=background+double(imread(filesort(L).name));
    end
    count = count + 1;
    waitbar(L/numfiles,wb);
end
close(wb);
background=background/count;

if gpu_num > 0;
    background=gather(background);
end

if saveon == 1;
    save([outputFileName, '.mat'],'background');
    if max(background) > 256
        imwrite(uint16(background), [outputFileName,ext], 'tif');
    else
        imwrite(uint8(background), [outputFileName,ext], 'tif');
    end
end
