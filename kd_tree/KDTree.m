classdef KDTree
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
        axis            %1=>x, 2=>y, 3=>z
        left
        right
    end
    methods
        function obj = KDTree()
            obj.root = -1;      %Or nan
            obj.axis = -1;
            obj.left = [];
            obj.right = [];
        end
        
        function bool = is_empty(tree)
            bool = isempty(tree.root)
        end
        
        function leaf = is_leaf(tree) 
           leaf = isempty(tree.left) & isempty(tree.right); 
        end
        
        % point is a 1x3 matrix to inset into the tree
        function tree = insert(tree, point)
           %TODO method stub 
        end
        
        function tree = remove(tree, point)
           %TODO method stub 
        end
    end
    
end

