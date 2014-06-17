%% Fresnel Propagation Function.
% Version 5.0
% The Fresnel appoximation describes how the image from an object gets
% propagated in real space.
% This function produces the digital refocusing of a hologram.
% (ref pg 67,J Goodman, Introduction to Fourier Optics)
% function [E1,H] = fp_fresnelprop_cpu(E0,lambda,Z,ps,zpad)
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

function [Eout,Hout] = propagate(Ein,lambda,Z,ps,zpad)

gpu_num = gpuDeviceCount; %Determines if there is a CUDA enabled GPU

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
if gpu_num == 0;
    Eout = zeros(m,n,length(Z));
    aveborder=mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)'));
    if nargout>1
        Hout = zeros(M,N,length(Z));
    end
else
    lambda = gpuArray(lambda);
    Z = gpuArray(Z);
    ps = gpuArray(ps);
    Eout = gpuArray.zeros(m,n,length(Z));
    aveborder=gpuArray(mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)')));
    if nargout>1
        Hout = gpuArray.zeros(M,N,length(Z));
    end
end
k=(2*pi/lambda);  %wavenumber


% Spatial Sampling
[x,y]=meshgrid(-N/2:(N/2-1), -M/2:(M/2-1));
fx=(x/(ps*M));    %frequency space width [1/m]
fy=(y/(ps*N));    %frequency space height [1/m]
fx2fy2 = fx.^2 + fy.^2;


% Padding value 
E0_pad=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
E0_pad(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=Ein;


% FFT of E0
E0fft = fftshift(fft2(E0_pad));
for z = 1:length(Z)
    %h(:,:,z) = exp(1i*k*z)*exp(1i*k*(x.^2+y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
    %H  = exp(1i*k*Z(z))*exp(-1i*pi*lambda*Z(z)*(fx2fy2)); %Correct Transfer Function
    H  = exp(-1i*pi*lambda*Z(z)*(fx2fy2)); %Fast Transfer Function
    if nargout>1
        Hout(:,:,z) = H;
    end
    E1temp=ifft2(ifftshift(E0fft.*H));
    Eout(:,:,z)=E1temp(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2);
end


% Gather variables from GPU if necessary
if gpu_num > 0;
    Eout=gather(Eout);
    if nargout > 1
        Hout=gather(Hout);
    end
end
