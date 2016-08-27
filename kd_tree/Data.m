classdef Data < handle
    %DATA container class to hold info so I can pass it by reference while 
    % recursing
    %   Detailed explanation goes here
    
    properties
        data
    end
    
    methods
        function obj = Data(data)
            obj.data = data;
        end
    end
    
end

