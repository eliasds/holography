function [ stripped ] = strip_nans( mat, n )
%STRIP_NANS Strips a matrix of rows containing 1:n nans
%   TODO preallocate array for better speed
stripped = [];
for i = 1:size(mat, 1)
    if ~isnan(mat(i, 1:n))
        %keep
        stripped(end+1, :) = mat(i, :);
    end
end

end

