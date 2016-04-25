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
minpx1 = 9;
minpx2 = 3;
% thlevel = .2;
% derstr = 'R8D5E4D5E4';

%%
% if meanflag == false
    h = 1/9*ones(3);
    zmap = filter2(h,zmap); %Smooth zmap by averaging over all adjacent pixels
    zmap = filter2(h,filter2(h,zmap));
% end
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
            
        case 'M'
            minpx1 = dervector{2};
            dervector(1:2) = [];
            
        case 'N'
            minpx2 = dervector{2};
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

% th2 = zeros(m,n);
% for L = 1:numel(autodetstruct)
%     idx = round(autodetstruct(L).Centroid);
%     th2(idx(2),idx(1)) = 1;
% end
% thIteration = thIteration + 1; th_all(:,:,thIteration) = th2;
% th2 = imdilate(th2,makering(7,9));
% thIteration = thIteration + 1; th_all(:,:,thIteration) = th2;
% 
% if meanflag == true; %Determine Z-Values from perimeter means and X & Y-values from centroid
% %     th = bwperim(th,4).*th;
%     th2 = bwlabel(th2,4);
%     thIteration = thIteration + 1; th_all(:,:,thIteration) = th2;
%     autodetstructp = regionprops(th2,'Centroid','PixelIdxList');
%     xyCentroid = [autodetstructp.Centroid];
%     Xauto = xyCentroid(1:2:end);
%     Yauto = xyCentroid(2:2:end);
%     Zauto = zeros(size(autodetstructp))';
%     for L = 1:numel(autodetstructp)
%         idxp = autodetstructp(L).PixelIdxList;
%         Zauto(L) = mean(zmap(idxp));
%     end
%     th = th2; thIteration = thIteration + 1; th_all(:,:,thIteration) = th2;
% else % Determine X,Y,Z-values from minimum intensity pixel
%     Xauto = zeros(size(autodetstruct))';
%     Yauto = zeros(size(autodetstruct))';
%     Zauto = zeros(size(autodetstruct))';
    th = zeros(m,n);
    for L = 1:numel(autodetstruct)
        clear('idx','particlepixels','minidx');
%         zavg = 0;
        idx = autodetstruct(L).PixelIdxList;
        particlepixels = Imin(idx);
        for M = 1:min(length(autodetstruct(1).PixelIdxList),minpx1)
            [~,minidx(M)] = min(particlepixels);
            particlepixels(minidx(M)) = inf;
            th(idx(minidx(M))) = 1;
%             zavg = zavg + zmap(idx(minidx(M)));
        end
%         zavg = zavg/M;
%         Xauto(L) = ceil(idx(minidx(1))/m);
%         Yauto(L) = rem(idx(minidx(1)),m);
%         Zauto(L) = zavg;
    end
% end

thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
th = imdilate(th,ones(3));
th = bwlabel(th,4);
thIteration = thIteration + 1; th_all(:,:,thIteration) = th;
clear autodetectstruct;
autodetstruct = regionprops(th,'Centroid','PixelIdxList');
    Xauto = zeros(size(autodetstruct))';
    Yauto = zeros(size(autodetstruct))';
    Zauto = zeros(size(autodetstruct))';
    xyCentroid = [autodetstruct.Centroid];
    Xauto = xyCentroid(1:2:end);
    Yauto = xyCentroid(2:2:end);
%     th = zeros(m,n);
    for L = 1:numel(autodetstruct)
        clear('idx','particlepixels','minidx');
        zavg = 0;
        idx = autodetstruct(L).PixelIdxList;
        particlepixels = Imin(idx);
        for M = 1:min(length(autodetstruct(1).PixelIdxList),minpx2)
            [~,minidx(M)] = min(particlepixels);
            particlepixels(minidx(M)) = inf;
%             th(idx(minidx(M))) = 1;
%             zavg = zavg + zmap(idx(minidx(M)));
        end
%         minidx(1) = [];
%         zavg = zavg/M;
%         Xauto(L) = ceil(idx(minidx(1))/m);
%         Yauto(L) = rem(idx(minidx(1)),m);
        Zauto(L) = mean(zmap(idx(minidx(:))));
    end

end

