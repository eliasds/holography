classdef NodeArray < handle
    %NODEARRAY Handle class to pass for KDNode delete. Preallocates an 
    % array of given size to hold the KDNodes.
    
    properties
        
        % Row vector to hold information.
        array
        
        % Current index of end.
        index
        
    end
    
    methods
        
        % Constructs a new NodeArray with preallocated size.
        function obj = NodeArray(size)
            obj.array = KDNode.empty(size, 0);
            obj.index = 1;
        end
        
        % Adds a KDNode to the end of the array.
        function add(obj, node)
            obj.array(obj.index) = node;
            obj.index = obj.index + 1;
        end
        
    end
    
end

