function [root, left, right] = split(data, i)
% SPLIT Splits a group of data to find the root of a kd tree according to 
% an initial splitting plane in the orientation of the ith coordinate.
%
% @param data                   data to split
% @param i                      cutting dimension
% @return root                  root of tree
% @return left                  data for left subtree
% @return right                 data for right subtree

    sorted = tuple_sort(data, i);
    mid = ceil(size(data, 1) / 2);
    root = sorted(mid , :);
    left = sorted(1:mid-1, :);
    right = sorted(mid+1:end, :);
end