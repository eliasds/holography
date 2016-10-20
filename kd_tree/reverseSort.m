function [ lst ] = reverseSort( lst )
%REVERSESORT Sorts a row vector from largest to smallest, removing any
%nan values it might have
%   @param  sortable        a 1xn row vector of ints
%   @return                 sorted from highest to lowest with no nans

for i = 1:length(lst)
    max = lst(i);
    init = max;
    if isnan(max)
        lst(i:end) = [];
        break;
    end
    index = i;
    for j = (i + 1):length(lst)
        elem = lst(j);
        if isnan(elem)
            break;
        end
        if elem > max
            max = elem;
            index = j;
        end
    end
    lst(i) = max;
    lst(index) = init;
end

end

