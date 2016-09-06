function [ xyz ] = simulation( n, dt, frames, size )
%SIMULATION Simulates n particles moving in an environment
%   @param n number of particlees to simulate
%   @param dt time of each interval
%   @param frames total number of frames to take
%   @param size size of the environment to create
%   @return xyz struct with xyz locations. xyz(i).time gets array n x
%       3 array of particles moving in the environment

xyz = struct([]);

%Create x, v, a (maybe not a) -- nx1 vectors

%%% INIT V %%%
%Scale for velocity should be ~1e-5. Generate from 5e-6 to 5e-5
vMin = 5e-6;
vMax = 5e-5;
dv = vMax - vMin;
v = nan(n, 2);        %First comp is mag, 2nd is theta from 0 deg
for i = 1:n
    v(i, 1) = vMin + rand*dv;      %normal dist.
    v(i, 2) = rand*360        %TODO or 2pi in rads
    %TODO when calculating, add small oscillating time dependence
end

%%% INIT X %%%


for frame = 1:frames
    xyz(frame).time = nan(n, 3);        %Store info about the particles
    
end




end

