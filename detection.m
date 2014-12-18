%% Thresholding and Morphological Operators
%
function [Xauto_min,Yauto_min,Zauto_min,Xauto_centroid,Yauto_centroid,Zauto_centroid] = detection(Imin, zmap, thlevel, disk0, disk1, derstr);

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
th = imdilate(th,disk0);
th = imerode(th,disk0);
th = imdilate(th,disk1);
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

% Linear Interpolation Method, using 4 pixels nearest centroid(X-Y) to
%   determine z-depth.
xy = [autodetstruct.Centroid];
Xauto_centroid = xy(1:2:end);
Yauto_centroid = xy(2:2:end);
Zauto_centroid = interp2(1:size(zmap,2),1:size(zmap,1),zmap,Xauto_centroid,Yauto_centroid);

% Determine X,Y,Z-values from minimum intensity pixel
Xauto_min=zeros(size(autodetstruct))';
Yauto_min=zeros(size(autodetstruct))';
Zauto_min=zeros(size(autodetstruct))';
for i = 1:numel(autodetstruct)
    idx = autodetstruct(i).PixelIdxList;
    particlepixels = Imin(idx);
    [~,minidx] = min(particlepixels);
    Xauto_min(i) = ceil(idx(minidx)/2048);
    Yauto_min(i) = rem(idx(minidx),2048);
    Zauto_min(i) = zmap(idx(minidx));
end


