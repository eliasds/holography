function [Xauto,Yauto,Zauto,th,th_all] = detection(Imin, zmap, thlevel, derstr, minmean);
%% detection - Particle Detection using Thresholding and Morphological Operators
%
%              Daniel Shuldman <elias.ds@gmail.com>
%              Version 2.1
%
%
%%
if nargin > 4 && isequal(upper(minmean),'MEAN')
    meanflag = true;
else
    meanflag = false;
end

%%
% clear all
% load('constants.mat')
% load('matfiles\DH_0200.mat')
% thlevel = .2;
% derstr = 'R8D5E4D5E4';

%%
if meanflag == false
    h = 1/9*ones(3);
    zmap = filter2(h,zmap); %Smooth zmap by averaging over all adjacent pixels
    zmap = filter2(h,filter2(h,zmap));
end
th = Imin<thlevel;
th_all = uint8(th);
[m,n] = size(Imin);
thIteration = 1;

%%
%
loop = 0;
dervector = cell(1,length(derstr));
for L = 1:length(derstr)
    loop = loop + 1;
    dervector{loop} = derstr(L);
    if ismember(dervector{loop}, '0123456789')
        dervector{loop} = str2double(dervector{loop});
        if isnumeric(dervector{loop-1})
            dervector{loop-1} = 10*dervector{loop-1} + dervector{loop};
            dervector(loop) = [];
            loop = loop - 1;
        end
    end
end

while ~isempty(dervector)
    switch upper(dervector{1})
        
        case 'D'
            disknum = dervector{2};
            diskshape = morphshape(disknum);
            th = imdilate(th,diskshape);
            thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
            dervector(1:2) = [];
            
        case 'E'
            disknum = dervector{2};
            diskshape = morphshape(disknum);
            th = imerode(th,diskshape);
            thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
            dervector(1:2) = [];
            
        case 'R'
            disknum = dervector{2};
            % th = bwareaopen(th, 4);
            % th = bwareaopen(th, 8); %Default
            th = bwareaopen(th,disknum); %Disknum of 8 is default
            thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
            dervector(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' dervector{1}])
    end
end
%}


%% Dilate or Erode with a single number
% th = imdilate(th,ones(4));
% th = imerode(th,ones(4));
% disk1 = strel('disk', dilaterode, 0);
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imdilate(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));
% th = imerode(th,strel('disk', dilaterode, 0));

%% Detect Structures
th = imfill(th,'holes');
thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
th = bwlabel(th,4);
thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
autodetstruct = regionprops(th,'Centroid','PixelIdxList');
if meanflag == true; %Determine Z-Values from perimeter means and X & Y-values from centroid
    th = bwperim(th,4).*th;
    thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
    autodetstructp = regionprops(th,'PixelIdxList');
    xyCentroid = [autodetstruct.Centroid];
    Xauto = xyCentroid(1:2:end);
    Yauto = xyCentroid(2:2:end);
    Zauto = zeros(size(autodetstruct))';
    for i = 1:numel(autodetstruct)
        idxp = autodetstructp(i).PixelIdxList;
        Zauto(i) = mean(zmap(idxp));
    end
else % Determine X,Y,Z-values from minimum intensity pixel
    Xauto = zeros(size(autodetstruct))';
    Yauto = zeros(size(autodetstruct))';
    Zauto = zeros(size(autodetstruct))';
    for i = 1:numel(autodetstruct)
        idx = autodetstruct(i).PixelIdxList;
        particlepixels = Imin(idx);
        [~,minidx] = min(particlepixels);
        Xauto(i) = ceil(idx(minidx)/m);
        Yauto(i) = rem(idx(minidx),m);
        Zauto(i) = zmap(idx(minidx));
    end
end


