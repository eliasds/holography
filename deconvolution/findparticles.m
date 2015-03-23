%% Find Deconvolved Particle Locations
J2pos = Jpos{2};
J2real = Jreal{2};


thresh = 1.2;

matPOS = J2pos > thresh; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');
matREAL = J2real > thresh; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');

% if exist('Holo','var')
for L = 1:length(xyzlocationsPOS)
xyzlocationsPOS(L,4) = J2pos(xyzlocationsPOS(L,2),xyzlocationsPOS(L,1),xyzlocationsPOS(L,3));
end
% end
% if exist('Holo','var')
for L = 1:length(xyzlocationsREAL)
xyzlocationsREAL(L,4) = J2real(xyzlocationsREAL(L,2),xyzlocationsREAL(L,1),xyzlocationsREAL(L,3));
end
% end


% x_obj = x_obj+256
% y_obj = y_obj+256
xyzFoundPOS = zeros(5,4)
xyzFoundREAL = zeros(5,4)
% Manually edit these records from correct xyzlocationsPOS and xyzlocationsREAL

% xyzTrue = zeros(5,4)
dz = 24E-6;
for L = 1:5
errorXpos(L) = dz*abs(xyzFoundPOS(L,1) - xyzTrue(L,1));
errorYpos(L) = dz*abs(xyzFoundPOS(L,2) - xyzTrue(L,2));
errorZpos(L) = dz*abs(xyzFoundPOS(L,3) - xyzTrue(L,3));
end
errorTOTpos = sqrt(errorXpos.^2 + errorYpos.^2 + errorZpos.^2);
for L = 1:5
errorXreal(L) = dz*abs(xyzFoundREAL(L,1) - xyzTrue(L,1));
errorYreal(L) = dz*abs(xyzFoundREAL(L,2) - xyzTrue(L,2));
errorZreal(L) = dz*abs(xyzFoundREAL(L,3) - xyzTrue(L,3));
end
errorTOTreal = sqrt(errorXreal.^2 + errorYreal.^2 + errorZreal.^2);


dx = 5.5e-6/4;
dy = 5.5e-6/4;


% plot(errorTOTpos)
% axis([0,5,0,1e-6])
% plot(errorTOTpos)
% Title('Simulation Errors')
% title('Simulation Errors')
% xlabel('Particle Number')
% ylabel('Absolute Error (Meters)')
% Title('Simulation Errors')figure
% figure
% plot(errorTOTpos*1e3)
% title('Simulation Errors')
% xlabel('Particle Number')
% ylabel('Absolute Error (Meters)')
% ylabel('Absolute Error (mm)')
% plot(errorYpos*1e3)
% title('Simulation Errors')
% xlabel('Particle Number')
% ylabel('Absolute Error (mm)')
% plot(errorYpos)
% plot(errorYpos*1e1)
% plot(errorYpos*0.00002)
% plot(errorYpos*1e3)
% xlabel('Particle Number')
% title('Simulation Errors')
% ylabel('Absolute Error (mm)')
% plot(errorYpos*1e6)
% xlabel('Particle Number')
% title('Simulation Errors')
% ylabel('Absolute Error (mm)')
% ylabel('Absolute Error (um)')
% title('Simulation X,Y Errors')
% bar(errorYpos*1e6)
% bar(errorYpos)
% bar(errorYpos*1e6)
% xlabel('Particle Number')
% title('Simulation Errors')
% ylabel('Absolute Error (um)')
% title('Simulation Errors in X&Y')
% bar(errorTOTpos*1e6)
% title('Deviation in Deconvolved Position')
% xlabel('Particle Number')
% ylabel('Absolute Error (um)')
% bar(errorYpos*1e6)
% title('Deviation in Deconvolved Position; X/Y')
% xlabel('Particle Number')
% ylabel('Deviation in Y-Direction Only (um)')
% imagesc(Holo); colormap gray; colorbar; axis image; axis ij;
% title('Hologram')
% ylabel('700um')
% xlabel('700um')

figure(98)
bar(errorXpos*1e6)
title('Deviation in Deconvolved Position; X/Y POS')
xlabel('Particle Number')
ylabel('Deviation in X-Direction Only (um)')
colormap jet
axis([0.5,5.5,0,100])
figure(99)
bar(errorXreal*1e6)
title('Deviation in Deconvolved Position; X/Y REAL')
xlabel('Particle Number')
ylabel('Deviation in X-Direction Only (um)')
colormap jet
axis([0.5,5.5,0,100])

figure(98)
bar(errorYpos*1e6)
title('Deviation in Deconvolved Position; X/Y POS')
xlabel('Particle Number')
ylabel('Deviation in Y-Direction Only (um)')
colormap jet
axis([0.5,5.5,0,100])
figure(99)
bar(errorYreal*1e6)
title('Deviation in Deconvolved Position; X/Y REAL')
xlabel('Particle Number')
ylabel('Deviation in Y-Direction Only (um)')
colormap jet
axis([0.5,5.5,0,100])

figure(98)
bar(errorZpos*1e6)

figure(99)
bar(errorTOTpos*1e6)


imagesc(Holo); colormap gray; colorbar; axis image; axis ij;
title('Hologram POS')
xlabel('700um')
ylabel('700um')
axis ij