%% Create Background Image From Average of Series
% 
% Version 2.0

function [background] = avgbg(varargin)

gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
background=0;

filename = 'DH-';
ext = 'tif';
outputFileName = 'background';

% if max(size(varargin))==1
%         filename=varargin{1};
%         [pathstr, name, ext] = fileparts(filename);
%         varargin(1) = [];
% end

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'FILENAME'
            filename = varargin{2};
            [pathstr, filename, ext] = fileparts(filename);
            varargin(1:2) = [];
            
        case 'CPU'
            varargin(1) = [];
            gpu_num = 0;
            
        case 'EXT'
            ext = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);

if gpu_num > 0;
    background=gpuArray(background); 
end

wb = waitbar(1/numfiles,['importing files']);
for L=1:numfiles 
    background=background+double(imread(filesort(L).name));
    waitbar(L/numfiles,wb);
end
close(wb);
background=background/numfiles;


imwrite(background, outputFileName, ext);
save(outputFileName,Imin,zmap);
