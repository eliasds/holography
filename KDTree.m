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
            obj.root = nan;
            obj.left = [];
            obj.right = [];
        end
        
        function obj = setLeft(left)
            obj.left = left;
        end
        
        function obj = setRight(right)
            obj.right = right;
        end
        
        
    end
    
end

function tree = constTree(points, coord)
    dim = 2;
    if coord > dim
        tree = 'PROBLEM';
        return;
    end
    if isempty(points)
        tree = 'No points';
        return;
    end
    [root, left, right] = split(points, coord);
    
end

function [root, left, right] = split(data, i)
    sorted = sort(data, i);
    mid = ceil(length(data) / 2);
    root = sorted(mid , :);
    left = sorted(1:mid-1, :);
    right = sorted(mid+1:end, :);
end

%Merge sort algorithm for tuples. Sort by the ith spot in the tuple
function result = sort(data, i)
    %TODO preallocate result for speed
    result = [];
    mid = ceil(length(data) / 2);
    if length(data) < 2
        result = data;
        return;
    end
    left = sort(data(1:mid-1, :), i);
    right = sort(data(mid:end, :), i);
    while ~isempty(left) | ~isempty(right)
        if ~isempty(left) & ~isempty(right)
            if left(1, i) > right(1, i)
               result = [result; right(1, :)];
               right = right(2:end, :);
            else
               result = [result; left(1, :)];
               left = left(2:end, :);
            end
        elseif ~isempty(right)
            %for list in right, append to result
            for j = 1:length(right)
                result = [result; right(j, :)];
                return;
            end
        else        %Then left not empty
            for j = 1:length(left)
               result = [result; left(j, :)];
               return;
            end
        end
    end
    
end
