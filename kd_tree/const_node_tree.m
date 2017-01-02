function [ node ] = const_node_tree( points, coord, dim )
% CONST_NODE_TREE Helper function for const_tree. Constructs a tree of
% nodes to be attached to a KDTree object.
% @param points           points to build the node tree out of. Should be
%                         of size 1 x (dim + 1)
% @param coord            coordinate to split the plane of first node
% @param dim              dimension of space using
% @return                 node tree

    [root, left, right] = split(points, coord);
    node = KDNode(root(1:dim));
    node.axis = coord;
    node.index = root(dim + 1);
    if ~isempty(left)
        node.left = const_node_tree(left, mod(coord, dim)+1, dim);
    end
    if ~isempty(right)
        node.right = const_node_tree(right, mod(coord, dim)+1, dim);
    end
    if ~isnan(node.left)
        node.left.parent = node;
    end
    if ~isnan(node.right)
        node.right.parent = node;
    end
end

