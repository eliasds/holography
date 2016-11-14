classdef KDTree
    %Implementation of a KD Tree. TODO support nodes
    
    properties
        
        %Root value (tuple, will change to KDNode)
        root
        
        %Splitting axis. Should move into KDNode
        axis            %1=>x, 2=>y, 3=>z
        left
        right
        dim
        index       %Index in original array during creation
    end
    methods
        function obj = KDTree()
            obj.root = -1;      %Or nan
            obj.axis = -1;
            obj.dim = 3;
            obj.index = -1;
            obj.left = [];
            obj.right = [];
        end
        
        %{
        % node must be an instance of KDNode, or nan.
        function obj = KDTree(node)
            obj.root = node;
        end
        %}
        
        function bool = is_empty(tree)
            bool = isempty(tree.root);
        end
        
        %{
        % Checks if there are values in the tree.
        function empty = isEmpty(tree)
            empty = isnan(tree.root);
        end
        %}
        
        function leaf = is_leaf(tree) 
           leaf = isempty(tree.left) & isempty(tree.right); 
        end
        
        %{
        % Checks if a node is a leaf. node must be a KDNode.
        function leaf = isLeaf(node)
            return isnan(node.left) && isnan(node.right);
        end
        %}
        
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
        
        %{
        function node = insert(val)
            if size(val, 2) ~= obj.dim
                error('Wrong sized input for insert.');
            end
            node = KDNode(val);
            insertNode(node, val);
        end
        
        private function node = insertNode(node, val)
            %TODO
        end
        %}
        
        function tree = del(tree, point, coord)
           %TODO method stub
        end
        
        function tree = get(tree, point)
            %TODO method stub
        end
    end
    
end

