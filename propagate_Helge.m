function [ U_out ] = propagate( U_in, params )
%PROPAGATE propagates a field with various propagation methods
% default is the angular spectrum method

    if(~isfield(params,'method'))
        method='angular'; % angular,hcm,fresnel,farfield
    else
        method=params.method;
    end

    if(~isfield(params,'lambda'))
        lambda=632.8e-9;   % wavelength
    else
        lambda = params.lambda;
    end
    
    if(~isfield(params,'dx'))
        dx=5.5e-6;     % pixel size 1 µm
        dy=5.5e-6;     % pixel size 1 µm
    else
        dx=params.dx;
        dy=params.dy;
    end
    
    if(~isfield(params,'z'))
        z=500e-6; % distance 500 µm
    else
        z=params.z;
    end
    
    if(~isfield(params,'mask'))
        mask=1; % aperture mask
    else
        mask=params.mask;
    end

    k=2*pi/lambda;
    H=double(U_in);
    
    % Number of pixels
    [Ny, Nx]=size(H);
    
    % ----------------------
    % we really want to have
    % only even field sizes!
    % ----------------------
    if mod(Ny,2)
        H=H(1:end-1,:);
		fprintf('Warning: uneven field (rows)!\n');
    end
    if mod(Nx,2)
        H=H(:,1:end-1);
		fprintf('Warning: uneven field (columns)!\n');
    end
    
    [Ny, Nx]=size(H);
	
	switch method
		case 'angular'
			%------------------------------------------------------
			% Angular Spectrum Method
			%------------------------------------------------------
			spec=fftshift(fft2(H));
			% generate the spatial frequencies
			[kx, ky]=meshgrid( (-Nx/2:Nx/2-1) *(2*pi/(dx*Nx)),...
				               (-Ny/2:Ny/2-1) *(2*pi/(dy*Ny)));

			% low-pass filter for the input spatial frequencies
			circ= kx.^2+ky.^2 <= k^2;

% 			fprintf('ASM: size of evanescent field components: %spx\n',...
% 				num2str(Nx*Ny - sum(circ(:))));

			kernel=exp(1i*z*sqrt(k^2-kx.^2-ky.^2)).*circ;
			kernel(isnan(kernel))=0;

			% propagate the field
			propagation=(spec.*kernel.*mask);
					
			% back transformation
			U_out=ifft2(ifftshift(propagation));
			
% 		case 'fresnel2'
% 			% source plane
% 			[x0,y0] = meshgrid(...
% 				(-Nx/2:Nx/2-1) *dx,...
% 				(-Ny/2:Ny/2-1) *dy);
% 
% 			% destination plane
% 			[x,y] = meshgrid(...
% 				(-Nx/2:Nx/2-1) /(Nx*dx)*lambda*z,...
% 				(-Ny/2:Ny/2-1) /(Ny*dy)*lambda*z);
% 
% 			U_out = -1i*k/z * exp(1i*k*z)  ...
% 				* exp(1i*k/(2*z) * (x.^2 + y.^2)) ...
% 				.* fftshift(fft2(H .* exp(1i*k/(2*z) * (x0.^2+y0.^2))));
%             
% 		case 'fresnel3'
% 			N = size(H,1);
% 			d1 =params.dx;
% 			wvl = params.lambda;
% 			Dz = params.z;
% 			Uin = H;
% 			[x1 y1] = meshgrid((-N/2 : 1 : N/2 - 1) * d1);
% 
% 			[x2 y2] = meshgrid((-N/2 : N/2-1) / (N*d1)*wvl*Dz);
% 			% evaluate the Fresnel-Kirchhoff integral
% 			U_out = 1 / (i*wvl*Dz) ...
% 			.* exp(i * k/(2*Dz) * (x2.^2 + y2.^2)) ...
% 			.* fftshift(fft2(Uin .* exp(i * k/(2*Dz) ...
% 			* (x1.^2 + y1.^2))));

		case 'farfield'
			%------------------------------------------------------
			% Fraunhofer Diffraction Method
			% far field method
			% from DHM Kim, M. Eq. 2.36
			%------------------------------------------------------
			spec=fftshift(fft2(H));
			% generate the layer
			X = (1-Nx/2:Nx/2);
			Y = (1-Ny/2:Ny/2);
			X = X.*dx;
			Y = Y.*dy;
			[x,y] = meshgrid(X,Y);

			% DHM Kim, M. Eq. 2.36

			U_out = -(1i*k/z)*exp(1i*k*z) ...
				.* exp(1i*k/(2*z).*(x.^2+y.^2)) ...
				.* spec;
		
		case 'hcm'
			%------------------------------------------------------
			% Huygens Convolution Method
			% from DHM Kim, M. Eq. 4.20
			%------------------------------------------------------
			spec = fftshift(fft2(H));
			% generate the layer
			X = (1-Nx/2:Nx/2);
			Y = (1-Ny/2:Ny/2);
			X = X.*dx;
			Y = Y.*dy;
			[x,y]=meshgrid(X,Y);

			% equals the Huygens PSF
			% DHM Kim, M. Eq. 4.21
			kernel=fftshift(fft2(-(1i*k/(2*pi*z))* ...
				exp(sign(z)*1i*k*sqrt(x.^2+y.^2+z^2))));
			
			propagation=(spec.*kernel.*mask); 
			%------------------------------------------------------

			% back transformation
			U_out=ifftshift(ifft2(ifftshift(propagation)));
	end