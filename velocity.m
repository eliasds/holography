function [ particles ] = velocity( particles, delta_Time )
%velocity.m  Takes particle positions and outputs velocity
%   Takes particle positions and outputs velocity if delta-Time is known,
%   otherwise outputs change in position (delta-Time=1)


if nargin == 1
    delta_Time = 1; %units of seconds assumed
end

numofparticles = numel(particles);
[particles(1:numofparticles).xyz] = deal(particles.pos);

for La = 1:numofparticles
    particles(La).xyz(isnan(particles(La).xyz(:,1)),:)=[];
    particles(La).Dxyz = diff(particles(La).xyz,1);
    particles(La).AbsD = sqrt(sum(particles(La).Dxyz.^2,2));
    particles(La).AbsV = particles(La).AbsD/delta_Time;
    particles(La).MeanAbsD = mean(particles(La).AbsD);
    particles(La).MeanAbsV = mean(particles(La).AbsV);
    particles(La).MeanDxyz = mean(particles(La).Dxyz,1);
    particles(La).MeanVxyz = sqrt(sum(particles(La).MeanDxyz.^2))/delta_Time;
    for Lb = 1:3
        particles(La).SmoothedDxyz(:,Lb) = smooth(particles(La).Dxyz(:,Lb),5);
        particles(La).Smoothedxyz(:,Lb) = smooth(particles(La).xyz(:,Lb),3);
        particles(La).rmsDxyz(:,Lb) = rms(particles(La).Dxyz(:,Lb)-particles(La).MeanDxyz(:,Lb));
        particles(La).rmsxyz(:,Lb) = rms(particles(La).xyz(:,Lb)-particles(La).Smoothedxyz(:,Lb));
    end
end


end

