classdef KDTree
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
        left
        right
    end
    methods
        function obj = KDTree()
            obj.root = -1;      %Or nan
            obj.left = [];
            obj.right = [];
        end
        
        function leaf = is_leaf(tree) 
           leaf = isempty(tree.left) & isempty(tree.right); 
        end
        
    end
    
end

