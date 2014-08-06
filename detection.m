%% Thresholding and Morphological Operators
%
function [Xauto,Yauto,Zauto_centroid,Zauto_mean,Zauto_min] = detection(Imin, zmap, thlevel, disk0, disk1, derstr);

th = Imin<thlevel;

%{
derstr = 'D1E0R8D1D1';

dervector = cell(1,length(derstr));
for L = 1:length(derstr)
    dervector{L} = derstr(L);
end

while ~isempty(dervector)
    switch upper(dervector{1})
        
        case 'D'
            if dervector{2} == 0
                th = imdilate(th,disk0);
            else
                th = imdilate(th,disk1);
            dervector(1:2) = [];
            
        case 'E'
            if dervector{2} == 0
                th = imerode(th,disk0);
            else
                th = imerode(th,disk1);
            dervector(1:2) = [];
            
        case 'R'
            if dervector{2} == 4
                th = bwareaopen(th, 4);
            else
                th = bwareaopen(th, 8);
            dervector(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end
%}

%% Dilate and Erode with predertimined Shape(s)
%
th = bwareaopen(th, 8);
th = imdilate(th,disk1);
th = imerode(th,disk0);
th = bwareaopen(th, 8);
th = imdilate(th,disk1);
th = imdilate(th,disk1);
% th = imerode(th,disk);
% th = imdilate(th,disk);
% th = imerode(th,disk);
%}

%% Part for finding Cricles
%{
% [CENTERS1, RADII1, METRIC1]=imfindcircles(th,[6,32]); %Used for Vort in Focus
[CENTERS1, RADII1, METRIC1]=imfindcircles(th,[8,18]); %Used for Cuvette in Focus
% viscircles(CENTERS1, RADII1) % ONLY NEEDED FOR PLOTTING

Xcircles = CENTERS1(:,1)';
Ycircles = CENTERS1(:,2)';

% Depth of Circle Center intensity pixel
Zcircles = zeros(size(Xcircles));
for L = 1:length(CENTERS1(:,1))
    Zcircles(L) = zmap(round(Ycircles(L)),round(Xcircles(L)))';
end
%}

%% Dilate or Erode with a single number
% disk1 = strel('disk', dilaterode, 0);
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));

%% Detect Structures
th = bwlabel(th,4);
autodetstruct = regionprops(th,'Centroid','PixelIdxList');
xy = [autodetstruct.Centroid];
Xauto = xy(1:2:end);
Yauto = xy(2:2:end);

% Linear Interpolation Method, using 4 pixels nearest centroid(X-Y) to
%   determine z-depth. more acurate centroid method
Zauto_centroid = interp2(1:size(zmap,2),1:size(zmap,1),zmap,Xauto,Yauto);

% Determine mean Z-value from all pixels in region (biasing errors) and
%   depth of minimum intensity pixel
Zauto_mean=zeros(size(Xauto));
Zauto_min=zeros(size(Xauto));
for i = 1:numel(autodetstruct)
    idx = autodetstruct(i).PixelIdxList;
    Zauto_mean(i) = mean(zmap(idx));
    
    particlepixels = Imin(idx);
    [~,minidx] = min(particlepixels);
    Zauto_min(i) = zmap(idx(minidx));
end
