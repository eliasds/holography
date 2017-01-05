
function tree = const_bounded_tree(points)
% Constructs a bounded kd tree out of the data points.
% @param points             array of points to create tree of. Should have
%                           numColumns = dim + 1.
% @return                   KDTree with data points

    dim = size(points, 2) - 1;
    if isempty(points)
        tree = nan;
        return;
    end
    defaultAxis = 1;
    infty = 1000;        %TODO change to handle
    passing = [];
    for i = 1 : dim
        passing(i, :) = [-infty infty];
    end
    node = const_bounded_node_tree(points, defaultAxis, dim, passing);
    tree = KDTree(node);
    tree.dim = dim;
end
