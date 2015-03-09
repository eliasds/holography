function Eout = mask(Ein ,aperture, zpad)

%{
if length(size(Ein)) == 2
    
    [m,n]=size(Ein);  ypad=m;  xpad=n;
    if nargin < 3
        zpad=2*ceil(length(Ein)/2);
    end
    if length(zpad) == 1
        ypad=zpad;
        xpad=zpad;
    else
        ypad=zpad(1);
        xpad=zpad(2);
    end
    if nargin < 2
        aperture = ones(ypad,xpad);
        aperture(:,1:xpad/2-1) = 0;
    end

    avgborder=mean(cat(2,Ein(1,:),Ein(m,:),Ein(:,1)',Ein(:,n)'));
    Ein_pad=ones(ypad,xpad)*avgborder; %pad by average border value to avoid sharp jumps
    Ein_pad(1+(ypad-m)/2:(ypad+m)/2,1+(xpad-n)/2:(xpad+n)/2)=Ein;
    EinFFT = fftshift(fft2(Ein_pad));
    Eout=EinFFT.*aperture;
    Eout=ifft2(ifftshift(Eout));
    Eout=Eout(1+(ypad-m)/2:(ypad+m)/2,1+(xpad-n)/2:(xpad+n)/2);

end

if length(size(Ein)) == 3
%}

    [m,n,o]=size(Ein);  ypad=m;  xpad=n;
    if nargin < 3
        zpad=2*ceil(length(Ein(:,:,1))/2);
    end
    if length(zpad) == 1
        ypad=zpad;
        xpad=zpad;
    else
        ypad=zpad(1);
        xpad=zpad(2);
    end
    if nargin < 2
        aperture = ones(ypad,xpad,o);
        aperture(:,1:xpad/2-1,:) = 0;
    end

    % avgborder=mean(cat(2,squeeze(Ein(1,:,:)),squeeze(Ein(m,:,:)),squeeze(Ein(:,1,:)'),squeeze(Ein(:,n,:)')));
    % Ein_pad=ones(ypad,xpad)*avgborder; %pad by average border value to avoid sharp jumps
    % Ein_pad(1+(ypad-m)/2:(ypad+m)/2,1+(xpad-n)/2:(xpad+n)/2)=Ein;
    Ein_pad = Ein;
    EinFFT = fftshift(fft2(Ein_pad));
    Eout = EinFFT.*aperture;
    Eout = ifft2(ifftshift(Eout));
    Eout = abs(Eout);
    % Eout = Eout(1+(ypad-m)/2:(ypad+m)/2,1+(xpad-n)/2:(xpad+n)/2);

% end


end

