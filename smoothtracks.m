function [ xyzLocSmoothed, xyzLocTrackedMat, xyzLocSmoothedMat, numofparticles, FrameOfLastParticle ] = smoothtracks( xyzLocTracked, smoothparam )
%% smoothtracks - Smooth Tracked Particles:
%             Takes tracked particle data and smooths with a spline curve
%             smoothtracks takes a specifically formated struct of tracked particles
%             and uses a spline curve function to smooth the data.
%           
%             Daniel Shuldman <elias.ds@gmail.com>
%             Version 1.00
%
% Inputs:
%             xyzLocTracked     - Struct with 4 columns per cell.
%                                 X, Y, Z, Particle tracking number
%
% Optional Inputs:
%             smoothparam       - Spline Smoothing parameter between 0 and 1
%                                   Zero being a straight line.
%
% Outputs:
%             xyzLocSmoothed    - Smoothed output formatted just as the input
%             xyzLocTrackedMat  - optional output of the xyzLocTracked
%                                   input converted to 3D matrix form
%             xyzLocSmoothedMat - optional output of the smoothed data
%                                   converted to 3D matrix form
%
%


if length(smoothparam) == 1
    smoothparam(2:3) = smoothparam;
end

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

multiWaitbar('Smoothing Particle Motion...',0);
xyzLocSmoothedMat = xyzLocTrackedMat;
for L = 1:numofparticles
    for M = 1:3
        xyzLocSmoothedMat(:,M,L) = splinesmooth(xyzLocTrackedMat(:,4,L),xyzLocTrackedMat(:,M,L),smoothparam(M));
    end
    multiWaitbar('Smoothing Particle Motion...',L/numofparticles);
end

xyzLocSmoothed = xyzLocTracked;
for L = 1: length(xyzLocTracked)
    for M = 1:numofparticles
        partNum = find(xyzLocTracked(L).time(:,4) == M);
        if partNum > 0
            xyzLocSmoothed(L).time(partNum,1:3) = xyzLocSmoothedMat(L,1:3,M);
        end
    end
end

multiWaitbar( 'Smoothing Particle Motion...', 'Close' );
end

