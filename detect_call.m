tic
OutputPathStr = ['analysis-',datestr(now,'yyyymmdd'),'\'];

if ~exist(OutputPathStr, 'dir')
    mkdir(OutputPathStr);
end

thlevel = 0;
for thlevel = 0.2:0.05:0.3
%     newdir = ['th',thlevel]
%     mkdir(newdir);
%     thlevel = thlevel + 0.05;
    for M = 3:9
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thlevel', thlevel, 'derstr',['R8D',num2str(M),'E',num2str(M-1),'R8D',num2str(M),'E',num2str(M-1)],'firstframe',151,'lastframe',250);
    end
    for M = 2:8
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thlevel', thlevel, 'derstr',['R8D',num2str(M),'E',num2str(M+1),'R8D',num2str(M),'E',num2str(M+1)],'firstframe',151,'lastframe',250);
    end
    for M = 2:9
        [Imin,zmap,constants,xyzLocCentroid,th] = detect('thlevel', thlevel, 'derstr',['R8D',num2str(M),'E',num2str(M),'R8D',num2str(M),'E',num2str(M)],'firstframe',151,'lastframe',250);
    end
end
toc
