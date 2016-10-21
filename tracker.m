% Particle tracking by Dan Shuldman and Camille Jeannette Mei Biscarrat
% Version 2.1

% Struct array "particles" contains all the particles with field "pos" + "match" 
    % pos : x, y, z
    % match : 1/0
    
dist_thresh = 15E-6;   %TODO work with this; diameter (in meters) in which to search for particle in next frame
appear_thresh = 8; % remove particles that apear for less than this number of frames
blink_keep = 5;     % number of frames to search for missing/blinking particle
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
%{
for i = 1:size(init,1)              %For each particle...
    p = init(i, :);
    if isnan(p)
        continue;
    end
    particles(i).pos(1,:) = p;      %Add a particle to the particles array with position given by init(i, :) (which is the initial (x, y, z) coord of the particle)
    particles(i).match(1,1) = 0;
end
%}
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

%{
For init also need to buffer

Particles are rows in the xyzLocScaled(i).time matrix: To get particle 5's
(x, y, z) coords at time 2, do xyzLocScaled(2).time(5, :)

Now particles has one entry for each particle in the first frame with (x,
y, z) coords in the position field and match as 0

Seems like mine is more dependent on z position than Dan's-- when I change
the scale, it gets less accurate to his. I think that making the scale too
big can actually mess his up though-- In xyzLoc(2).time, there are [.0003,
.0006, .007] and [.0003, .0006, .0075]. Dan's tracks the [.0003, .0006,
.007] to the [.0003, .0006, .0075] while mine tracks it to the [.0003,
.0006, .007] which seems more correct. Try on scale = 100 for this result

Go through each frame, tracking particles
multiWaitbar('Tracking Particles...',0);

%}
notFound = struct([]);
%Will have fields pos (of [x, y, z]), frame (frame lost in), and index (in particles)

for frame = 2:length(xyzLocScaled)
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
       %TODO CHECK THIS IS A GOOD PADDING OF PARTICLES
       particles(i).pos(frame, :) = nan(1, 3);
       particles(i).match(frame-1, 1) = 0;
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
        dist = sqrt(sum((nn-part).^2));
        if dist < dist_thresh
            %This is good, then we add it to the matrix at index
            particles(index).pos(frame, :) = part;
            particles(index).match(frame-1, 1) = 1;
        else
            %Didn't find the nearest particle, so check for blinking
            noMatch(noMatchIndex, :) = part;
            noMatchIndex = noMatchIndex + 1;
            %{
            %New particle, so we add it to the matrix
            particles(end+1).pos(1:frame-1,:) = nan(frame-1,3);     %Add particle
            particles(end).match(1:frame,1) = zeros(frame,1);
            particles(end).pos(frame,:) = part;
            %}
        end
%        multiWaitbar('Searching for Nearest Neighbors...',i / n);
    end
    
    %{
    match tells if a tuple in the particles struct has already been paired.
    If it has, then we don't want to use it for finding blinking particles
    because we've already found it and it would waste time and space
    %}
    %BEGIN BLINKING
    noMatch = strip_nans(noMatch, 3);      %Get rid of nans
%    notFound = struct([]);
%    nfIndex = 1;
    for i = 1:length(particles)
        if isnan(particles(i).pos(frame - 1, :)) | particles(i).match(frame-1, 1)        %Then particles have a match
            continue;
        end
        %if ~particles(i).match(frame - 1)
        notFound(end + 1).pos = particles(i).pos(frame - 1, :);
        notFound(end).frame = frame - 1;
        notFound(end).index = i;
        %end
        %Old blinking
        %{
        if frame - blink_keep < 1
            minFrame = 1;
        else
            minFrame = frame - blink_keep;
        end
        f = frame - 1;
        %TODO start at minFrame and go up to f-1
        while f >= minFrame
            %if ~particles(i).match(f, 1) && ~isnan(particles(i).pos(f, 1))
            %Why this if statement? Shouldn't it be a tautology?
            if ~particles(i).match(f, 1)        %Get particle if it hasn't been matched yet
                %Then we want f+1... or do we want f?
                %notFound(nfIndex).pos = [particles(f).pos, nfIndex];     %f or f+1
                notFound(nfIndex).pos = [particles(i).pos(f, :), nfIndex];
                notFound(nfIndex).frame = f;    %f or f+1
                notFound(nfIndex).part_number = i;
                nfIndex = nfIndex + 1;
                break;
            end
            f = f - 1;
        end
        %}
    end
    
    if isempty(notFound) 
        continue;
    end
    %notFound.pos returns 3 different vectors-- have to convert to an array
    %points = structToArray(notFound.pos);
    points = nan(size(notFound, 2), 4);
    %{
    for k = 1:size(notFound, 2)
        points(k, :) = notFound(k).pos;
    end
    %}
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
    
    nfTree = const_tree(points, 1);
    toDel = nan(1, length(notFound));
    toDelIndex = 1;
    %Iterate through noMatch and find nearest neighbor
    for i = 1:size(noMatch, 1)
        %noMatch(i, :) is the 3-tuple with (x, y, z)
        part = noMatch(i, :);
        [nn, index] = nearest_neighbor(nfTree, part, Data(nan), Data(realmax), Data(-1));
        d = sqrt(sum((nn-part).^2));
        k = frame - notFound(index).frame;       %Number of frames back
        new_thresh = k*dist_thresh;
        if d < new_thresh
            %pIndex = notFound(index).frame;
            pIndex = notFound(index).index;
            particles(pIndex).pos(frame, :) = nn(1, 1:3);
            %TODO ADD particles(notFound(index).index:pIndex-1, :) = interpolate(particles(pIndex).pos(frame, :), particles(pIndex).pos(notFound(index).frame, :), frame - notFound(index).frame);
            %particles(pIndex).match(frame, 1) = 1;
            
            %TODO PROBLEM: Since notFound(index) is deleted, all the
            %indices are off by one. Hopefully this fixes it
            %notFound(index) = [];
            toDel(1, toDelIndex) = index;
            toDelIndex = toDelIndex + 1;
        else
            %add particle to particles
            particles(end + 1).pos(frame, :) = part;
            particles(end).pos(1:frame - 1, :) = nan(frame - 1, 3);
            particles(end).match(1:frame - 1, :) = zeros(frame - 1, 1);
            %particles(end).match(1:frame-1,1) = zeros(frame-1,1);       %Or ones?
            %particles(end).match(frame, 1) = 1;
        end
    end
    
    %sort toDelIndex from largest to smallest and delete from nfIndex
    sortedDel = reverseSort(toDel);
    for i = 1:length(sortedDel)
        notFound(sortedDel(i)) = [];
    end
    
    %END BLINKING
    %{
    for i = 1:size(particles, 2)        %Now see if the particle vanished-- if it did we want nans
        if size(particles(i).pos, 1) < frame
            %Fill it with nans
            particles(i).pos = [particles(i).pos ; nan, nan, nan];
        end
    end
    
    %Now go through and pad the fields for deleted particles
    for i = i:length(particles)
       if size(particles(i).pos, 1) < (frame - 1)
           particles(i).pos()
       end
    end
    %}
    
    
%    multiWaitbar('Tracking Particles...',frame/length(xyzLocScaled));
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

