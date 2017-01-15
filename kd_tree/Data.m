classdef Data < handle
    %DATA container class to hold info so I can pass it by reference while 
    % recursing
    
    properties
        
        % Data that is held.
        data
        
    end
    
    methods
        function obj = Data(data)
            obj.data = data;
            obj.index = 1;
        end
    end
    
end

