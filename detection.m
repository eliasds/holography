%% Thresholding and Morphological Operators
%
function [Xauto_min,Yauto_min,Zauto_min,th,th1,th2,th3,th4,th5,th6,th7,th8,th9] = detection(Imin, zmap, thlevel, derstr);

%%
% clear all
% load('constants.mat')
% load('matfiles\DH_0200.mat')
% thlevel = .2;
% derstr = 'R8D5E4D5E4';

%%
th = Imin<thlevel;
th1 = th;
[m,n] = size(Imin);
thIteration = 1;

%%
%
dervector = cell(1,length(derstr));
for L = 1:length(derstr)
    dervector{L} = derstr(L);
end

while ~isempty(dervector)
    switch upper(dervector{1})
        
        case 'D'
            thIteration = thIteration + 1;
            disknum = str2double(dervector{2});
            diskshape = morphshape(disknum);
            th = imdilate(th,diskshape);
            eval(['th',num2str(thIteration),' = th;']);
            dervector(1:2) = [];
            
        case 'E'
            thIteration = thIteration + 1;
            disknum = str2double(dervector{2});
            diskshape = morphshape(disknum);
            th = imerode(th,diskshape);
            eval(['th',num2str(thIteration),' = th;']);
            dervector(1:2) = [];
            
        case 'R'
            thIteration = thIteration + 1;
            disknum = str2double(dervector{2});
            % th = bwareaopen(th, 4);
            % th = bwareaopen(th, 8); %Default
            th = bwareaopen(th,disknum); %Disknum of 8 is default
            eval(['th',num2str(thIteration),' = th;']);
            dervector(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' dervector{1}])
    end
end
%}

%% Dilate and Erode with predertimined Shape(s)
%
% th2 = bwareaopen(th1, 8);
% th2 = imdilate(th2,disk0);
% th3 = imerode(th2,disk1);
% th = bwareaopen(th, 8);
% th = imdilate(th,disk1);
% th = imdilate(th,disk1);
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
thIteration = thIteration + 1;
th = bwlabel(th,4);
eval(['th',num2str(thIteration),' = th;']);
autodetstruct = regionprops(th,'Centroid','PixelIdxList');

% Determine X,Y,Z-values from minimum intensity pixel
Xauto_min=zeros(size(autodetstruct))';
Yauto_min=zeros(size(autodetstruct))';
Zauto_min=zeros(size(autodetstruct))';
for i = 1:numel(autodetstruct)
    idx = autodetstruct(i).PixelIdxList;
    particlepixels = Imin(idx);
    [~,minidx] = min(particlepixels);
    Xauto_min(i) = ceil(idx(minidx)/m);
    Yauto_min(i) = rem(idx(minidx),m);
    Zauto_min(i) = zmap(idx(minidx));
end


