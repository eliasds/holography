classdef KDNode < handle
    %KDNODE Node object for a KDTree to use
    
    properties
        
        % Val is a 3-tuple, or nan if no value.
        val
        
        % Left is a KDNode or nan if no left child.
        left
        
        % Right is a KDNode or nan if no right child.
        right
        
        % Parent is a KDNode or nan if this node is the root.
        parent
        
        % Splitting axis. 1 -> x, 2 -> y, 3 -> z.
        axis
        
        % Index in original data set, used for nearest_neighbor purposes.
        index
    end
    
    methods
        
        %Constructs a new KDNode.
        function obj = KDNode(label)
            obj.val = label;
            obj.left = nan;
            obj.right = nan;
            obj.axis = nan;
            obj.index = nan;
            obj.parent = nan;
        end
        
        % An instantiated object is never nan.
        function bool = isnan(node)
            bool = 0;       %TODO make it isnan(node.val)
        end
        
        % Checks if a node is a leaf. node must be a KDNode.
        function leaf = isLeaf(node)
            leaf = isnan(node.left) && isnan(node.right);
        end
    end
    
end

