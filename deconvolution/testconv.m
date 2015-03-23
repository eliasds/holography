%Test for convergence
tic
numofiterations = 100;
iternum = (2:numofiterations);
diffsumHOLO(numofiterations-1) = 0;
diffsumPSF(numofiterations-1) = 0;
[J,PSF3D] = deconvblind({Holo3D_Init},{PSF3D_Init},2);
diffsumHOLO(1) = sum(J{3}(:)-J{2}(:));
diffsumPSF(1) = sum(PSF3D{3}(:)-PSF3D{2}(:));
for L = 2:numofiterations-1
    [J,PSF3D] = deconvblind(J,PSF3D,1);
    diffsumHOLO(L) = sum(J{3}(:)-J{2}(:));
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