classdef KDTree
    % Implementation of a KD Tree. Each KDTree has a root object, which
    % is an instance of KDNode.
    
    properties

        % Root value (KDNode)
        root

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
        
        % Inserts a value into the KDTree.
        function node = insert(val)
            if size(val, 2) ~= obj.dim
                error('Wrong sized input for insert.');
            end
            if isnan(tree.root)
                tree.root = KDNode(val);
            else
                insertNode(obj.root, val, 1);
            end
        end
        
        % Finds the node containing a value in the tree.
        function node = find(val)
            if size(val, 2) ~= obj.dim
                error('Wrong dimensions to find');
            elseif isnan(obj.root)
                node = nan;
            else
                node = findNode(obj.root, val, 1);
            end
        end
        
        % Deletes a node from the tree and returns it.
        function node = delete(val)
            if size(val, 2) ~= obj.dim
                error('wrong dimensions');
            elseif isnan(obj.root)
                node = nan;
            else
                node = deleteNode(obj.root, val, 1);
            end
        end
        
        % Finds the minimum value w.r.t the dth splitting axis
        function node = findMin(d)
            %TODO
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
        function node = insertNode(node, point, coord)
            if point(1, coord) < node.val(1, coord)
                if isnan(node.left)
                    child = KDNode(point);
                    child.parent = node;
                    child.axis = coord;
                    %child.index = TODO
                    node.left = child;
                else
                    insertNode(node.left, point, mod(coord, obj.dim) + 1);
                end
            else
                if isnan(node.right)
                    child = KDNode(point);
                    child.parent = node;
                    child.axis = coord;
                    %TODO child.index = ...
                    node.right = child;
                else
                    insertNode(node.right, point, mod(coord, obj.dim) + 1);
                end
            end
        end
        
        % Recursive helper function for find.
        function node = findNode(node, point, coord)
            if isnan(node.val)
                node = 0;
            elseif point == node.val(1, coord)
                return;
            elseif point(1, coord) < node.val(1, coord)
                node = findNode(node.left, point, mod(coord, obj.dim) + 1);
            else
                node = findNode(node.right, point, mod(coord, obj.dim) + 1);
            end
        end
        
        % Recursive helper function for delete.
        function node = deleteNode(node, point, coord)
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
        function findMinNode(node, axis, coord)
            %TODO
        end
        
        % Gets the up (parent's) direction for the corresponding down
        % direction
        function upAxis = getUpAxis(obj, axis)
            %TODO
        end
        
    end
    
end

