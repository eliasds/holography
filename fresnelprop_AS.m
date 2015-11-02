function [Ef,x,y,Fx,Fy,H] = fresnel_prop(E0,N,ps,lam,z)
%function Ef = fresnel_prop(E0,N,ps,lam,z)
%Function Input: Initial field in x-y, wavelength lam, no of sample points N, pixel size in um say,z value
%Function output: Final field in x-y after Fresnel Propagation    
%(ref pg 67,J Goodman, Introduction to Fourier Optics)

%%
%Spatial Sampling
%xsize = 10^3;ysize= 10^3;           %Grid size (Pixel size should be of the order of the wavelength; the sharp edge adds noise in high frequencies)
xsize =  ps*N; ysize = ps*N;
fprintf('\nIn um\n');
Pixel_Size = xsize/N                 %Print pixel size

z

%N = 1001;                          %No of sample points in space (preferably odd to include zero)
x = linspace(-xsize/2,xsize/2,N);   %N point sampling over xsize
y = linspace(-ysize/2,ysize/2,N);

% %Proper way of creating frequency axes(fix this)
% wx =2*pi*(0:(N-1))/N;fx =N/xsize*unwrap(fftshift(wx)-2*pi)/2/pi;
% [Fx,Fy] = meshgrid(fx,fx);

%The real proper way
wx =2*pi*(0:(N-1))/N; %Create unshifted default omega axis
%fx =1/ps*unwrap(fftshift(wx)-2*pi)/2/pi; 
fx = 1/ps*(wx-pi*(1-mod(N,2)/N))/2/pi; %Shift zero to centre - for even case, pull back by pi, for odd case by pi(1-1/N)
[Fx,Fy] = meshgrid(fx,fx);


% %Inverse space
% fx = linspace(-(N-1)/2*(1/xsize),(N-1)/2*(1/xsize),N);Fx = repmat(fx,N,1);
% fy = linspace(-(N-1)/2*(1/ysize),(N-1)/2*(1/ysize),N);Fy = repmat(fy',1,N);
% [val,index_centre] = min(abs(fx)); %Finds the index of centre element (useful in plotting) 
%%
%Point spread function h=H(kx,ky) 
%H = sqrt(z*lam)*exp(1i*pi*lam*z*(Fx.^2+Fy.^2));
H = exp(1i*2*pi/lam*z)*exp(1i*pi*lam*z*(Fx.^2+Fy.^2));
E0fft = fftshift(fft2(E0));                 %Centred about zero (as fx and fy defined to be centred around zero)
G = H.*E0fft;
g = ifft2(ifftshift(G));                    %Output after deshifting the fourier transform
Ef=g;
%%
%Plot
%subplot(3,1,1);imagesc(fx,fy,abs(H));title('FT of PSF ');
% subplot(3,1,1);plot(fx,real(H(index_centre,:)));title('Analytic fourier transform of point spread function along fx');
% subplot(3,1,2);imagesc(fx,fy,abs(E0fft));title('Fourier transform of input function');
% subplot(3,1,3);imagesc(fx,fy,abs(G));title('Multiplied fourier transform');
%final intensity
% 

% figure;
% imagesc(x,y,abs(g).^2);title('Final field');colormap(gray);