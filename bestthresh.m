function [ thlevel ] = bestthresh( Imin, thparam, plotflag )
%bestthresh find the best threshold parameter based on histogram
%   Detailed explanation goes here

% Determine optimal threshold (thlevel) from Imin
%
if nargin == 1
%     thparam = 0.5;
%     thparam = 0.4;
    thparam = 0.333;
%     thparam = 0.25;
%     thparam = 0.1;
%     thparam = 0.05;
%     thparam = 0.01;
%     thparam = 0.0;
%     thparam = -0.01;
%     thparam = -0.05;
end

nbins = round(sqrt(numel(Imin)));
[bincount,edges] = histcounts(Imin(:),nbins);
% figure;histogram(Imin(:),nbins);title('histogram(Imin(:),nbins)')

[maxvalue,maxindex] = max(bincount(round(nbins/50):end));
maxindex = maxindex + round(nbins/50)-1;
nbins = maxindex + round(nbins/50);
bincount = bincount(1:nbins);
edges = edges(1:nbins+1);

bincountsmooth = smooth(bincount,'lowess');
if exist('plotflag', 'var')
    figure;plot(edges(2:end),bincountsmooth);title('plot(edges,bincountsmooth)')
end
[minvaluesmooth,minindexsmooth] = min(bincountsmooth(1:nbins));
[maxvaluesmooth,maxindexsmooth] = max(bincountsmooth(ceil(nbins/50):end));
maxindexsmooth = maxindexsmooth + round(nbins/50)-1;
minmaxsmoothdiff = maxindexsmooth - minindexsmooth;
thlevel_index = round(minindexsmooth + thparam*minmaxsmoothdiff);
if thlevel_index < 1
    warning('thparam too low. Setting thlevel to lowest possible value.');
    thlevel_index = 1;
end
thlevel = sum(edges(thlevel_index:thlevel_index+1))/2;

end

