classdef KDTree
    %Implementation of a KD Tree. TODO support nodes
    
    properties
        %
        root
        %Splitting axis. Should move into KDNode
        axis            %1=>x, 2=>y, 3=>z
        left
        right
        dim
        index       %Index in original array during creation
        %}
        
        %{
        %Root value (tuple, will change to KDNode)
        root
        %}
    end
    methods
        %
        function obj = KDTree()
            obj.root = -1;      %Or nan
            obj.axis = -1;
            obj.dim = 3;
            obj.index = -1;
            obj.left = [];
            obj.right = [];
        end
        
        function bool = is_empty(tree)
            bool = isempty(tree.root);
        end
        
        function leaf = is_leaf(tree) 
           leaf = isempty(tree.left) & isempty(tree.right); 
        end
        
        % point is a 1x3 matrix to insert into the tree
        function tree = insert(tree, point, coord)
           if tree.root == -1 | isempty(tree)
               tree = KDTree();
               tree.root = point;
           elseif tree.root == point
               tree = 'Error';
               return;
           elseif point(1, coord) < tree.root(1, coord)
               tree.left = insert(tree.left, point, mod(coord, tree.dim)+1);
           else
               tree.right = insert(tree.right, point, mod(coord, tree.dim)+1);
           end
        end
        
        function tree = del(tree, point, coord)
           %TODO method stub
        end
        
        function tree = get(tree, point)
            %TODO method stub
        end
        
        %}
        
        %{
        
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
        
        % Finds the node containing a value in the tree.
        function node = find(val)
            if size(val, 2) ~= obj.dim
                error('Wrong dimensions to find');
            elseif isnan(obj.root)
                node = 0;
            else
                node = findNode(obj.root, val, 1);
            end
        end
        
        % Recursive helper function for find.
        function node = findNode(node, point, coord)
            if isnan(node.val)
                node = 0;
            elseif point == node.val
                return;
            elseif point(1, coord) < node.val
                node = findNode(node.left, point, mod(coord, obj.dim) + 1);
            else
                node = findNode(node.right, point, mod(coord, obj.dim) + 1);
            end
        end
        
        % Deletes a node from the tree and returns it.
        function node = delete(val)
            
        end
        
        %}
        
    end
    
end

