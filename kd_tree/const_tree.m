
%{
    Creates a k-d tree out of the given points with the first splitting 
    plane in the orientation of the given coord (should be 1, 2, or 3)
%}
function tree = const_tree(points, coord)
    dim = 2;
    if coord > dim
        tree = 'PROBLEM';
        return;
    end
    if isempty(points)
        tree = 'No points';
        return;
    end
    [root, left, right] = split(points, coord);
    tree = KDTree();
    tree.root = root;
    if ~isempty(left)
        tree.left = const_tree(left, mod(coord, dim)+1);
    end
    if ~isempty(right)
        tree.right = const_tree(right, mod(coord, dim)+1);
    end
end
