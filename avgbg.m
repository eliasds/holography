%% Create Background Image From Average of Series
% Create an averaged (background) image from many images.
% Defaults:
% Options: Filename, CPU, Ext, Output, Odd, Even, Demosaic, Keep
% Version 2.0

function [background, mov] = avgbg(varargin)

background = 0;
saveon = 0;
count = 0;
firstframe = 1;
step = 1;
mosaic = false;
rgbcode = 'rggb';
keep = false;
flagfilerange = false;
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
            saveon = true;
            outputFileName = varargin{2};
            outputFileName = strrep(outputFileName, '.mat', '');
            varargin(1:2) = [];
            
        case 'ODD'
            varargin(1) = [];
            firstframe = 1;
            step = 2;
            
        case 'FILERANGE'
            flagfilerange = true;
            filerange = varargin{2};
            varargin(1:2) = [];
            
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

if flagfilerange == false;
    filerange = [firstframe:step:numfiles];
end

if gpu_num > 0;
    background=gpuArray(background);
end

if nargout > 1
    newfile = imread(filesort(firstframe).name);
    mov = zeros([size(newfile),numfiles]);
end
    
wb = waitbar(1/numel(filerange),['importing files']);
for L = filerange
    newfile = imread(filesort(L).name);
    if mosaic == true;
        newfile = double(rgb2gray(demosaic(newfile,rgbcode)));
        background = background+newfile;
    else
        newfile = double(newfile);
        background = background+newfile;
    end
    if nargout > 1
        mov(:,:,L) = newfile;
    end
    count = count + 1;
    waitbar(count/numel(filerange),wb);
end
close(wb);
background=background/count;

if gpu_num > 0;
    background=gather(background);
end

if saveon == true;
    save([outputFileName, '.mat'],'background');
    if max(background) > 256
        imwrite(uint16(background), [outputFileName,ext], 'tif');
    else
        imwrite(uint8(background), [outputFileName,ext], 'tif');
    end
end
