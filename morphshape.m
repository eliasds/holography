%% Create Dilate and Erode Shape Parameters
function diskshape = morphshape(dilaterode)

if dilaterode <= 2
    diskshape = logical(ones(dilaterode-1));
elseif dilaterode == 3
    diskshape = logical(ones(dilaterode));
elseif dilaterode == 4
    diskshape = getnhood(strel('diamond', round((dilaterode+1)/2)));
    diskshape = diskshape(2:end-1,2:end-1);
    diskshape(:,dilaterode/2) = [];
    diskshape(dilaterode/2,:) = [];
elseif dilaterode == 5
    diskshape = getnhood(strel('diamond', round((dilaterode)/2)));
    diskshape = diskshape(2:end-1,2:end-1);
elseif dilaterode == 6
    diskshape = getnhood(strel('diamond', round((dilaterode+1)/2)));
    diskshape = diskshape(2:end-1,2:end-1);
    diskshape(:,dilaterode/2) = [];
    diskshape(dilaterode/2,:) = [];
elseif dilaterode == 7
    diskshape = getnhood(strel('diamond', round((dilaterode)/2)));
    diskshape = diskshape(2:end-1,2:end-1);
elseif dilaterode == 8
    diskshape = getnhood(strel('disk', 5));
    diskshape(:,dilaterode/2) = [];
    diskshape(dilaterode/2,:) = [];
% elseif dilaterode > 8
%     [xx,yy] = ndgrid((1:dilaterode)-((dilaterode+1)/2),(1:dilaterode)-((dilaterode+1)/2));
%     diskshape = (xx.^2 + yy.^2)<((dilaterode+1)/2)^2;
end
