classdef KDNode
    %KDNODE Node object for a KDTree to use
    
    properties
        
        % Val is a 3-tuple, or nan if no value.
        val
        
        % Left is a KDNode or nan if no left child.
        left
        
        % Right is a KDNode or nan if no right child.
        right
        
        % Splitting axis. 1 -> x, 2 -> y, 3 -> z.
        axis
        
        % Index in original data set, used for nearest_neighbor purposes.
        index
    end
    
    methods
        function obj = KDNode(label)
            obj.val = label;
            obj.left = nan;
            obj.right = nan;
            obj.axis = nan;
            obj.index = nan;
        end
    end
    
end

