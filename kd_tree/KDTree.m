classdef KDTree < handle
    % Implementation of a KD Tree. Each KDTree has a root object, which
    % is an instance of KDNode.
    
    properties

        % Root value (KDNode)
        root
        
        % Dimension of points
        dim

    end
    methods (Access = public)
        
        % Constructs a new KDNode
        function obj = KDTree(node)
            obj.root = node;
        end
        
        % An instantiated KDTree is never nan.
        function bool = isnan(tree)
            bool = isnan(tree.root);
        end
        
        % Checks if there are values in the tree.
        function empty = isEmpty(tree)
            empty = isnan(tree.root);
        end
        
        % Inserts a value into the KDTree. Value must have an index
        % attached at end.
        function node = insert(tree, val)
            if size(val, 2) ~= tree.dim + 1
                error('Wrong sized input for insert.');
            end
            if isnan(tree.root)
                tree.root = KDNode(val);
            else
%                insertNode(tree.root, val, 1);
                tree.insertNode(tree.root, val, 1);
            end
        end
        
        % Finds the node containing a value in the tree.
        function node = find(tree, val)
            if size(val, 2) ~= tree.dim
                error('Wrong dimensions to find');
            elseif isnan(tree.root)
                node = nan;
            else
                node = tree.findNode(tree.root, val, 1);
            end
        end
        
        % Deletes a node from the tree and returns it.
        function node = delete(tree, val)
            if size(val, 2) ~= tree.dim
                error('wrong dimensions');
            elseif isnan(tree.root)
                node = nan;
            else
                node = deleteNode(tree.root, val, 1);
            end
        end
        
        % Finds the minimum value w.r.t the cutting dimension cd.
        function node = findMin(tree, cd)
            if cd > tree.dim
                error('cutting dimension too large.');
            else
                node = tree.findMinNode(tree.root, cd, tree.root.axis);
            end
        end
        
        % Reestablishes the kd property for an arbitrary node
        function kdify(obj, node)
            parAxis = obj.getUpAxis(node.axis);
            %TODO
        end
        
        % Changes the value in a node and rekdifys the node if needed
        function changeVal(obj, node, val)
            node.val = val;
            obj.kdify(node);
        end
        
    end
    
    methods (Access = private)
        
        % Recursive helper function for insert.
        function node = insertNode(obj, node, point, coord)
            if point(1, coord) < node.val(1, coord)
                if isnan(node.left)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = coord;
                    child.index = point(obj.dim + 1);
                    node.left = child;
                else
                    obj.insertNode(node.left, point, mod(coord, obj.dim) + 1);
                end
            else
                if isnan(node.right)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = coord;
                    child.index = point(obj.dim + 1);
                    node.right = child;
                else
                    obj.insertNode(node.right, point, mod(coord, obj.dim) + 1);
                end
            end
        end
        
        % Recursive helper function for find.
        function node = findNode(obj, node, point, coord)
            if isnan(node) | isnan(node.val)
                node = 0;
            elseif point == node.val
                return;
            elseif point(coord) < node.val(coord)
                node = obj.findNode(node.left, point, mod(coord, obj.dim) + 1);
            else
                node = obj.findNode(node.right, point, mod(coord, obj.dim) + 1);
            end
        end
        
        % Recursive helper function for delete.
        function node = deleteNode(obj, node, point, coord)
            if isnan(node)
                return;
            end
            if node.val == point
                if isnan(t.left) && isnan(t.right)
                    node = nan;
                    return;
                elseif isnan(t.right)
                    t.val = findMin(t.right, coord, mod(coord, obj.dim) + 1);
                else
                    t.val = findMin(t.left, coord, mod(coord, obj.dim) + 1);
                end
                %TODO
            elseif point(1, coord) < node.val(1, coord)
                node.left = deleteNode(node.left, point, mod(coord, obj.dim) + 1);
            elseif point(1, coord) > node.val(1, coord)
                node.right = deleteNode(node.right, point, mod(coord, obj.dim) + 1);
            end
        end
        
        % Recursive helper function for findMin.
        function node = findMinNode(obj, node, axis, cd)
            if isnan(node) | isnan(node.val)
                data = nan(obj.dim);
                data(cd) = realmax;
                node = KDNode(data);
            elseif node.isLeaf()
                return;
            elseif cd == axis
                if ~isnan(node.left)
                    node = obj.findMinNode(node.left, axis, mod(cd, obj.dim) + 1);
                end
            else
                left = obj.findMinNode(node.left, axis, mod(cd, obj.dim) + 1);
                right = obj.findMinNode(node.right, axis, mod(cd, obj.dim) + 1);
                node = obj.minimumNode(node, left, right, axis);
            end
        end
        
        function node = minimumNode(obj, n1, n2, n3, axis)
            val1 = n1.val(axis); val2 = n2.val(axis); val3 = n3.val(axis);
            if val1 < val2
                if val1 < val3
                    node = n1;
                else
                    node = n3;
                end
            else
                if val2 < val3
                    node = n2;
                else
                    node = n3;
                end
            end
        end
        
        % Gets the up (parent's) direction for the corresponding down
        % direction
        function upAxis = getUpAxis(obj, axis)
            %TODO
        end
        
    end
    
end

