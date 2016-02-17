% Particle tracking by Dan Shuldman and Camille Jeannette Mei Biscarrat
% Version 2.1

% Struct array "particles" contains all the particles with field "pos" + "match" 
    % pos : x, y, z
    % match : 1/0
    
dist_thresh = 15;   % diameter (in pixels) in which to search for particle in next frame
appear_thresh = 10; % remove particles that apear for less than this number of frames
blink_keep = 5;     % number of frames to search for missing/blinking particle

tic
xyzLocCentroidScaled = xyzLocCentroid;
for i = 1:length(xyzLocCentroidScaled)
    xyzLocCentroidScaled(i).time(:,3) = xyzLocCentroidScaled(i).time(:,3)/(ps);
end

%Initialize struct array, with all particles in frame 1 + 2
particles = struct([]);
init = xyzLocCentroidScaled(1).time;  
for i = 1:size(init,1)
    particles(i).pos(1,:) = init(i,:);
    particles(i).match(1,1) = 0;
end

%Go through each frame, tracking particles
multiWaitbar('A: Tracking Particles...',0);
for L = 2:length(xyzLocCentroidScaled)
    mat1 = xyzLocCentroidScaled(L-1).time;
    mat2 = xyzLocCentroidScaled(L).time;
    [m,~] = size(mat1);
    [n,~] = size(mat2);
    
    %Creates distance matrix between every particle in frame L and L + 1
    dist_mat = nan(m,n);
%     multiWaitbar('Creating Distance Matrix Between Frames Adjacent Frames...',0);
    for M = 1:m
        for N = 1:n
            dist_mat(M,N) = sqrt((mat1(M,1)-mat2(N,1))^2 + ...
                (mat1(M,2)-mat2(N,2))^2 + (mat1(M,3)-mat2(N,3))^2);
        end
%         multiWaitbar('Creating Distance Matrix Between Frames Adjacent Frames...',M/m);
    end
    
    %Thresholds + finds match
    dist_mat_logic = dist_mat < dist_thresh;
    
    %Copies particle positions for the next #(blink_keep) frames
    %(there is room here for speed improvements)
    multiWaitbar('B: Filling in data for blinking particles...',0);
    for j = 1:length(particles)
        repeat = 0;
        for i = 1:blink_keep
            particles(j).pos(L+i-1,:) = nan(1,3);
            particles(j).match(L+i-1,1) = 0;
            
%             if L-i > 0 && particles(j).match(L-i,1) == 1
            if L-i > 0 && repeat == 0 && particles(j).match(L-i,1) == 1
                repeat = 1;
            end
        end
        
        if repeat
            particles(j).match(L,1) = 0;
            particles(j).pos(L,:) = particles(j).pos(L-1,:);
        end
        multiWaitbar('B: Filling in data for blinking particles...',j/length(particles));
    end
    
    %What does this loop do? Creates a new distance matrix including blinking particles?
    partLength = length(particles);
    deletetempval(L) = partLength; %does this value change?
    dist = zeros(n, partLength);
    keep = ones(partLength,1);
    multiWaitbar('C: Creating NEW Distance Matrix Between Adjacent Frames...',0);
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
        multiWaitbar('C: Creating NEW Distance Matrix Between Adjacent Frames...',j/partLength);
    end
            
    
    %Append matches in L+1 to corresponding particles or adds them as new particles
    partLength = length(particles);
%     multiWaitbar('Match Particles from Previous Frame...',0);
    for i = 1:n
        isInMatch = 0;  
        index = find(dist_mat_logic(:,i));
        min_z = abs(mat2(i,3) - mat1(index,3));
        [~,minInd] = min(min_z);
        
        dist_logic = dist(i,:)' < keep*dist_thresh;
        distIndex = find(dist_logic);
        keepMatch = 0;
        for j = 1:partLength
            
%Switch && below?
            if ~isempty(distIndex) && ~particles(j).match(L-1,1)
                for k = 1:length(distIndex)
                    if distIndex(k) == j
                        keepMatch = 1;
                    end
                end
            end
                
%Switch && below?
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
%         multiWaitbar('Match Particles from Previous Frame...',i/n);
    end
    multiWaitbar('A: Tracking Particles...',L/length(xyzLocCentroidScaled));

end

partLength = length(particles); 

%Remove particles that appear less than appear_thresh
multiWaitbar('Removing Neglegible Particles and Correcting Data for Blinking Particles...',0);
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
    multiWaitbar('Removing Neglegible Particles and Correcting Data for Blinking Particles...',i/partLength);
end



%Store particles as fn of time (to plot)
numofframes = length(xyzLocCentroidScaled);
multiWaitbar('Reformatting Particle Data...',0);
for L = 1:numofframes
    index = 1;
    xyzLocTracked(L).time = []; 
    for i = 1:length(particles)
        if ~isempty(particles(i).pos) && ~isnan(particles(i).pos(L,1))
            xyzLocTracked(L).time(index,1:3) = round(particles(i).pos(L,1:3));
            xyzLocTracked(L).time(index,3) = xyzLocTracked(L).time(index,3)*ps;
            xyzLocTracked(L).time(index,4) = i;
            index = index + 1;
        end
    end
    multiWaitbar('Reformatting Particle Data...',L/numofframes);
end

multiWaitbar('closeall');

if ~exist('particlefilename','var')
    particlefilename = 'temp';
    warning('File name not specified. Saving to temp_Tracked.mat');
end
    
save([particlefilename,'_Tracked.mat'], 'xyzLocTracked')

toc
