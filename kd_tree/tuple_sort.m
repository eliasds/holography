
function [ result ] = tuple_sort( data, i )
    %TODO preallocate result for speed
    result = [];
    mid = ceil(size(data, 1) / 2);
    if size(data, 1) < 2
        result = data;
        return
    elseif size(data, 1) == 2
        left = tuple_sort(data(1, :), i);
        right = tuple_sort(data(2, :), i);
    else
        left = tuple_sort(data(1:mid-1, :), i);
        right = tuple_sort(data(mid:end, :), i);
    end
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
            for j = 1:size(right, 1)
                result = [result; right(j, :)];
            end
            break
        else        %Then left not empty
            for j = 1:size(left, 1)
               result = [result; left(j, :)];
            end
            break
        end
    end
end

