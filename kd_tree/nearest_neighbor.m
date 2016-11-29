
function [ node ] = nearest_neighbor( tree, point )
%NEAREST_NEIGHBOR finds the nearest point in a k-d tree to a point
%   @param tree is the tree to search
%   @param point is the point to find the nearest neighbor of
%   @param best is the current nearest neighbor. Default with best = Data(nan)
%   @param R is the current closest radius. Default with R = Data(realmax)
%   @return particle 3-tuple representing [x, y, z] location of particle

    if isnan(tree)
        return;
    end
    nodeData = nearest_node(tree.root, point, Data(nan), Data(realmax));
    node = nodeData.data;
end

