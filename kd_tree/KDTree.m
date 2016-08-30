classdef KDTree
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
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
        
        function bool = is_empty(tree)
            bool = isempty(tree.root)
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
        
        function tree = del(tree, point)
           %TODO method stub 
        end
    end
    
end

