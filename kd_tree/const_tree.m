
%{
    Creates a k-d tree out of the given points with the first splitting 
    plane in the orientation of the given coord (should be 1, 2, or 3)
%}
function tree = const_tree(points, coord)
    %Dim of matrix entered must be dim+1; The 4th column is devoted to
    %storing index values of the matrix so that they can easily be
    %retrieved later
    %TODO deal with a [NaN, NaN, NaN] point
    dim = 3;
    if coord > dim
        error('invalid coordinate entered');
    end
    if isempty(points)
        tree = nan;
        return;
    end
    
    %
    [root, left, right] = split(points, coord);
    tree = KDTree();
    tree.root = root(1:3);      %root has extra number-- original index
    tree.axis = coord;
    tree.index = root(4);
    if ~isempty(left)
        tree.left = const_tree(left, mod(coord, dim)+1);
    end
    if ~isempty(right)
        tree.right = const_tree(right, mod(coord, dim)+1);
    end
    %}
    
    %{
    node = const_node_tree(points, coord, dim);
    tree = KDTree(node);
    %}
end
