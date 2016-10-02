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
for i = 1:size(init,1)              %For each particle...
    particles(i).pos(1,:) = init(i,:);      %Add a particle to the particles array with position given by init(i, :) (which is the initial (x, y, z) coord of the particle)
    particles(i).match(1,1) = 0;
end

%For init also need to buffer

%Particles are rows in the xyzLocScaled(i).time matrix: To get particle 5's
%(x, y, z) coords at time 2, do xyzLocScaled(2).time(5, :)

%Now particles has one entry for each particle in the first frame with (x,
%y, z) coords in the position field and match as 0

%Seems like mine is more dependent on z position than Dan's-- when I change
%the scale, it gets less accurate to his. I think that making the scale too
%big can actually mess his up though-- In xyzLoc(2).time, there are [.0003,
%.0006, .007] and [.0003, .0006, .0075]. Dan's tracks the [.0003, .0006,
%.007] to the [.0003, .0006, .0075] while mine tracks it to the [.0003,
%.0006, .007] which seems more correct. Try on scale = 100 for this result

%Go through each frame, tracking particles
multiWaitbar('Tracking Particles...',0);
for frame = 2:length(xyzLocScaled)
    cur_particles = xyzLocScaled(frame).time;       %Current list of particle locations
    [n,~] = size(cur_particles);
    
    %{
        TODO
        The problem is in the cases that the algorithm doesn't select the
        nearest neighbor-- more dependent on (x, y) than on z. Might screw
        up nearest neighbor search
        Should create some sort of a flag when they're used so that no
        particles are reused
        That will create a problem when the nearest neighbor blinks though
        Need to think this through and refine it
    %}
    
    %Set up particle matrix to turn into kd tree
    particle_mat = nan(length(particles), 4);       %3 space dims + 1 index dim
 %   multiWaitbar('Creating Particle Matrix...',0);
    for j = 1:length(particles)
        particle_mat(j, 4) = j;     %Store index
    end
    for i = 1:length(particles)
       positions = particles(i).pos;            %Particle positions
       %Add something for init
       last_pos = positions(frame - 1, :);
       if ~isempty(last_pos) %Particle exists at current time
           particle_mat(i, 1:3) = last_pos;
           particles(i).match = 1;
           continue             %Done with this particle
       else
           particles(i).match = 0;      %Might not even need this
       end
       %{
       %Now add blinking particles
       %Look back on each frame through blink_keep frames
       blinking = 0;
       for j = 1:blink_keep
           if frame - (j+1) > 0         %Make sure it stays within time's domain
               blink_pos = positions(frame - (j+1), :);
               if ~is_empty(blink_pos)
                   particle_mat(i, 1:3) = blink_pos;
                   blinking = 1;
                   break
               end
           end
       end
       %If you don't find it, set it to nan, nan, nan
       if ~blinking
           particle_mat(i, 1:3) = nan(1, 3);
       end
    %   particle_mat(i, 4) = i;
 %      multiWaitbar('Creating Particle Matrix...',i / length(particles));
       %}
    end
    pmat = strip_nans(particle_mat, 4);
    tree = const_tree(pmat, 1);     %Matrix of all particles in previous frame
    
    noMatch = nan(length(particles), 3);
    noMatchIndex = 1;
    multiWaitbar('Searching for Nearest Neighbors...',0);
    for i = 1:n         %For each particle in the current frame
        part = cur_particles(i, :);     %current particle
        [nn, index] = nearest_neighbor(tree, part, Data(nan), Data(realmax), Data(-1));
        dist = sqrt(sum(nn-part).^2);       %Cartesian metric
        %More dependent on (x, y), so only focus on x and y
    %    dist = sqrt((nn(1)-(part(1)))^2 + (nn(2)-part(2))^2);
        if dist < dist_thresh
            %This is good, then we add it to the matrix at index
            particles(index).pos(frame, :) = part;
            particles(index).match(frame, 1) = 1;
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
        multiWaitbar('Searching for Nearest Neighbors...',i / n);
    end
    noMatch = strip_nans(noMatch, 3);      %Get rid of nans
    notFound = struct([]);
    %DO BLINKING STUFF HERE
    for i = 1:length(particles)
        if particles(frame).match(i)
            continue;
        end
        for f = frame-blink_keep : frame-1
            if f <= 0
                continue;
            end
            if particles(f).match(i)
                
            end
        end
    end
    
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
    
    
    multiWaitbar('Tracking Particles...',frame/length(xyzLocScaled));
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

