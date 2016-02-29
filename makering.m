function ringshape = makering( innerdiameter, outerdiameter )
%
% Create a logical image of a ring with specified
% inner diameter, outer diameter center, and image size.
% First create the image.

if nargin < 2
    outerdiameter = innerdiameter + 1;
end

outerdiameter = 2*floor(outerdiameter/2)+1;

imageSizeX = outerdiameter;
imageSizeY = outerdiameter;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = round(outerdiameter/2);
centerY = round(outerdiameter/2);
innerRadius = round(innerdiameter/2);
outerRadius = round(outerdiameter/2);
array2D = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2;
ringshape = array2D >= innerRadius.^2 & array2D <= outerRadius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
image(ringshape) ;
colormap([0 0 0; 1 1 1]);
title('Binary Image of a Ring', 'FontSize', 25);

end