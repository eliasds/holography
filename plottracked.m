% function [ output_args ] = plottracked( input_args )
%plottracked.m: Simple code to plot the trajectory of tracked particles
%   Detailed explanation goes here

xyzLocInput = xyzLocSmoothed; % change to struct with your data
az = 10; el = 5; % Rotate plot to these Azimuth and Elevation angles


fignum = 333; % Figure number to use
xscale = 1000; % convert axis to mm
yscale = 1000; % convert axis to mm
zscale = 1000; % convert axis to mm
tscale = 1; % change to 1000 to convert time to ms
numofpixels = 1024;
fps = 20; dt = tscale/fps; %Frames per second. dt is time between frames in ms


xmax = numofpixels*ps/mag; % max x value in data to plot
ymax = numofpixels*ps/mag; % max y value in data to plot
zmax = abs(z2-z1); % max distance in z propagation
zmin = min(z1,z2);
figure(fignum);
for La = 1:numel(xyzLocInput)
%     scatter3(xscale*xyzLocInput(La).time(:,1),zscale*(-z2+xyzLocInput(La).time(:,3)),yscale*(ymax-xyzLocInput(La).time(:,2)),30,'filled','b'); %Blue Particles
    scatter3(xscale*xyzLocInput(La).time(:,1),zscale*(-zmin+xyzLocInput(La).time(:,3)),yscale*(ymax-xyzLocInput(La).time(:,2)),30,'filled','CData',xyzLocInput(La).time(:,4)); colormap(jet(125)); %Multicolored Particles
    view([az,el])
    axis equal
    axis([0,ceil(4*xscale*xmax)/4,0,floor(2*zscale*zmax)/2,0,ceil(4*yscale*ymax)/4]); %Round axis value
    xlabel('(mm)')
    zlabel('(mm)')
    ylabel('(mm)')
    title(['3D Tracked Particles       ',num2str((La-1)*dt,'%.2f'),'s']);
    grid on
    grid minor
    box on
    drawnow
end




