function [ xyz ] = simulation( n, dt, frames )
%SIMULATION Simulates n particles moving in an environment
%   @param n number of particlees to simulate
%   @param dt time of each interval, ~.01
%   @param frames total number of frames to take, ~60
%   @param size size of the environment to create, ~ .001
%   @return xyz struct with xyz locations. xyz(i).time gets array n x
%       3 array of particles moving in the environment

size = .001;

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
    %Add in permutation of the x matrix
    permute = randperm(n);
    xyz(frame).time = x(permute, :);
    
    %TODO take away particles to simulate blinking
    
    
    %update x and v
    x = x + v *dt;                      %Move particle
    v = v + v * .02*sin(frame*rand);           %Modify v slightly each time
    %Make sure don't change by too much or it might lose the particle
end

end

