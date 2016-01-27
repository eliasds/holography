tic
OutputPathStr = ['analysis-',datestr(now,'yyyymmdd'),'\'];

if ~exist(OutputPathStr, 'dir')
    mkdir(OutputPathStr);
end

thlevel = 0;
%     thparam = 0.5;
%     thparam = 0.4;
%     thparam = 0.333;
%     thparam = 0.25;
%     thparam = 0.1;
%     thparam = 0.05;
%     thparam = 0.01;
% thparamlist = [.4,.333,.25];

for thparam = [0.01,0.02,0.05,0.1]
%     newdir = ['th',thlevel]
%     mkdir(newdir);
%     thlevel = thlevel + 0.05;
    for M = 3
        
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8E',num2str(M-1),'D',num2str(M),'E',num2str(M-1)],'firstframe',151,'lastframe',220);
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8E',num2str(M-1),'D',num2str(M),'E',num2str(M+1)],'firstframe',151,'lastframe',220);
    end
    for M = 3:4
        
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8E',num2str(M-1),'D',num2str(M)],'firstframe',151,'lastframe',220);
    end
    for M = 3:6
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M),'E',num2str(M-1)],'firstframe',151,'lastframe',220);
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M),'E',num2str(M+1)],'firstframe',151,'lastframe',220);
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M-1),'E',num2str(M)],'firstframe',151,'lastframe',220);
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thparam', thparam, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M-1),'E',num2str(M)],'firstframe',151,'lastframe',220);
    end
end
toc
