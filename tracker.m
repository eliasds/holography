% Particle tracking by Dan Shuldman and Camille Jeannette Mei Biscarrat
% Version 2.1

% Struct array "particles" contains all the particles with field "pos" + "match" 
    % pos : x, y, z
    % match : 1/0
    
dist_thresh = 15E-6;   % diameter (in meters) in which to search for particle in next frame
appear_thresh = 8; % remove particles that apear for less than this number of frames
blink_keep = 5;     % number of frames to search for missing/blinking particle
smoothparam = [0.003 0.003 0.0005]; % Spline Smoothing parameter between 0 and 1; Zero being a straight line.

tic
scale = 15; %weights z axis less than x and y when looking for nearest neighbor
multiWaitbar('closeall');
clear xyzLocTracked
try
    %Just a list of particle locations? will get rescaled to xyzLocScaled
    xyzLocScaled = xyzLoc;
catch
    xyzLocScaled = xyzLocCentroid;
end

for i = 1:length(xyzLocScaled)
%     xyzLocScaled(i).time(:,1:3) = xyzLocScaled(i).time(:,1:3)/(scale);
    xyzLocScaled(i).time(:,3) = xyzLocScaled(i).time(:,3)/(scale);      %Scale 3rd column (z coord) why not x and y?
end

%Initialize struct array, with all particles in frame 1 + 2
%Structure array is an array of self made objects-- . creates a new field
particles = struct([]);
init = xyzLocScaled(1).time;        %Init is an array of tuples at first time t = 1: [(x, y, z)]
for i = 1:size(init,1)              %For each particle...
    particles(i).pos(1,:) = init(i,:);      %Add a particle to the particles array with position given by init(i, :) (which is the initial (x, y, z) coord of the particle)
    particles(i).match(1,1) = 0;
end

%Particles are rows in the xyzLocScaled(i).time matrix: To get particle 5's
%(x, y, z) coords at time 2, do xyzLocScaled(2).time(5, :)

%Now particles has one entry for each particle in the first frame with (x,
%y, z) coords in the position field and match as 0

%Go through each frame, tracking particles
multiWaitbar('Tracking Particles...',0);
for La = 2:length(xyzLocScaled)
    mat1 = xyzLocScaled(La-1).time;     %Previous list of particle locations
    mat2 = xyzLocScaled(La).time;       %Current list of particle locations
    [m,~] = size(mat1);     %Use ~ because mat1 will be m x 3 in size (Location is a 3 tuple)
    [n,~] = size(mat2);
    %m is # of particles in first frame and n is # of particles in second
    %not equal iff a particle drifted off the screen
    
    %Init k-d tree
    tree = const_tree(mat2, 1);
    
    %{
    %Creates distance matrix between every particle in frame L and L + 1
    dist_mat = nan(m,n);
%     multiWaitbar('Creating Distance Matrix Between Frames Adjacent Frames...',0);
    for M = 1:m
        for N = 1:n
            dist_mat(M,N) = sqrt((mat1(M,1)-mat2(N,1))^2 + ...      %The 1 gets the x coords
                (mat1(M,2)-mat2(N,2))^2 + (mat1(M,3)-mat2(N,3))^2);         %The 2 gets the y coords, 3 gets z
        end
%         multiWaitbar('Creating Distance Matrix Between Frames Adjacent Frames...',M/m);
    end
    
    %}
    
    %Thresholds + finds match
    % dist_mat_logic is an array with bool values
    dist_mat_logic = dist_mat < dist_thresh;
    
    %Copies particle positions for the next #(blink_keep) frames
    %(there is room here for speed improvements)
    multiWaitbar('Filling in data for blinking particles...',0);
    for j = 1:length(particles)
        repeat = 0;
        for i = 1:blink_keep
            particles(j).pos(La+i-1,:) = nan(1,3);
            particles(j).match(La+i-1,1) = 0;
            
            if La-i > 0 && particles(j).match(La-i,1) == 1
                repeat = 1;
            end
        end
        
        if repeat
            particles(j).match(La,1) = 0;
            particles(j).pos(La,:) = particles(j).pos(La-1,:);
        end
        multiWaitbar('Filling in data for blinking particles...',j/length(particles));
    end
    
    %What does this loop do? Creates a new distance matrix including blinking particles?
    partLength = length(particles);
    dist = zeros(n, partLength);
    keep = ones(partLength,1);
    multiWaitbar('Creating NEW Distance Matrix Between Adjacent Frames...',0);
    for j = 1:partLength
        for i = 1:n
            dist(i,j) = sqrt((particles(j).pos(La-1,1)-mat2(i,1))^2 + ...
                (particles(j).pos(La-1,2)-mat2(i,2))^2 + ...
                (particles(j).pos(La-1,3)-mat2(i,3))^2);
        end
        for k = 1:blink_keep
            if La-k > 0 && ~particles(j).match(La-k,1)
                keep(j,1) = keep(j,1) + 1;
            end
        end
        multiWaitbar('Creating NEW Distance Matrix Between Adjacent Frames...',j/partLength);
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
            
            if ~isempty(distIndex) && ~particles(j).match(La-1,1)
                for k = 1:length(distIndex)
                    if distIndex(k) == j
                        keepMatch = 1;
                    end
                end
            end
                
            %If match, record index of particle in particles
            if keepMatch || (~isempty(index) && isequal(mat1(index(minInd),:), particles(j).pos(La-1,:)))
                isInMatch = 1; 
                ind = j;
                break
            end
        end        
        
        if isInMatch
            particles(ind).pos(La,:) = mat2(i,:);
            particles(ind).match(La,1) = 1;
        else
            particles(end+1).pos(1:La-1,:) = nan(La-1,3);
            particles(end).match(1:La,1) = zeros(La,1);
            particles(end).pos(La,:) = mat2(i,:);
        end
%         multiWaitbar('Match Particles from Previous Frame...',i/n);
    end
    multiWaitbar('Tracking Particles...',La/length(xyzLocScaled));

end

partLength = length(particles); 

%Remove particles that appear less than appear_thresh
multiWaitbar('Removing Neglegible Particles and Correcting Data for Blinking Particles...',0);
index = 1; 
for i = 1:partLength
    if sum(particles(index).match) < appear_thresh
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
numofframes = length(xyzLocScaled);
multiWaitbar('Reformatting Particle Data...',0);
for La = 1:length(particles)
    particles(La).pos(:,3) = particles(La).pos(:,3)*scale;
end
for La = 1:numofframes
    index = 1;
    xyzLocTracked(La).time = [];
    for Lb = 1:length(particles)
        if ~isempty(particles(Lb).pos) && ~isnan(particles(Lb).pos(La,1))
            xyzLocTracked(La).time(index,1:3) = particles(Lb).pos(La,1:3);
            xyzLocTracked(La).time(index,4) = Lb;
            index = index + 1;
        end
    end
    multiWaitbar('Reformatting Particle Data...',La/numofframes);
end


%% Smooth Tracked Motion with a Spline Smoothing Function
[ xyzLocSmoothed, xyzLocTrackedMat, xyzLocSmoothedMat, numofparticles, FrameOfLastParticle ] = smoothtracks(xyzLocTracked, smoothparam);


%% Compute Velocity information and store in particles variable
particles = velocity(particles);


%% Save Work
multiWaitbar('closeall');

if ~exist('particlefilename','var')
    particlefilename = 'temp';
    warning('File name not specified. Saving to temp_Tracked.mat');
end
    
try
    save([OutputPathStr,particlefilename,'_Track_DT',num2str(dist_thresh*1E6),'AT',num2str(appear_thresh),'BK',num2str(blink_keep),'.mat'], 'xyzLocTracked', 'xyzLocSmoothed', 'particles', 'dist_thresh', 'appear_thresh', 'blink_keep'  )
catch
    save([particlefilename,'_Track_DT',num2str(dist_thresh*1E6),'AT',num2str(appear_thresh),'BK',num2str(blink_keep),'.mat'], 'xyzLocTracked', 'xyzLocSmoothed', 'particles', 'dist_thresh', 'appear_thresh', 'blink_keep' )
end

toc2

