classdef KDTree < handle
    % Implementation of a KD Tree. Each KDTree has a root object, which
    % is an instance of KDNode.
    
    properties (Access = public)

        % Root value (KDNode)
        root
        
        % Dimension of points
        dim
        
        % Number of nodes in the tree.
        size

    end
    
    properties (Access = private)
        
        % Infinite value. TODO change to realmax.
        infty = 1000;
        
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
                node = tree.root;
            else
                node = tree.insertNode(tree.root, val, tree.root.axis);
                if ~isnan(node)
                    tree.size = tree.size + 1;
                end
            end
        end
        
        % Inserts a value into the KDTree and updates bounds. Value must 
        % have an index attached at the end.
        function boundedInsert(tree, val)
            if size(val, 2) ~= tree.dim + 1
                error('Wrong sized input for insert.');
            end
                passing = [];
            for i = 1 : tree.dim
                passing(i, :) = [-tree.infty tree.infty];
            end
            if isnan(tree.root)
                tree.root = KDNode(val);
                tree.root.bounds = passing;
                node = tree.root;
            else
                node = tree.insertBoundedNode(tree.root, val, tree.root.axis, passing);
                if ~isnan(node)
                    tree.size = tree.size + 1;
                end
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
                if ~isnan(node)
                    tree.size = tree.size - 1;
                end
            end
        end
        
        % Deletes a node from the tree and updates bounds. Returns the 
        % deleted node.
        function node = boundedDelete(tree, val)
            if size(val, 2) ~= tree.dim
                error('wrong dimensions');
            elseif isnan(tree)
                node = nan;
            else
                flagged = Data(nan(1, tree.size));
                node = tree.deleteBoundedNode(tree.root, val, ... 
                    tree.root.axis, flagged);
                if ~isnan(node)
                    tree.size = tree.size - 1;
                end
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
        
        % Finds the minimum value w.r.t. the cutting dimension cd.
        function node = findMax(tree, cd)
            if cd > tree.dim
                error('cutting dimension too large.');
            else
                node = tree.findMaxNode(tree.root, cd, tree.root.axis);
            end
        end
        
        % Checks if the kd property will be violated by replacing the
        % node's value with val.
        function bool = isKDified(tree, node, val)
            bool = 1;
            for i = 1 : tree.dim
                if val(i) < node.bounds(i, 1) | val(i) > node.bounds(i, 2)
                    bool = 0;
                    return;
                end
            end
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
        function inserted = insertNode(obj, node, point, cd)
            if point(cd) < node.val(cd)
                if isnan(node.left)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = cd;
                    child.index = point(obj.dim + 1);
                    node.left = child;
                    inserted = child;
                else
                    inserted = obj.insertNode(node.left, point, ...
                        mod(cd, obj.dim) + 1);
                end
            else
                if isnan(node.right)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = cd;
                    child.index = point(obj.dim + 1);
                    node.right = child;
                    inserted = child;
                else
                    inserted = obj.insertNode(node.right, point, ...
                        mod(cd, obj.dim) + 1);
                end
            end
        end
        
        % Recursive helper function for boundedInsert.
        function inserted = insertBoundedNode(obj, node, point, cd, passing)
            if point(cd) < node.val(cd)
                passing(cd, 2) = node.val(cd);
                if node.bounds(cd, 1) < point(cd)
                    node.bounds(cd, 1) = point(cd);
                end
                if isnan(node.left)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = cd;
                    child.index = point(obj.dim + 1);
                    child.bounds = passing;
                    node.left = child;
                    inserted = child;
                else
                    inserted = obj.insertBoundedNode(node.left, point, ...
                        mod(cd, obj.dim) + 1, passing);
                end
            else
                passing(cd, 1) = node.val(1, cd);
                if node.bounds(cd, 2) > point(cd)
                    node.bounds(cd, 2) = point(cd);
                end
                if isnan(node.right)
                    child = KDNode(point(1:obj.dim));
                    child.parent = node;
                    child.axis = cd;
                    child.index = point(obj.dim + 1);
                    child.bounds = passing;
                    node.right = child;
                    inserted = child;
                else
                    inserted = obj.insertBoundedNode(node.right, point, ...
                        mod(cd, obj.dim) + 1, passing);
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
                    return;
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
        
        % Recursive helper function for boundedDelete
        function node = deleteBoundedNode(obj, node, point, cd, flagged)
            
        end
        
        % Recursive helper function for findMin.
        function node = findMinNode(obj, node, axis, cd)
            if isnan(node) | isnan(node.val)
                node = nan;
            elseif node.isLeaf()
                return;
            elseif cd == axis
                if ~isnan(node.left)
                    node = obj.findMinNode(node.left, axis, mod(cd, obj.dim) + 1);
                end
            else
                left = obj.findMinNode(node.left, axis, mod(cd, obj.dim) + 1);
                right = obj.findMinNode(node.right, axis, mod(cd, obj.dim) + 1);
                node = obj.minThreeNode(node, left, right, axis);
            end
        end
        
        % Recursive helper function for findMax.
        function node = findMaxNode(obj, node, axis, cd)
           if isnan(node) | isnan(node.val)
               node = nan;
           elseif node.isLeaf()
               return;
           elseif cd == axis
               if ~isnan(node.right)
                   node = obj.findMaxNode(node.right, axis, mod(cd, obj.dim) + 1);
               end
           else
               left = obj.findMaxNode(node.left, axis, mod(cd, obj.dim) + 1);
               right = obj.findMaxNode(node.right, axis, mod(cd, obj.dim) + 1);
               node = obj.maxThreeNode(node, left, right, axis);
           end
        end
        
        % Returns the node with the minimum value in the axis cutting
        % dimension. Takes three nodes as parameters.
        function node = minThreeNode(obj, n1, n2, n3, cd)
            if isnan(n1)
                node = obj.minTwoNode(n2, n3, cd); return;
            elseif isnan(n2)
                node = obj.minTwoNode(n1, n3, cd); return;
            elseif isnan(n3)
                node = obj.minTwoNode(n1, n2, cd); return;
            end
            val1 = n1.val(cd); val2 = n2.val(cd); val3 = n3.val(cd);
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
        
        % Returns the node with the minimum value in the proper cutting 
        % dimension. Takes two nodes as parameters.
        function node = minTwoNode(~, n1, n2, cd)
            if isnan(n1)
                node = n2; return;
            elseif isnan(n2)
                node = n1; return;
            end
            if n1.val(cd) < n2.val(cd)
                node = n1;
            else
                node = n2;
            end
        end
        
        % Returns the node with the maximum value in the proper cutting 
        % dimension. Takes 3 nodes as parameters.
        function node = maxThreeNode(obj, n1, n2, n3, cd)
            if isnan(n1)
                node = obj.maxTwoNode(n2, n3, cd);
                return;
            elseif isnan(n2)
                node = obj.maxTwoNode(n1, n3, cd);
                return;
            elseif isnan(n3)
                node = obj.maxTwoNode(n1, n2, cd);
                return;
            end
            val1 = n1.val(cd); val2 = n2.val(cd); val3 = n3.val(cd);
            if val1 > val2
                if val1 > val3
                    node = n1;
                else
                    node = n3;
                end
            else
                if val2 > val3
                    node = n2;
                else
                    node = n3;
                end
            end
        end
        
        % Returns the node with the maximum value in the proper cutting 
        % dimension. Takes 2 nodes as parameters.
        function node = maxTwoNode(~, n1, n2, cd)
            if isnan(n1)
                node = n2; return;
            elseif isnan(n2)
                node = n1; return;
            end
            if n1.val(cd) > n2.val(cd)
                node = n1;
            else
                node = n2;
            end
        end
        
        % Gets the up (parent's) direction for the corresponding down
        % direction
        function upAxis = getUpAxis(obj, axis)
            %TODO
        end
        
    end
    
end

