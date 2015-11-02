function [field2,H] = propagate(field1,lambda,z,ps,zpad)
% propagate a field in z (digital focusing of a hologram)
% function [field2,H] = propagate(field1,lambda,z,ps,zpad)
% inputs: field1 - complex field at input plane
%         lambda - wavelength of light [m]
%         z - propagation distance (can be negative)
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:field2 - propagated complex field
%         H - propagation kernel to check for aliasing
%
% Laura Waller, MIT, lwaller@alum.mit.edu

[m,n]=size(field1);
if nargin==5
    M=zpad;
    N=zpad;
elseif nargin==4
    M=m;N=n;
else
    M=m;N=n;
    ps=12*10^-6;
end
[x,y]=meshgrid(-N/2+1:N/2, -M/2+1:M/2);
fx=x/(ps*M);     %width of CCD [m]
fy=y/(ps*N);     %height of CCD [m]
k=2*pi/lambda;

%H=exp(i*k*z)*exp(-i*pi*lambda*z.*(x.^2+y.^2));
H=exp(-i*pi*lambda*z.*(fx.^2+fy.^2));

aveborder=mean(cat(2,field1(1,:),field1(m,:),field1(:,1)',field1(:,n)'));
ff=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
ff(1:m,1:n)=field1;
objFT=fftshift(fft2(ff));
field2=(ifft2(fftshift(objFT.*H)));

field2=field2(1:m,1:n);
