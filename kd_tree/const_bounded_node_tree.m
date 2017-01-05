function [ node ] = const_bounded_node_tree( points, cd, dim, passing )
% CONST_NODE_TREE Helper function for const_bounded_tree. Constructs a 
% bounded tree of nodes to be attached to a KDTree object.
% @param points           points to build the node tree out of. Should be
%                         of size 1 x (dim + 1)
% @param coord            coordinate to split the plane of first node
% @param dim              dimension of space using
% @return                 node tree
    
    [root, left, right] = split(points, cd);
    node = KDNode(root(1:dim));
    node.axis = cd;
    node.index = root(dim + 1);
    lSize = size(left, 1); rSize = size(right, 1);
    mine = passing;          %make sure copied value, not reference
    if lSize > 0
        mine(cd, 1) = left(lSize, cd);
    end
    if rSize > 0
        mine(cd, 2) = right(1, cd);
    end
    node.bounds = mine;
    lPass = passing; rPass = passing;
    lPass(cd, 2) = node.val(cd);
    rPass(cd, 1) = node.val(cd);
    if ~isempty(left)
        node.left = const_bounded_node_tree(left, mod(cd, dim)+1, dim, lPass);
    end
    if ~isempty(right)
        node.right = const_bounded_node_tree(right, mod(cd, dim)+1, dim, rPass);
    end
    if ~isnan(node.left)
        node.left.parent = node;
    end
    if ~isnan(node.right)
        node.right.parent = node;
    end
end

