dist_thresh = 15;
% try
%     [dirname, filename, ext] = fileparts(xyzfile);
%     varnam=who('-file',xyzfile); xyzLoc=load(xyzfile,varnam{1});
%     xyzLoc=xyzLoc.(varnam{1});
% catch err
% end

tic
xyzLocOld = xyzLocCentroid;

%looking at 3 frames each iteration
for L = 1:length(xyzLocOld) - 2
    %extracting the position information for the particles in
    %each frame
    mat1 = xyzLocOld(L).time;
    xyzLocOld(L).time = [];
    mat2 = xyzLocOld(L+1).time;
    xyzLocOld(L+1).time = [];
    mat3 = xyzLocOld(L+2).time;
    xyzLocOld(L+2).time = [];
    %l, n, and p are the number of particles in frames 1, 2, and 3
    %respectively
    [l,~] = size(mat1);
    [n,~] = size(mat2);
    [p,~] = size(mat3);
    
    %creates matrix with distances between every particle in the
    %first frame and second frame
    %rows correspond to frame 1, columns to frame 2
    dist_mat = nan(l,n);
    for M = 1:l
        for N = 1:n
            dist_mat(M,N) = sqrt((mat1(M,1)-mat2(N,1))^2 + (mat1(M,2)-mat2(N,2))^2);
        end
    end
    
    %logical array with 1 where the distance between two particles
    %in subsequent frames is small enough that you can assume
    %they are the same particle
    dist_mat_logic = dist_mat < dist_thresh;
    
    %checks that number of distinct particles in a frame matches
    %the number of particles being tracked
    numpartperframe(L) = sum(dist_mat_logic(:));
    
    %returns indices of matches
    [mat1row, mat2row] = find(dist_mat_logic);
    
    %projected x and y positions of particles
    projection = nan(length(mat1row),2);
    
    xyzLocOld(L).time = zeros(length(mat1row),3);
    %for every match found
    for i = 1:length(mat1row)
        xyzLocOld(L).time(i,:) = xyzLocCentroid(L).time(mat1row(i),:);
        x1 = mat1(mat1row(i),1);
        x2 = mat2(mat2row(i),1);
        y1 = mat1(mat1row(i),2);
        y2 = mat2(mat2row(i),2);
        
        %projected x position
        projection(i,1) = 2 * x2 - x1;
        
        %projected y position
        projection(i,2) = 2 * y2 - y1;
    end
    
    %if particles don't pass threshold, means they don't have a
    %buddy and should be removed
    min_threshold = 10;
    
    %for every projection
    dist_mat1 = nan(p,1);
    index = 1;
    for P = 1:p
        for Q = 1:length(projection)
            %create column vector of distance to points in frame 3
            dist_mat1(Q,1) = sqrt((projection(Q,1)-mat3(P,1))^2 + (projection(Q,2)-mat3(P,2))^2);
        end
        %if projection is close enough to a particle,
        %keep tracking it
        if min(dist_mat1) < min_threshold
            xyzLocOld(L+1).time(index,:) = xyzLocCentroid(L+1).time(P,:);
            index = index + 1;
        end
    end
    
    
    %             avgX = (mat1(mat1row,1) + mat2(mat2row,1))/2;
    %             avgY = (mat1(mat1row,2) + mat2(mat2row,2))/2;
    %             avgZ = (mat1(mat1row,3) + mat2(mat2row,3))/2;
    %
    %
    %             xyzLocCentroid(L).time(:,1) = avgX;
    %             xyzLocCentroid(L).time(:,2) = avgY;
    %             xyzLocCentroid(L).time(:,3) = avgZ;
    
end

toc
