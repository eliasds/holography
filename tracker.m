% Particle tracking by Dan Shuldman and Patrick Oare
% Version 2.2

% Struct array "particles" contains all the particles with field "pos" + "match" 
    % pos : x, y, z
    % match : 1/0
    
dist_thresh = 15E-6;   %TODO work with this; diameter (in meters) in which to search for particle in next frame
appear_thresh = 8; % remove particles that apear for less than this number of frames
blink_keep = 10;     % number of frames to search for missing/blinking particle
smoothparam = [0.003 0.003 0.0005]; % Spline Smoothing parameter between 0 and 1; Zero being a straight line.

tic
scale = 15; %15, weights z axis less than x and y when looking for nearest neighbor
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
particles = struct([]);
init = xyzLocScaled(1).time;        %Init is an array of tuples at first time t = 1: [(x, y, z)]
initIndex = 1;
partIndex = 1;
while initIndex <= size(init, 1)
    p = init(initIndex, :);
    initIndex = initIndex + 1;
    if isnan(p)
        continue;
    end
    particles(partIndex).pos(1, :) = p;
    particles(partIndex).match(1, 1) = 0;   %Set it to 0 so that we can set it to 1 if we find it
    partIndex = partIndex + 1;
end


notFound = struct([]);
%Will have fields pos (of [x, y, z]), frame (frame lost in), and index (in particles)
multiWaitbar('Tracking Particles...',0);
numFrames = length(xyzLocScaled);
for frame = 2:numFrames
    cur_particles = xyzLocScaled(frame).time;       %Current list of particle locations
    [n, ~] = size(cur_particles);
    
    %Set up particle matrix to turn into kd tree
    particle_mat = nan(length(particles), 4);       %3 space dims + 1 index dim
 %   multiWaitbar('Creating Particle Matrix...',0);
    for j = 1:length(particles)
        particle_mat(j, 4) = j;     %Store index
    end
    for i = 1:length(particles)
       positions = particles(i).pos;            %Particle positions
       last_pos = positions(frame - 1, :);
       particles(i).pos(frame, :) = nan(1, 3);
       particles(i).match(frame - 1, 1) = 0;
       if ~isnan(last_pos)
           particle_mat(i, 1:3) = last_pos;
       end
    end
    pmat = strip_nans(particle_mat, 4);
    
    tree = const_tree(pmat, 1);     %Matrix of all particles in previous frame
    
    noMatch = nan(length(particles), 3);
    noMatchIndex = 1;
    
%    multiWaitbar('Searching for Nearest Neighbors...',0);
    for i = 1:n         %For each particle in the current frame
        part = cur_particles(i, :);     %current particle
        if isnan(part)
            continue;
        end
        [nn, index] = nearest_neighbor(tree, part, Data(nan), Data(realmax), Data(-1));
%        node = nearest_neighbor(tree, part);
%        nn = node.val;
%        index = node.index;
        dist = sqrt(sum((nn-part).^2));
        if dist < dist_thresh
            %This is good, then we add it to the matrix at index
            particles(index).pos(frame, :) = part;
            particles(index).match(frame-1, 1) = 1;
        else
            %Didn't find the nearest particle, so check for blinking
            noMatch(noMatchIndex, :) = part;
            noMatchIndex = noMatchIndex + 1;
        end
%        multiWaitbar('Searching for Nearest Neighbors...',i / n);
    end
    
    %BEGIN BLINKING
    noMatch = strip_nans(noMatch, 3);
    for i = 1:length(particles)
        if isnan(particles(i).pos(frame - 1, :)) | particles(i).match(frame-1, 1)        %Then particles have a match
            continue;
        end
        notFound(end + 1).pos = particles(i).pos(frame - 1, :);
        notFound(end).frame = frame - 1;
        notFound(end).index = i;
    end
    
    if isempty(notFound) 
        continue;
    end
    points = nan(size(notFound, 2), 4);
    k = 1;
    while k <= size(notFound, 2)
        if frame - notFound(k).frame > blink_keep
            notFound(k) = [];
        else
            points(k, 1:3) = notFound(k).pos;
            points(k, 4) = k;       %Store notFound index
            k = k + 1;
        end
    end
    
    %{
    Guard against bug-- points became empty, but didn't continue. 
    Think what happened is that there were one or two particles in notFound
    and they were all greater than blink_keep away, so it removed them 
    from the matrix and points was null. This made the kdTree null, which
    will return a value of -1 for all operations, hence why the indexing 
    was throwing an error.
    %}
    if isnan(points)
        continue;
    end
    
    nfTree = const_tree(points, 1);
    toDel = nan(1, length(notFound));
    toDelIndex = 1;
    %Iterate through noMatch and find nearest neighbor
    for i = 1:size(noMatch, 1)
        part = noMatch(i, :);
        [nn, index] = nearest_neighbor(nfTree, part, Data(nan), Data(realmax), Data(-1));
        
%        node = nearest_neighbor(nfTree, part);
%        nn = node.val;
%        index = node.index;
        
        d = sqrt(sum((nn-part).^2));
        k = frame - notFound(index).frame;       %Number of frames back
        new_thresh = k*dist_thresh;
        if d < new_thresh
            %pIndex = notFound(index).frame;
            pIndex = notFound(index).index;
            particles(pIndex).pos(frame, :) = part;%nn(1, 1:3);       %TODO change to part
            %TODO ADD particles(notFound(index).index:pIndex-1, :) = interpolate(particles(pIndex).pos(frame, :), particles(pIndex).pos(notFound(index).frame, :), frame - notFound(index).frame);
            %particles(pIndex).match(frame, 1) = 1;
            
            %TODO PROBLEM: Since notFound(index) is deleted, all the
            %indices are off by one. Hopefully this fixes it
            %notFound(index) = [];
            toDel(1, toDelIndex) = index;
            toDelIndex = toDelIndex + 1;
            %TODO delete particle from k-d tree. Implement remove
            %{
                Problem is that two of the particles in noMatch are very 
                close to one another, and they find the same particle in
                notFound. After I delete the particle from notFound, it 
                tries to again delete the same index, which causes an
                index out of bounds error
            %}
        else
            %add particle to particles
            particles(end + 1).pos(frame, :) = part;
            particles(end).pos(1:frame - 1, :) = nan(frame - 1, 3);
            particles(end).match(1:frame - 1, :) = zeros(frame - 1, 1);
        end
    end
    
    %sort toDelIndex from largest to smallest and delete from nfIndex
    sortedDel = reverseSort(toDel);
    for i = 1:length(sortedDel)
        notFound(sortedDel(i)) = [];
    end
    
    %END BLINKING
    multiWaitbar('Tracking Particles...',frame/numFrames);
end

%Remove particles that appear less than appear_thresh
multiWaitbar('Removing Neglegible Particles and Correcting Data for Blinking Particles...',0);
index = 1;
partLength = length(particles);
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
for frame = 1:length(particles)
    particles(frame).pos(:,3) = particles(frame).pos(:,3)*scale;
end
for frame = 1:numofframes
    index = 1;
    xyzLocTracked(frame).time = [];
    for Lb = 1:length(particles)
        if ~isempty(particles(Lb).pos) && ~isnan(particles(Lb).pos(frame,1))
            xyzLocTracked(frame).time(index,1:3) = particles(Lb).pos(frame,1:3);
            xyzLocTracked(frame).time(index,4) = Lb;
            index = index + 1;
        end
    end
    multiWaitbar('Reformatting Particle Data...',frame/numofframes);
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

