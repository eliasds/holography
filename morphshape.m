%% Create Dilate and Erode Parameters
function [disk1, disk0]=morphshape(dilaterode)

if dilaterode <= 2
    disk1 = logical(ones(dilaterode-1));
elseif dilaterode == 3
    disk1 = logical(ones(dilaterode));
elseif dilaterode == 4
    disk1 = getnhood(strel('diamond', round((dilaterode+1)/2)));
    disk1 = disk1(2:end-1,2:end-1);
    disk1(:,dilaterode/2) = [];
    disk1(dilaterode/2,:) = [];
elseif dilaterode == 5
    disk1 = getnhood(strel('diamond', round((dilaterode)/2)));
    disk1 = disk1(2:end-1,2:end-1);
elseif dilaterode == 6
    disk1 = getnhood(strel('diamond', round((dilaterode+1)/2)));
    disk1 = disk1(2:end-1,2:end-1);
    disk1(:,dilaterode/2) = [];
    disk1(dilaterode/2,:) = [];
elseif dilaterode == 7
    disk1 = getnhood(strel('diamond', round((dilaterode)/2)));
    disk1 = disk1(2:end-1,2:end-1);
elseif dilaterode == 8
    disk1 = getnhood(strel('disk', 5));
    disk1(:,dilaterode/2) = [];
    disk1(dilaterode/2,:) = [];
elseif dilaterode == 9
    [xx,yy] = ndgrid((1:dilaterode)-((dilaterode+1)/2),(1:dilaterode)-((dilaterode+1)/2));
    disk1 = (xx.^2 + yy.^2)<((dilaterode+1)/2)^2;
else
    [xx,yy] = ndgrid((1:dilaterode)-((dilaterode+1)/2),(1:dilaterode)-((dilaterode+1)/2));
    disk1 = (xx.^2 + yy.^2)<((dilaterode+1)/2)^2;
    dilaterode=dilaterode-1;
    [xx,yy] = ndgrid((1:dilaterode)-((dilaterode+1)/2),(1:dilaterode)-((dilaterode+1)/2));
    disk0 = (xx.^2 + yy.^2)<((dilaterode+1)/2)^2;
    % disk = 1 - disk;
end
