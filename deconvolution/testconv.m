%Test for convergence
tic
numofiterations = 50;
iternum = (2:numofiterations);
diffsumHOLO(numofiterations-1) = 0;
diffsumPSF(numofiterations-1) = 0;
[HOLO3D,PSF3D] = deconvblind({HOLO3Di},{PSF3Di},2);
toc
diffsumHOLO(1) = sum(HOLO3D{3}(:)-HOLO3D{2}(:));
diffsumPSF(1) = sum(PSF3D{3}(:)-PSF3D{2}(:));
%%
for L = 2:9%numofiterations-1
    [HOLO3D,PSF3D] = deconvblind(HOLO3D,PSF3D,1);
    diffsumHOLO(L) = sum(HOLO3D{3}(:)-HOLO3D{2}(:));
    diffsumPSF(L) = sum(PSF3D{3}(:)-PSF3D{2}(:));
end

save(['testconv_',num2str(numofiterations),'iterations.mat'],'diffsumHOLO','diffsumPSF','-v7.3');

h(1) = figure(298);
p = plot(iternum,diffsumPSF);
axis tight
title('Convergence Results of PSF')
xlabel('Number of Iterations')
ylabel('Difference (AU)')
p(1).LineWidth = 2;
saveas(h(1),'ConvResultsPSF.fig')
saveas(h(1),'ConvResultsPSF.png')

h(2) = figure(299);
p = plot(iternum,diffsumHOLO);
axis tight
title('Convergence Results of Holo')
xlabel('Number of Iterations')
ylabel('Difference (AU)')
p(1).LineWidth = 2;
saveas(h(2),'ConvResultsHOLO.fig')
saveas(h(2),'ConvResultsHOLO.png')

toc