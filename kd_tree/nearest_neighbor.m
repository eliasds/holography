
%best and R must be a Data object
function [ particle ] = nearest_neighbor( tree, point, best, R )
%NEAREST_NEIGHBOR finds the nearest point in a k-d tree to a point
%   tree is the tree to search
%   point is the point to find the nearest neighbor of
%   best is the current nearest neighbor. Default with best = Data(nan)
%   R is the current closest radius. Default with R = Data(realmax)
if tree.root == -1
    return;
end
root = tree.root;
dist = sum((root-point).^2);        %Minimize d^2 since d is a metric
if dist < R.data
   R.data = dist;
   best.data = root;
end
if tree.is_leaf()
    particle = best.data;
    return;
end
axis = tree.axis;
dx = point(1, axis) - root(1, axis);
if dx < 0
    near = tree.left;
    far = tree.right;
else
    near = tree.right;
    far = tree.left;
end
nearest_neighbor(near, point, best, R);
if(dx^2 >= R.data)      %x distance greater than current closest
    particle = best.data;
    return;
end
nearest_neighbor(far, point, best, R);
particle = best.data;
end

