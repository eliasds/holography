function [xyzLoc, xyzfile] = plotxyz(xyzfile, varargin)
%% plotxyz - Plot 3D Particle information
%
%            Daniel Shuldman <elias.ds@gmail.com>
%            Version 2.1
% Options:
%   'pause',pausevaluemilliseconds
%   'view',[az,el]  % Some good perspectives are:  
    % view(-150,20)
    % view(-34,18)
    % view(15,15) % small perspective in z
    % view(0,0) %flat overlaying hologram (default)
    % view(180,0) %reverse flat
    % view(0,90) %Projected along x-axis to view changes in z


%% Idea for finding real max and min z values:
% Accurate to within 20um with first dataset. Giving cuvette depth of
% 5.02mm instead of 5mm
%
% for L=1:512
% Mmin(L)=min(xyzLoc(1, L).time(:,3));
% Mmax(L)=max(xyzLoc(1, L).time(:,3));
% end
% [M,F]=mode(Mmin);
% [M,F]=mode(Mmax);

%%
tic
% clear all
undock
triperiod=20;
vidonflag = true; %Set to true to save video
holdflag = false;
colorstr = ',''b'''; % Default setting - does not seperate particles with colors
plotvortflag = false; %Set to true if you want to plot approx location of vorticella
insertbackgroundflag = false;
drawlinesflag = false;
latecropplotflag = false;
framerate = 40;
avgnumframes = 0;
jitterflag = false;
%[m,n]=size(Ein);
% radix2 = 2048;
% filename='Basler_acA2040-25gm__21407047';
% ext = 'tiff';
% xyzfile=['analysis-20150413/Basler_acA2040-25gm-th8E-02_dernum3-15_day73606793391.mat'];
% dirname='D:\shuldman\20150325\10mmCuvette2mmOutside_MaxParticlesTrial2\';
% xyzfile=['analysis-20150414\Basler_acA2040-25gm-th1E-01_dernum3-8_day73606852005.mat'];
% dirname='D:\shuldman\20150325\10mmCuvetteHalfwayIn_MaxParticlesTrial2\';
currdir = pwd;
try
    [dirname, filename, ext] = fileparts(xyzfile);
    varnam = who('-file',xyzfile);
    xyzLoc=load(xyzfile,varnam{1});
    xyzLoc=xyzLoc.(varnam{1});
    movfilename = xyzfile(1:end-4);
    if ~isempty(strfind(movfilename,'tracked'))
        trackedpos = strfind(movfilename,'tracked');
        movfilename = movfilename(1:trackedpos-1);
    end
catch
    xyzLoc = xyzfile;
    try
        movfilename = particlefilename;
    catch
        movfilename = 'plotxyzVID';
    end
end


try
    varnam = who('-file','background.mat');
    dirname = pwd;
    background = load([dirname,'\background.mat'],varnam{1});
    background=background.(varnam{1});
    [m,n]=size(background);
catch
    try
        cd ..\
        varnam = who('-file','background.mat');
        dirname = pwd;
        background = load([dirname,'\background.mat'],varnam{1});
        background=background.(varnam{1});
        [m,n]=size(background);
        cd(currdir);
    catch
        try
            cd ..\
            varnam = who('-file','background.mat');
            dirname = pwd;
            background = load([dirname,'\background.mat'],varnam{1});
            background=background.(varnam{1});
            [m,n]=size(background);
            cd(currdir);
        catch
            m = 2048;
            n = m;
            cd(currdir);
        end
    end
end

try
    load([movfilename,'constants.mat']);
    if ~exist('rect_xydxdy','var')
        if ~exist('rect','var')
            rect_xydxdy = [1 1 n m];
        else
            eval('rect_xydxdy = rect;');
            clear('rect');
        end
    end
    disp(['Using Constants from ',movfilename(1:end-4),'constants.mat']);
catch
    try
        cd ..\
        load('constants.mat');
            if ~exist('rect_xydxdy','var')
                if ~exist('rect','var')
                    rect_xydxdy = [1 1 n m];
                else
                    eval('rect_xydxdy = rect;');
                    clear('rect');
                end
            end
        cd(currdir);
        disp(['Using Constants from ',pwd,'\constants.mat']);
    catch
        try
            cd ..\
            load('constants.mat');
                if ~exist('rect_xydxdy','var')
                    if ~exist('rect','var')
                        rect_xydxdy = [1 1 n m];
                    else
                        eval('rect_xydxdy = rect;');
                        clear('rect');
                    end
                end
            cd(currdir);
            disp(['Using Constants from ',pwd,'\constants.mat']);
        catch
            ps=6.5e-6;
            mag = 4;
            z1 = 0;
            z2 = 10E-3;
            rect_xydxdy = [1 1 n m];
            disp(['Using Default Constants; ps=6.5E-6, mag=4, z1=0, z2=10E-3, rect=',num2str(rect_xydxdy)]);
            cd(currdir);
        end
    end
end
% rect_xydxdy = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
% rect_xydxdy = [Xceil,Yceil,xmax-1,ymax-1]; %Cropping
% rect_xydxdy = [512 512 1023 1023];
xmax = rect_xydxdy(3)*ps/mag; % max pixels in x propagation
ymax = rect_xydxdy(4)*ps/mag; % max pixels in y propagation
zmax = abs(z2-z1); % max distance in z propagation
% xscale = 1000*ps/mag; %recontructed pixel distance in mm
% yscale = 1000*ps/mag; %recontructed pixel distance in mm
xscale = 1000; %recontructed pixel distance in mm
yscale = 1000; %recontructed pixel distance in mm
zscale = 1000; %recontructed distance in mm
% lastframe = 'numfiles';
% lastframe = '2';
lastframe = 'length(xyzLoc)';
fignum=1001;
handle=figure(fignum); set(handle, 'Position', [100 100 768 512])
view(0,0) %flat overlaying hologram
[az,el] = view;
plotstr = 'figure(fignum); scatter3(xscale*xyzLoc(L+M).time(:,1),zscale*(-z2+xyzLoc(L+M).time(:,3)),yscale*(ymax-xyzLoc(L+M).time(:,2)),30,''filled''';
tmp = z1;
z1 = max(tmp,z2);
z2 = min(tmp,z2);

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'PAUSE'
            pauseval = varargin{2};
            varargin(1:2) = [];
            
        case 'BACKGROUND'
            backgroundfile = varargin{2};
            background = load(backgroundfile);
            varargin(1:2) = [];
            
        case 'OVERLAY'
            hologramfile = varargin{2};
            filename = varargin{2};
            varargin(1:2) = [];
            
        case 'VIEW'
            [az] = varargin{2}(1);
            [el] = varargin{2}(2);
            varargin(1:2) = [];
            
        case 'CONSTANTS'
            constantsfile = varargin{2};
            load(constantsfile);
                if ~exist('rect_xydxdy','var')
                    if ~exist('rect','var')
                        rect_xydxdy = [1 1 n m];
                    else
                        rect_xydxdy = rect;
                        clear('rect');
                    end
                end
            disp(['NOW using Constants from ',constantsfile]);
            varargin(1:2) = [];
            
        case 'IMCROP'
            rect_xydxdy = varargin{2};
            rect_xydxdy(3:4) = rect_xydxdy(3:4)-1;
            xmax = rect_xydxdy(3); % max pixels in x propagation
            ymax = rect_xydxdy(4); % max pixels in y propagation
            varargin(1:2) = [];
            
        case 'LATECROP'
            latecropplotflag = true;
            if numel(varargin{2}) ~= 4
                rect_xydxdy_copy = [(varargin{2}(1:2)), 1023,1023];
            else
                rect_xydxdy_copy = [varargin{2}];
                rect_xydxdy_copy(3:4)=rect_xydxdy_copy(3:4)-1;
            end
            xmax = rect_xydxdy(3); % max pixels in x propagation
            ymax = rect_xydxdy(4); % max pixels in y propagation
            varargin(1:2) = [];
            
        case 'VIDEO'
            varargin(1) = []; 
            vidonflag = true;
            
        case 'FPS'
            framerate = varargin{2};
            varargin(1:2) = [];
            
        case 'LASTFRAME'
            lastframe = varargin{2};
            varargin(1:2) = [];
            
        case 'AVERAGE'
            avgnumframes = varargin{2};
            varargin(1:2) = [];
            
        case 'HOLD'
            holdflag = true;
            varargin(1) = [];
            
        case 'COLOR' %plot particles with different color, only works with track_particles
            colorstr = ',''CData'',xyzLoc(L+M).time(:,4));colormap(jet(125)';
            varargin(1) = [];
            
        case 'JITTER' %Create plot at various angles to emphasize 3D nature
            jitterflag = true;
            varargin(1) = [];
            
        case 'FILENAME'
            movfilename = varargin{2};
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
            
    end
end

numframes = eval(lastframe)-avgnumframes;


if insertbackgroundflag == true;
    filename = strcat(dirname,filename);
    filesort = dir([filename,'*.',ext]);
    numfiles = numel(filesort);
    for L = 1:numfiles-avgnumframes
        [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
            fileparts([filesort(L).name]);
        %filesort(i).matname=strcat(filesort(i).matname,'.mat');
    end
end


% Change Default Crop Parameters
if latecropplotflag == true
    rect_xydxdy = rect_xydxdy_copy;
    xmax = rect_xydxdy(3); % max pixels in x propagation
    ymax = rect_xydxdy(4); % max pixels in y propagation
end


% mov(eval(lastframe)-avgnumframes).cdata = [];
% mov(eval(lastframe)-avgnumframes).colormap = [];
mov(eval(lastframe)-avgnumframes) = struct('cdata',zeros(rect_xydxdy(4),rect_xydxdy(3),3,'uint8'),'colormap',[]);

L=1;
M=0;
plotstr = [plotstr,colorstr,');'];
eval(plotstr)
for L=1:eval(lastframe)-avgnumframes
    deltadeg=triperiod*(sawtooth(2*pi*L/triperiod/4,.5)+1)/8;
    if holdflag == true
        hold on
    else
        hold off
    end
    clf('reset')
    if jitterflag == true
        view([az+deltadeg,el])
    else
        view([az,el])
    end
%     figure(fignum)
%     for M=1:avgnumframes
%         groupz(:,M)=xyzLoc(L+M-1).time(:,3);
%     end
%     meanz=mean(groupz,2);
%     modez=mode(groupz,2);
%     medianz=median(groupz,2);
%     plot3(xscale*xyzLoc(L).time(:,1),zscale*(-z1+meanz),yscale*(xyzLoc(L).time(:,2)),'b.');
%     plot3(xscale*xyzLoc(L+M).time(:,1),zscale*(-z1+xyzLoc(L+M).time(:,3)),yscale*(xyzLoc(L+M).time(:,2)),'b.');
    %% Insert Hologram image as backdrop
    %
    if insertbackgroundflag == true;
        Holo = sqrt(imcrop(double(imread([filesort(L).name])) ./ background,rect_xydxdy));
        % title(['3D Particle Detection']);
        colormap gray
        figure(fignum); hold off;
        surface('XData',[0 xscale*xmax; 0 xscale*xmax],'YData',[zscale*zmax zscale*zmax; zscale*zmax zscale*zmax],'ZData',[0 0; yscale*ymax yscale*ymax],'CData',(flipud(Holo)),'FaceColor','texturemap','EdgeColor','none');
        hold on
    end
    
    %% average none or several frames together (poorly)
    for M=0:avgnumframes
        if M>0
            hold on
        end
        eval(plotstr);
    end
    
    %% Draw big Vorticella
    if plotvortflag == true
        plot_3d(xscale*vortloc(1),zscale*(-z1+vortloc(3)),(yscale*(ymax-vortloc(2))),.1*[1,1,1],[1,0,0]);
    end

    %% Draw lines back to the Hologram plane.
    if drawlinesflag == true
        for N=1:10;
            scatter3([xscale*xyzLoc(L).time(N,1),xscale*xyzLoc(L).time(N,1)],[0,zscale*(-z1+xyzLoc(L).time(N,3))],[(yscale*(ymax-xyzLoc(L).time(N,2))),(yscale*(ymax-xyzLoc(L).time(N,2)))],'b-');
        end
    end
    
    axis equal
    axis([0,ceil(2*xscale*xmax)/2,0,ceil(zscale*zmax),0,ceil(2*yscale*ymax)/2]);


%     hold off
    xlabel('(mm)')
    zlabel('(mm)')
    ylabel('Through Focus (mm)')
    title(['Frame#:',num2str(L),'   (time in AU)']);
    grid on
    grid minor
    box on
    if jitterflag == true
        view([az+deltadeg,el])
    else
        view([az,el])
    end
    drawnow
%     axis image
    if vidonflag==true
%        t = colorbar;
%        set(get(t,'ylabel'),'string','Z Depth(m)','fontsize',16)
        mov(:,L) = getframe(fignum) ;
    end
end
hold off

if vidonflag==true
    if ischar(xyzfile) && isequal('plotxyzVID',movfilename)
        if ~isempty(strfind(xyzfile,'tracked')) 
            writerObj = VideoWriter([xyzfile(1:end-4),'_3DParticleDetectionVideo_rand',num2str(uint8(rand*100))],'MPEG-4');
        end
    else
        writerObj = VideoWriter([movfilename,'_3DParticleDetectionVideoAZ',num2str(az),'EL',num2str(el),'_rand',num2str(uint8(rand*100))],'MPEG-4');
    end
    writerObj.FrameRate = framerate;
    open(writerObj);
    writeVideo(writerObj,mov);
    close(writerObj);
end

toc