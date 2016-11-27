
%best and R must be a Data object
%
function [ particle, index ] = nearest_neighbor( tree, point, best, R, best_index )
%NEAREST_NEIGHBOR finds the nearest point in a k-d tree to a point
%   @param tree is the tree to search
%   @param point is the point to find the nearest neighbor of
%   @param best is the current nearest neighbor. Default with best = Data(nan)
%   @param R is the current closest radius. Default with R = Data(realmax)
%   @return particle 3-tuple representing [x, y, z] location of particle
%   @return index the index of the particle from the original matrix

%TODO return the nearest node. You can get all the desired info from it

    if isempty(tree) | tree.root == -1
        return;
    end
    root = tree.root;
    dist = sum((root-point).^2);        %Minimize d^2 since d is > 0
    if dist < R.data
        R.data = dist;
        best.data = root;
        best_index.data = tree.index;
    end
    if tree.is_leaf()
        particle = best.data;
        index = best_index.data;
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
    nearest_neighbor(near, point, best, R, best_index);
    if(dx^2 >= R.data)      %x distance greater than current closest
        particle = best.data;
        index = best_index.data;
        return;
    end
    nearest_neighbor(far, point, best, R, best_index);
    particle = best.data;
    index = best_index.data;

%}

%{

function [ node ] = nearest_neighbor( tree, point )

    if isnan(tree)
        return;
    end
    %nodeData should return a Data object with a KDNode as the data
    nodeData = nearest_node(tree.root, point, Data(nan), Data(realmax));
    node = nodeData.data;
%}

end

