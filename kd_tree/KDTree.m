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
                tree.insertNode(tree.root, val, tree.root.axis);
            end
        end
        
        % Finds the node containing a value in the tree.
        function node = find(tree, val)
            if size(val, 2) ~= tree.dim
                error('Wrong dimensions to find');
            elseif isnan(tree.root)
                node = nan;
            else
                node = tree.findNode(tree.root, val, tree.root.axis);
            end
        end
        
        % Deletes a node from the tree and returns it.
        function node = delete(tree, val)
            if size(val, 2) ~= tree.dim
                error('wrong dimensions');
            elseif isnan(tree)
                node = nan;
            else
                node = tree.deleteNode(tree.root, val, tree.root.axis);
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
        
        % Checks if the kd property will be violated by replacing the
        % node's value with val.
        function isKDified(tree, node, val)
            % TODO
            % Just have to check if the val is within the bounds
        end
                
        % Changes the value in a node and rekdifys the node if needed
        function changeVal(tree, node, val)
            if isKDified(tree, node, val)
                node.val = val;
            else
                tree.delete(node.val);
                % TODO: Make sure insert adds on proper bounds
                newNode = tree.insert(val);
                newNode.parent = node.parent;
                newNode.left = node.left;
                newNode.right = node.right;
                newNode.axis = node.axis;
                newNode.index = node.index;
            end
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
        function node = deleteNode(obj, node, point, cd)
            if isnan(node)
                node = 0;
                return;
            end
            if node.val == point
                if node.isLeaf()
                    node = nan;
                    return;         %not trying to modify node, just returning it
                elseif isnan(node.right)
                    node.val = obj.findMinNode(node.left, cd, mod(cd, obj.dim) + 1).val;
                    node.right = obj.deleteNode(node.left, node.val, mod(cd, obj.dim) + 1);
                    node.left = nan;
                else
                    node.val = obj.findMinNode(node.right, cd, mod(cd, obj.dim) + 1).val;
                    node.right = obj.deleteNode(node.right, node.val, mod(cd, obj.dim) + 1);
                end
            elseif point(1, cd) < node.val(1, cd)
                node.left = obj.deleteNode(node.left, point, mod(cd, obj.dim) + 1);
            elseif point(1, cd) > node.val(1, cd)
                node.right = obj.deleteNode(node.right, point, mod(cd, obj.dim) + 1);
            end
        end
        
        % Recursive helper function for findMin.
        function node = findMinNode(obj, node, axis, cd)
            if isnan(node) | isnan(node.val)
                data = nan(1, obj.dim);
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
        
        % Returns the node with the minimum value in the axis cutting
        % dimension.
        function node = minimumNode(~, n1, n2, n3, axis)
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

