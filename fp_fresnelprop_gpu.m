%% Fresnel Propagation on CUDA/NVIDIA GPU Function.
% Version 4.0
% The Fresnel appoximation describes how the image from an object gets
% propagated in real space.
% This function produces the digital refocusing of a hologram.
% (ref pg 67,J Goodman, Introduction to Fourier Optics)
% function [E1,H] = fp_fresnelprop_gpu(E0,lambda,Z,ps,zpad)
% inputs: E0 - complex field at input plane
%         lambda - wavelength of light [m]
%         Z - vector of propagation distances [m], (can be negative)
%               i.e. "linspace(0,10E-3,500);"
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:E1 - propagated complex field
%         H - propagation kernel to check for aliasing
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com
% Reference Laura Waller's version...

function [E1,H] = fp_fresnelprop_gpu(E0,lambda,Z,ps,zpad)

% reset(gpuDevice(1));

% Set Defaults and detect initial image size
[m,n]=size(E0);
if nargin==5
    M=zpad;
    N=zpad;
elseif nargin==4
    M=m;N=n;
end


% Initialize variables into GPU
lambda = gpuArray(lambda);
Z = gpuArray(Z);
ps = gpuArray(ps);
k=(2*pi/lambda);  %wavenumber
E1_gpu = gpuArray.zeros(m,n,length(Z));
if nargout>1
    H1_gpu = gpuArray.zeros(M,N,length(Z));
end


% Spatial Sampling
[x,y]=meshgrid(-N/2:(N/2-1), -M/2:(M/2-1));
fx=(x/(ps*M));    %frequency space width [1/m]
fy=(y/(ps*N));    %frequency space height [1/m]
fx2fy2 = fx.^2 + fy.^2;


% Padding value 
aveborder=gpuArray(mean(cat(2,E0(1,:),E0(m,:),E0(:,1)',E0(:,n)')));
E0_gpu=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
E0_gpu(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=E0;

% FFT of E0
E0fft = fftshift(fft2(E0_gpu));

for z = 1:length(Z)
    %h(:,:,z) = exp(1i*k*z)*exp(1i*k*(x.^2+y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
    %H  = exp(1i*k*Z(z))*exp(-1i*pi*lambda*Z(z)*(fx2fy2)); %Correct Transfer Function
    H  = exp(-1i*pi*lambda*Z(z)*(fx2fy2)); %Fast Transfer Function
    if nargout>1
        H1_gpu(:,:,z) = H;
    end
    E1temp=ifft2(ifftshift(E0fft.*H));
    E1_gpu(:,:,z)=E1temp(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2);
end

E1=gather(E1_gpu);
if nargout>1
    H=gather(H1_gpu);
end
%toc