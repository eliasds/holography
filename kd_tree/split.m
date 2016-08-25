
%{
    Splits a group of data to find the root of a k-d tree according to an
    initial splitting plane in the orientation of the ith coordinate
%}
function [root, left, right] = split(data, i)
    sorted = tuple_sort(data, i);
    mid = ceil(size(data, 1) / 2);
    root = sorted(mid , :);
    left = sorted(1:mid-1, :);
    right = sorted(mid+1:end, :);
end