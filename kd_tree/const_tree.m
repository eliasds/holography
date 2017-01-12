
function tree = const_tree(points)
% Constructs a kd tree out of the data points.
% @param points             array of points to create tree of. Should have
%                           numColumns = dim + 1.
% @return                   KDTree with data points

    dim = size(points, 2) - 1;
    if isempty(points)
        tree = nan;
        return;
    end
    defaultAxis = 1;
    node = const_node_tree(points, defaultAxis, dim);
    tree = KDTree(node);
    tree.dim = dim;
    tree.size = size(points, 1);
end
