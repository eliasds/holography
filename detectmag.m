L=10;
load('constants.mat')
load('background.mat')
% load('DH_0001.mat')
% Holo = Imin;
Holo = background;
z1 =0;
z2 = 15E-3;
thlevel = .005;
Holo = imcrop(Holo,[2560-1600,560,1599,1399]);
% [Imin, zmap] = imin(Holo,lambda/refractindex,linspace(z1,z2,1001),ps/mag,'zpad',2048);
Imin = Imin / max(Imin(:));
%save('bgImin.mat','Imin','zmap');
figure(L); imagesc(Imin); axis image; colorbar; colormap gray; L=L+1;
title(['Imin of ', pwd, '\background']);
figure(L); hist(Imin(:),100); L=L+1;
title(['hist Imin']);
th = Imin<thlevel;
figure(L); imagesc(th); axis image; colorbar; colormap gray; L=L+1;
title(['th of ', pwd, '\background']);
th = imdilate(th,ones(4));
th = imdilate(th,ones(4));
th = imdilate(th,ones(4));
thlabel = bwlabel(th,4);
figure(L); imagesc(thlabel); axis image; colorbar; colormap jet; L=L+1;
title(['Dilate1 th of ', pwd, '\background']);
th = bwareaopen(th, 8);

% LB = 8;   
% UB = 100;
% CC = bwconncomp(th);
% numPixels = cellfun(@numel,CC.PixelIdxList);
% UB = round(2*mean(numPixels));
% th = xor(bwareaopen(th,LB),  bwareaopen(th,UB));
% thlabel = bwlabel(th,4);
% figure(L); imagesc(thlabel); axis image; colorbar; colormap jet; L=L+1;
% title(['Remove Large areas from th']);

zth = zeros(size(zmap));
zth(th) = zmap(th);
figure(L); imagesc(zth); axis image; colorbar; colormap jet; L=L+1;
title(['zth of ', pwd, '\background']);


%% Detect Centroid Structures
th = bwlabel(th,4);
autodetstruct = regionprops(th,'Centroid','Area','PixelIdxList');
xy = [autodetstruct.Centroid];
Xauto = xy(1:2:end);
Yauto = xy(2:2:end);
Zauto_centroid = interp2(1:size(zmap,2),1:size(zmap,1),zmap,Xauto,Yauto);
figure(L); plot(Zauto_centroid, '.'); L=L+1;
title(['Zcentroid']);
figure(L); hist(Zauto_centroid,500); L=L+1;
title(['hist Zcentroid']);

% Determine mean Z-value from all pixels in region (biasing errors) and
%   depth of minimum intensity pixel
Zauto_mean=zeros(size(Xauto));
Zauto_min=zeros(size(Xauto));
for i = 1:numel(autodetstruct)
    idx = autodetstruct(i).PixelIdxList;
    Zauto_mean(i) = mean(zmap(idx));
    
    particlepixels = Imin(idx);
    [~,minidx] = min(particlepixels);
    Zauto_min(i) = zmap(idx(minidx));
end

figure(L); plot(Zauto_mean, '.'); L=L+1;
title(['Zmean']);
figure(L); hist(Zauto_mean,50); L=L+1;
title(['hist Zmean']);

figure(L); plot(Zauto_min, '.'); L=L+1;
title(['Zmin']);
figure(L); hist(Zauto_min,50); L=L+1;
title(['hist Zmin']);
figure(L); plot(Zauto_centroid, 'b.'); L=L+1;
hold on
plot(Zauto_mean, 'r.')
plot(Zauto_min, 'g.')
title(['hist Z all']);
legend('Centroid','Mean','Min');
hold off

