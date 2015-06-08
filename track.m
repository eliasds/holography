dist_thresh = 15;
% try
%     [dirname, filename, ext] = fileparts(xyzfile);
%     varnam=who('-file',xyzfile); xyzLoc=load(xyzfile,varnam{1});
%     xyzLoc=xyzLoc.(varnam{1});
% catch err
% end

tic
xyzLocOld = xyzLocCentroid;
clear xyzLocCentroid
xyzLocCentroid(length(xyzLocOld)-1).time = [];
for L = 1:length(xyzLocOld)-1
    
mat1 = xyzLocOld(L).time;
mat2 = xyzLocOld(L+1).time;
[l,~] = size(mat1);
[n,~] = size(mat2);

dist_mat = nan(l,n);
for M = 1:l
    for N = 1:n
        dist_mat(M,N) = sqrt((mat1(M,1)-mat2(N,1))^2 + (mat1(M,2)-mat2(N,2))^2);
    end
end
dist_mat_logic = dist_mat < dist_thresh;
numpartperframe(L) = sum(dist_mat_logic(:));
[mat1row, mat2row] = find(dist_mat_logic);
avgX = (mat1(mat1row,1) + mat2(mat2row,1))/2;
avgY = (mat1(mat1row,2) + mat2(mat2row,2))/2;
avgZ = (mat1(mat1row,3) + mat2(mat2row,3))/2;


xyzLocCentroid(L).time(:,1) = avgX;
xyzLocCentroid(L).time(:,2) = avgY;
xyzLocCentroid(L).time(:,3) = avgZ;

end

toc
    