function [ best ] = nearest_node( node, point, best, R )
%NEAREST_NODE Helper function for nearest_neighbor. Given a KDNode,
%recursively finds the node value that minimizes distance to a point.
%   @param node is the node to search
%   @param point is the point to find the nearest neighbor of
%   @param best is the current nearest neighbor. Default with best = Data(nan)
%   @param R is the current closest radius. Default with R = Data(realmax)
%   @return Data object with node as value that minimizes distance to point

    if isnan(node)
        return;
    end
    root = node.val;
    dist = sum((root-point).^2);        %Minimize d^2 since d is > 0
    if dist < R.data
        R.data = dist;
        best.data = node;
    end
    if node.isLeaf()
        return;
    end
    axis = node.axis;
    dx_i = point(1, axis) - root(1, axis);
    if dx_i < 0
        near = node.left;
        far = node.right;
    else
        near = node.right;
        far = node.left;
    end
    nearest_node(near, point, best, R);
    if(dx_i^2 >= R.data)      %x distance greater than current closest
        return;
    end
    nearest_node(far, point, best, R);
end
