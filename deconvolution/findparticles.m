%% Find Deconvolved Particle Locations
J2pos = Jpos{2};
J2real = Jreal{2};

figure(98);
hist(J2pos(:),1000);title('POS');
figure(99);
hist(J2real(:),1000);title('REAL');


threshPOS = 1.07;
threshREAL = 1.15;

matPOS = J2pos > threshPOS; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');
matREAL = J2real > threshREAL; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');

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
dx = 5.5e-6/4;
dy = 5.5e-6/4;
dz = 24E-6;
for L = 1:5
errorXpos(L) = dx*abs(xyzFoundPOS(L,1) - xyzTrue(L,1));
errorYpos(L) = dy*abs(xyzFoundPOS(L,2) - xyzTrue(L,2));
errorZpos(L) = dz*abs(xyzFoundPOS(L,3) - xyzTrue(L,3));
end
errorTOTpos = sqrt(errorXpos.^2 + errorYpos.^2 + errorZpos.^2);
for L = 1:5
errorXreal(L) = dx*abs(xyzFoundREAL(L,1) - xyzTrue(L,1));
errorYreal(L) = dy*abs(xyzFoundREAL(L,2) - xyzTrue(L,2));
errorZreal(L) = dz*abs(xyzFoundREAL(L,3) - xyzTrue(L,3));
end
errorTOTreal = sqrt(errorXreal.^2 + errorYreal.^2 + errorZreal.^2);


figure(98)
bar([errorXpos'*1e6,errorYpos'*1e6,errorZpos'*1e6])
title('Deviation in Deconvolved Position; X/Y/Z POS')
xlabel('Particle Number')
ylabel('Deviation in X/Y/Z-Direction Only (um)')
colormap jet
legend('X','Y','Z')
axis([0.5,5.5,0,30])

figure(99)
bar([errorXpos'*1e6,errorYpos'*1e6,errorZpos'*1e6])
title('Deviation in Deconvolved Position; X/Y/Z REAL')
xlabel('Particle Number')
ylabel('Deviation in X/Y/Z-Direction Only (um)')
colormap jet
legend('X','Y','Z')
axis([0.5,5.5,0,30])


figure(99)
bar(errorTOTpos*1e6)


imagesc(Holo); colormap gray; colorbar; axis image; axis ij;
title('Hologram POS')
xlabel('700um')
ylabel('700um')
axis ij