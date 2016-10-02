function [ stripped ] = strip_nans( mat, returnSize )
%STRIP_NANS Strips a matrix of rows containing 1:n nans
%@param mat         matrix to strip
%@param size        size of the rows in the matrix to return
%Check for row of nans and if none then return
n = 3;
%stripped = [];
rows = size(mat, 1);
stripped = nan(rows, returnSize);
cur = 1;
hasNans = false;
for i = 1:rows
    if ~isnan(mat(i, 1:n))
        %keep
        %Make sure that mat has an index dimension
        stripped(cur, :) = mat(i, :);
        cur = cur + 1;
    else
        hasNans = true;
    end
end
if ~hasNans
    stripped = mat;
    return;
end

while rows >= cur
    stripped(rows, :) = [];
    rows = rows - 1;
end

end

