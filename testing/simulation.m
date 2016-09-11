function [ xyz ] = simulation( n, dt, frames, size )
%SIMULATION Simulates n particles moving in an environment
%   @param n number of particlees to simulate
%   @param dt time of each interval
%   @param frames total number of frames to take
%   @param size size of the environment to create, try .001
%   @return xyz struct with xyz locations. xyz(i).time gets array n x
%       3 array of particles moving in the environment

xyz = struct([]);

%Create x, v, a (maybe not a) -- nx1 vectors

%%% INIT X AND V %%%
%Scale for velocity should be ~1e-5. Generate from 5e-6 to 5e-5
vMin = 5e-6;
vMax = 5e-5;
dv = vMax - vMin;
v = nan(n, 3);          %[vx, vy, vz]

xMin = -size;
xMax = size;
dx = xMax - xMin;
x = nan(n, 3);
for i = 1:n
    for j = 1:3
        x(i, j) = xMin + rand*dx;
        v(i, j) = vMin + rand*dv;       %x, y, z components
    end
    %TODO when calculating, add small oscillating time dependence
end

for frame = 1:frames
  %  xyz(frame).time = nan(n, 3);        %Store info about the particles
    xyz(frame).time = x;
    %Now, reset x by v
    x = x + v *dt;
%    v = v .* 2*sin(frame);
end


end

