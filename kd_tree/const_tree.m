
function tree = const_tree(points)
% Constructs a kd tree out of the data points.
% @param points             array of points to create tree of
% @return                   KDTree with data points

    dim = 3;
    if isempty(points)
        tree = nan;
        return;
    end
    defaultAxis = 1;
    node = const_node_tree(points, defaultAxis, dim);
    tree = KDTree(node);
end
