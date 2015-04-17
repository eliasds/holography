function [ thImin ] = imin2img( Imin, thlevel, outputfilename )
% imin2img takes a matrix, thresholds is and outputs a logical matrix
%   Detailed explanation goes here

if thlevel > 0
    thImin = uint8(Imin<thlevel);
else
    thImin = Imin;
end

%% Detect Structures
% th = bwlabel(th,4);
% autodetstruct = regionprops(th,'Centroid','PixelIdxList');

if nargin > 2
    imwrite(thImin*255, outputfilename);
end

end

