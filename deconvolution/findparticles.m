%% Find Deconvolved Particle Locations
J2 = J{2};
J2pos = Jpos{2};
J2real = Jreal{2};

figure(97);
hist(J2(:),1000);title('Norm');axis([0,max(J2(:)),0,100])
figure(98);
hist(J2pos(:),1000);title('POS');axis([0,1.6,0,100])
figure(99);
hist(J2real(:),1000);title('REAL');axis([0,1.6,0,100])

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
thresh = 11;

matPOS = J2pos > thresh; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');
% matREAL = J2real > thresh; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');
=======
thresh = 2.4;
mat = J2 > thresh; [ xyzlocations ] = findxyz( mat ); figure(97); plot3(xyzlocations(:,1),xyzlocations(:,2),xyzlocations(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('Norm');

for L = 1:length(xyzlocations)
xyzlocations(L,4) = J2(xyzlocations(L,2),xyzlocations(L,1),xyzlocations(L,3));
end


threshPOS = 0.2;
matPOS = J2pos > threshPOS; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');

threshREAL = 0.36;
matREAL = J2real > threshREAL; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');
>>>>>>> origin/master
=======
thresh = 1.2;

matPOS = J2pos > thresh; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');
matREAL = J2real > thresh; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');
>>>>>>> parent of 1e8d606... minor changes findparticles and imageprop
=======
thresh = 1.2;

matPOS = J2pos > thresh; [ xyzlocationsPOS ] = findxyz( matPOS ); figure(98); plot3(xyzlocationsPOS(:,1),xyzlocationsPOS(:,2),xyzlocationsPOS(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('POS');
matREAL = J2real > thresh; [ xyzlocationsREAL ] = findxyz( matREAL ); figure(99); plot3(xyzlocationsREAL(:,1),xyzlocationsREAL(:,2),xyzlocationsREAL(:,3),'b.'); box; grid minor; grid on; axis([0,512,0,512,0,251]); title('REAL');
>>>>>>> parent of 1e8d606... minor changes findparticles and imageprop

for L = 1:length(xyzlocationsPOS)
xyzlocationsPOS(L,4) = J2pos(xyzlocationsPOS(L,2),xyzlocationsPOS(L,1),xyzlocationsPOS(L,3));
end

for L = 1:length(xyzlocationsREAL)
xyzlocationsREAL(L,4) = J2real(xyzlocationsREAL(L,2),xyzlocationsREAL(L,1),xyzlocationsREAL(L,3));
end



% x_obj = x_obj+256
% y_obj = y_obj+256
xyzFound = zeros(5,4);
xyzFoundPOS = zeros(5,4);
xyzFoundREAL = zeros(5,4);
% Manually edit these records from correct xyzlocationsPOS and xyzlocationsREAL

% xyzTrue = zeros(5,4)
dx = 5.5e-6/4;
dy = 5.5e-6/4;
dz = 24E-6;
for L = 1:5
errorX(L) = dx*abs(xyzFound(L,1) - xyzTrue(L,1));
errorY(L) = dy*abs(xyzFound(L,2) - xyzTrue(L,2));
errorZ(L) = dz*abs(xyzFound(L,3) - xyzTrue(L,3));
end
errorTOTpos = sqrt(errorX.^2 + errorY.^2 + errorZ.^2);
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


figure(97)
bar([errorX'*1e6,errorY'*1e6])
title('Deviation in Deconvolved Position; X/Y NORM')
xlabel('Particle Number')
ylabel('Deviation in X/Y-Direction Only (um)')
colormap jet
legend('X','Y')
axis([0.5,5.5,0,2])

figure(98)
bar([errorXpos'*1e6,errorYpos'*1e6,errorZpos'*1e6])
title('Deviation in Deconvolved Position; X/Y/Z POS')
xlabel('Particle Number')
ylabel('Deviation in X/Y/Z-Direction Only (um)')
colormap jet
legend('X','Y','Z')
axis([0.5,5.5,0,30])

figure(99)
bar([errorXreal'*1e6,errorYreal'*1e6,errorZreal'*1e6])
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