%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0
%
function  imageprop(Ein,lambda,Z,ps,varargin)

% clear all
% filename={'DH-001','tif'};
% filename={'Basler_acA2040-25gm__21407047__20141203_142806712_0100','tiff'};
% background='background.mat'; %comment out if no background file
% mag=4; %Magnification
% eps=6.5E-6 / mag; %Effective Pixel Size in meters
% ps=5.5E-6; %Effective Pixel Size in meters
% zpad=2048;
% refractindex = 1.33;
% lambda=632.8e-9;
% lambda=635e-9;
% lambda=785e-9; %in nanometers
% a=(0e-3); % Starting z position in meters
% b=(5e-3); % Ending z position in meters
% c=21; % number of steps
%{
if exist('background','var')==1
    load(background);
    Ein = double(imread(strcat(filename{1},'.',filename{2})))./background;
else
    %Ein=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
	Ein = double(imread(strcat(filename{1},'.',filename{2})));
end
Ein(isnan(Ein)) = 0;
%}
%%
%
% tic
%intensity=zeros(c,size(E2(1,1).time,1)+1);
%screensize=get(0,'screensize');
%screensize=[1,1,750,700];
%fig99=figure(99);set(fig99,'colormap',gray,'Position',screensize);

rect = [1,1,(size(Ein)-1)];
stopclick = 0;
pauseval = 0;
absreal = 'real';
L = 0;
while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'ABS'
            absreal = 'abs';
            varargin(1) = [];
            
        case 'REAL'
            absreal = 'real';
            varargin(1) = [];

        case 'PAUSE'
            if varargin{2} == ''
                stopclick = true;
            end
            pauseval = varargin{2};
            varargin(1:2) = [];
            
        case 'IMCROP'
            rect = varargin{2};
            rect(3:4) = rect(3:4)-1;
            varargin(1:2) = [];
            
        case 'MAXINT'
            maxint = varargin{2};
            varargin(1:2) = [];
            
        case 'MININT'
            minint = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            L = L + 1;
            varargin2{L} = varargin{1};
            varargin(1) = [];
            if isstr(varargin(1)) == false
                L = L + 1;
                varargin2{L} = varargin{1};
                varargin(1) = [];
            end
            
    end
end

if exist('varargin2','var')
    varargin = varargin2;
end
if ~exist('maxint','var')
    maxint=2*mean(abs(real(Ein(:))));
end
if ~exist('minint','var')
    minint=min(real(Ein(:)));
end
Eout = propagate(Ein,lambda,Z(1),ps,varargin{:});
abs_str1 = ['imagesc(imcrop(',absreal,'(Eout),rect),[minint maxint])'];
figure(99);
eval(abs_str1)
% imagesc(imcrop(real(Eout),rect),[minint maxint^2])
% imagesc(abs(Eout).^2,[0 maxint^2])
title(['Z = ',num2str(1000*Z(1)),'mm'],'FontSize',16);
colormap gray; colorbar; axis image;
drawnow
pause(pauseval)

for L=2:numel(Z)
    Eout = propagate(Ein,lambda,Z(L),ps,varargin{:});
    figure(99);
    eval(abs_str1)
%     imagesc(imcrop(abs(real(Eout)).^2,rect),[minint maxint^2])
%     imagesc(abs(Eout).^2,[0 maxint^2])
    title(['Z = ',num2str(1000*Z(L)),'mm'],'FontSize',16);
    colormap gray; colorbar; axis image;
    drawnow
    if stopclick==true
        pause
    end
    %
    %{
    intensity(loop,1)=z;
    for L=1:size(E2(1,1).time,1)
        intensity(loop,L+1)=abs(E1(round(E2(1,1).time(L,2)),round(E2(1,1).time(L,1))));
    end
    %}
    %waitbar(loop/c,wb);
end
% close(wb);
% toc
%