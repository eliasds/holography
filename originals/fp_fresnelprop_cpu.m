%% Fresnel Propagation Function.
% Version 3.0
% The Fresnel appoximation describes how the image from an object gets
% propagated in real space.
% This function produces the digital refocusing of a hologram.
% (ref pg 67,J Goodman, Introduction to Fourier Optics)
% function [E1,H] = fp_fresnelprop(E0,lambda,z,ps,zpad)
% inputs: E0 - complex field at input plane
%         lambda - wavelength of light [m]
%         z - propagation distance (can be negative)
%
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:E1 - propagated complex field
%         H - propagation kernel to check for aliasing
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com
% Reference Laura Waller's version...

function [E1,H] = fp_fresnelprop(E0,lambda,z,ps,zpad)
tic

[m,n]=size(E0);
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
    lambda=632.8e-9;
elseif nargin==1
    M=m;N=n;
    ps=6.5e-6;
    lambda=632.8e-9;
    z=0;
else
    M=m;N=n;
    ps=6.5e-6;
    lambda=632.8e-9;
    z=0;
    E0=phantom;
end

[x,y]=meshgrid(-N/2:(N/2-1), -M/2:(M/2-1));
fx=x/(ps*M);     %width of CCD [m]
fy=y/(ps*N);     %height of CCD [m]
k=2*pi/lambda; %wavenumber

%h=exp(1i*k*z)*exp(1i*k*(X.^2+Y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
H=exp(1i*k*z)*exp(-1i*pi*lambda*z*(fx.^2+fy.^2)); %Transfer Function


aveborder=mean(cat(2,E0(1,:),E0(m,:),E0(:,1)',E0(:,n)'));
ff=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
ff(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=E0;
E1=(ifft2(ifftshift(fftshift(fft2(ff)).*H)));
E1=E1(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2);

toc
