% Particle tracking
% Struct array "particles" contains all the particles with field "pos" + "match" 
    % pos : x, y, z
    % match : 1/0
    
dist_thresh = 15;
appear_thresh = 10;
blink_keep = 5;

tic

xyzLocCentroid1 = xyzLocCentroid;
for i = 1:length(xyzLocCentroid)
    xyzLocCentroid1(i).time(:,3) = xyzLocCentroid1(i).time(:,3)/ps;
end

%Initialize struct array, with all particles in frame 1 + 2
particles = struct([]);
init = xyzLocCentroid1(1).time;  
for i = 1:size(init,1)
    particles(i).pos(1,:) = init(i,:);
    particles(i).match(1,1) = 0;
end

%Go through each frame, tracking particles
for L = 2:length(xyzLocCentroid)
    mat1 = xyzLocCentroid1(L-1).time;
    mat2 = xyzLocCentroid1(L).time;
    [m,~] = size(mat1);
    [n,~] = size(mat2);
    
    %Creates dist matrix between every particle in frame L and L + 1
    dist_mat = nan(m,n);
    for M = 1:m
        for N = 1:n
            dist_mat(M,N) = sqrt((mat1(M,1)-mat2(N,1))^2 + ...
                (mat1(M,2)-mat2(N,2))^2 + (mat1(M,3)-mat2(N,3))^2);
        end
    end
    
    %Thresholds + finds match
    dist_mat_logic = dist_mat < dist_thresh;
    
    %Copies pos for next blink_keep frames    
    for j = 1:length(particles)
        repeat = 0;
        for i = 1:blink_keep
            particles(j).pos(L+i-1,:) = nan(1,3);
            particles(j).match(L+i-1,1) = 0;
            
            if L-i > 0 && particles(j).match(L-i,1) == 1
                repeat = 1;
            end
        end
        
        if repeat
            particles(j).match(L,1) = 0;
            particles(j).pos(L,:) = particles(j).pos(L-1,:);
        end
    end
    
    partLength = length(particles);
    dist = zeros(n, partLength);
    keep = ones(partLength,1);
    for j = 1:partLength
        for i = 1:n
            dist(i,j) = sqrt((particles(j).pos(L-1,1)-mat2(i,1))^2 + ...
                (particles(j).pos(L-1,2)-mat2(i,2))^2 + ...
                (particles(j).pos(L-1,3)-mat2(i,3))^2);
        end
        for k = 1:blink_keep
            if L-k > 0 && ~particles(j).match(L-k,1)
                keep(j,1) = keep(j,1) + 1;
            end
        end
    end
            
    
    %Append matches in L+1 to corresponding particles or adds them as new
    %particles
    partLength = length(particles);
    for i = 1:n
        isInMatch = 0;  
        index = find(dist_mat_logic(:,i));
        min_z = abs(mat2(i,3) - mat1(index,3));
        [~,minInd] = min(min_z);
        
        dist_logic = dist(i,:)' < keep*dist_thresh;
        distIndex = find(dist_logic);
        keepMatch = 0;
        for j = 1:partLength
            
            if ~isempty(distIndex) && ~particles(j).match(L-1,1)
                for k = 1:length(distIndex)
                    if distIndex(k) == j
                        keepMatch = 1;
                    end
                end
            end
                
            %If match, record index of particle in particles
            if (~isempty(index) && isequal(mat1(index(minInd),:), ...
                    particles(j).pos(L-1,:))) || keepMatch
                isInMatch = 1; 
                ind = j;
                break
            end
        end        
        
        if isInMatch
            particles(ind).pos(L,:) = mat2(i,:);
            particles(ind).match(L,1) = 1;
        else
            particles(end+1).pos(1:L-1,:) = nan(L-1,3);
            particles(end).match(1:L,1) = zeros(L,1);
            particles(end).pos(L,:) = mat2(i,:);
        end        
    end

end

partLength = length(particles); 

%Remove particles that appear less than appear_thresh
index = 1; 
for i = 1:partLength
    if sum(particles(index).match) <= appear_thresh
        particles(index) = [];
    else
        %fills missing particles with linear approx
        matches = find(particles(index).match(:,1));
        for j = 1:length(matches) - 1
            if matches(j) + 1 ~= matches(j+1)
                skips = matches(j+1) - matches(j);
                delpos = particles(index).pos(matches(j+1),1:3) - particles(index).pos(matches(j),1:3);  
                for k = matches(j)+1 : matches(j+1)-1
                    particles(index).pos(k,1:3) = particles(index).pos(matches(j),1:3) ...
                        + delpos*(k-matches(j))/skips;
                end
            end
        end
        index = index + 1;
    end
end



%Store particles as fn of time (to plot)
for L = 1:length(xyzLocCentroid)    
    index = 1;
    xyzLocOld(L).time = []; 
    for i = 1:length(particles)
        if ~isempty(particles(i).pos) &&~isnan(particles(i).pos(L,1))
            xyzLocOld(L).time(index,1:3) = round(particles(i).pos(L,1:3));
            xyzLocOld(L).time(index,3) = xyzLocOld(L).time(index,3)*ps;
            xyzLocOld(L).time(index,4) = i;
            index = index + 1;
        end
    end
end

    
toc