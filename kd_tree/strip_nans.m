function [ stripped ] = strip_nans( mat, n )
%STRIP_NANS Strips a matrix of rows containing 1:n nans
stripped = [];
rows = size(mat, 1);
stripped = nan(rows, n+1);
cur = 1;
for i = rows
    if ~isnan(mat(i, 1:n))
        %keep
        stripped(cur, :) = mat(i, :);
        cur = cur + 1;
    end
end
while cur <= rows      %Delete extras
    stripped(cur, :) = [];
    cur = cur + 1;
end

end

