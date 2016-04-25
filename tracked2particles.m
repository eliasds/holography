function [ particles ] = tracked2particles( xyzLocTracked )
%tracked2particles.m: Takes Structure of all tracked particles in each
%frame and converts into a struct of Particle positions per particle
%
%   Detailed explanation goes here

numofparticles = 0;
FrameOfLastParticle = 0;
partNum = 0;
for L = 1: length(xyzLocTracked)
    if max(xyzLocTracked(L).time(:,4)) >= numofparticles;
        FrameOfLastParticle = L;
        numofparticles = max(max(xyzLocTracked(L).time(:,4)),numofparticles);
    end
end


tracklength = length(xyzLocTracked);
xyzLocTrackedMat = NaN(tracklength,4,numofparticles);
for L = 1:tracklength
    for M = 1:numofparticles
        partNum = find(xyzLocTracked(L).time(:,4) == M);
        if partNum > 0
            xyzLocTrackedMat(L,1:3,M) = xyzLocTracked(L).time(partNum,1:3);
        else
            xyzLocTrackedMat(L,1:3,M) = NaN;
        end
        xyzLocTrackedMat(L,4,M) = L;
    end
end


% particles(1:numofparticles).pos=[];
particles(1:numofparticles) = struct('pos',[]);
for La = 1:numofparticles
    particles(La).pos = squeeze(xyzLocTrackedMat(:,1:3,La));
end

end

