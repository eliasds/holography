%% Create a PSF from a 20um diameter Particle with magnification of 4x

sizeM=512;
mask0=ones(sizeM);
titlepos=[sizeM/2 sizeM/10];
lambda = 632.8E-9;
refractindex = 1.33;
ps = 5.5E-6;
mag = 4;
Z=linspace(-5E-3,5E-3,11);


circ = getnhood(strel('disk', 7, 0));
circ20um=double(circ);
circ20um(7:9,1)=0.5;
circ20um(7:9,15)=0.5;
circ20um(1,7:9)=0.5;
circ20um(15,7:9)=0.5;
circ20um=1-circ20um;
Ein=mask0;
Ein(sizeM/2-7:sizeM/2+7,sizeM/2-7:sizeM/2+7)=circ20um;

% upper left quad
region=round(sizeM*50/100);
mask0(1:region,1:region)=0;
mask0=flipud(fliplr(mask0));

figure(801)
imagesc(Ein); colorbar; colormap gray;
handle=title('Ein'); set(handle,'Position',[titlepos(1),titlepos(2)]);

figure(802)
imagesc(mask0); colorbar; colormap gray;
handle=title('MASK'); set(handle,'Position',[titlepos(1),titlepos(2)]);

[Eout]=propagate(Ein,lambda/refractindex,Z,ps/mag,'mask',mask0);
% psf=(fftshift(fft2(H)));
Holo = (1+2*real(Eout)+abs(Eout).^2);

figure(803); imagesc(Holo(:,:,1),[0 max(Holo(:))]); colorbar; colormap gray;
handle=title(['Engineered Hologram @ Z = ',num2str(1000*Z(1)),'mm']); set(handle,'Position',[titlepos(1),titlepos(2)]);
figure(804); imagesc(Holo(:,:,6),[0 max(Holo(:))]); colorbar; colormap gray;
handle=title(['Engineered Hologram @ Z = ',num2str(1000*Z(6)),'mm']); set(handle,'Position',[titlepos(1),titlepos(2)]);
figure(805); imagesc(Holo(:,:,end),[0 max(Holo(:))]); colorbar; colormap gray;
handle=title(['Engineered Hologram @ Z = ',num2str(1000*Z(end)),'mm']); set(handle,'Position',[titlepos(1),titlepos(2)]);