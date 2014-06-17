%% Fresnel Propagation and Minimum Intensity Function for CPU/GPU.
% Version 5.0
% The Fresnel appoximation describes how the image from an object gets
% propagated in real space.
% This function produces the minimum intensity (per pixel) from a hologram
% digitally refocused to many propagated distances.
% (ref pg 67,J Goodman, Introduction to Fourier Optics)
% Version 5 works on CUDA enabled GPU if available.
% function [Imin, zmap] = fp_imin(Ein,lambda,Z,ps,zpad)
% inputs: Ein - complex field at input plane
%         lambda - wavelength of light [m]
%         Z - vector of propagation distances [m], (can be negative)
%               i.e. "linspace(0,10E-3,500)" or "0.01"
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:Imin - find minimum intensity of each pixel through focus
%         zmap - map z-coordinate to each minimum intesity pixel
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com


function [Imin, zmap] = fp_imin(Ein,lambda,Z,ps,zpad)

% Set Defaults and detect initial image size
[m,n]=size(Ein);
if nargin==5
    M=zpad;
    N=zpad;
elseif nargin==4
    M=m;N=n;
elseif nargin==3
    M=m;N=n;
    ps=6.5e-6;
elseif nargin==2
    M=m;N=n;
    ps=6.5e-6;
    Z=0;
elseif nargin==1
    M=m;N=n;
    ps=6.5e-6;
    Z=0;
    lambda=632.8e-9;
else
    M=m;N=n;
    ps=6.5e-6;
    Z=0;
    lambda=632.8e-9;
    Ein=phantom;
end


% Initialize variables into CPU or GPU
gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU
if gpu_num == 0;
    Imin = inf(m,n); 
    zmap = zeros(m,n);
    Eout = zeros(m,n,length(Z));
    aveborder=mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)'));
else
    % reset(gpuDevice(1));
    lambda = gpuArray(lambda);
    Z = gpuArray(Z);
    ps = gpuArray(ps);
    Imin = gpuArray.inf(m,n);
    zmap = gpuArray.zeros(m,n);
    Eout = gpuArray.zeros(m,n,length(Z));
    aveborder=gpuArray(mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)')));
end
k=(2*pi/lambda);  %wavenumber


% Spatial Sampling
[x,y]=meshgrid(-N/2:(N/2-1), -M/2:(M/2-1));
fx=(x/(ps*M));    %frequency space width [1/m]
fy=(y/(ps*N));    %frequency space height [1/m]
fx2fy2 = fx.^2 + fy.^2;


% Padding value 
Ein_pad=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
Ein_pad(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=Ein;


% FFT of E0
E0fft = fftshift(fft2(Ein_pad));
for z = 1:length(Z)
    %h(:,:,z) = exp(1i*k*z)*exp(1i*k*(x.^2+y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
    %H  = exp(1i*k*Z(z))*exp(-1i*pi*lambda*Z(z)*fx2fy2); %Correct Transfer Function
    H  = exp(-1i*pi*lambda*Z(z)*fx2fy2); %Fast Transfer Function
    Eout_pad=ifft2(ifftshift(E0fft.*H)); %real, magnitude of the field

    Eout=abs(Eout_pad(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)); %real, unpadded reconstruction intensity
    Imin = min(Imin, Eout);
    zmap(Imin==Eout) = Z(z);
end


% Gather variables from GPU if necessary
if gpu_num > 0;
    Imin = gather(Imin).^2;
    zmap = gather(zmap);
end
