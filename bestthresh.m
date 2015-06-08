function [ thlevel ] = bestthresh( Imin, thparam, histcutoff )
%bestthresh find the best threshold parameter based on histogram
%   Detailed explanation goes here

% Determine optimal threshold (thlevel) from Imin
%
if nargin == 1
    histcutoff = 0.75;
%     thparam = 0.5;
%     thparam = 0.4;
    thparam = 0.333;
%     thparam = 0.25;
%     thparam = 0.1;
%     thparam = 0.05;
%     thparam = 0.01;
elseif nargin == 2
    histcutoff = 0.75;
end

% Imin = imcrop(Imin,rect_xydxdy);
nbins = round(sqrt(numel(Imin)));
[bincount,edges] = histcounts(Imin(:),nbins);
% figure;histogram(Imin(:),nbins);title('histogram(Imin(:),nbins)')

nbins=round(histcutoff*nbins);
bincount = bincount(1:nbins);
edges = edges(1:nbins);

% figure;plot(edges,bincount);title('plot(edges,bincount)')
% [minvalue minindex] = min(bincount(:));
% [maxvalue maxindex] = max(bincount(:));
% minmaxdiff = maxindex - minindex
% thlevel_index = round(minindex + thparam*minmaxdiff)
% thlevel = edges(thlevel_index)

bincountsmooth = smooth(bincount,'lowess');
% figure;plot(edges,bincountsmooth);title('plot(edges,bincountsmooth)')
[minvaluesmooth minindexsmooth] = min(bincountsmooth(1:nbins));
[maxvaluesmooth maxindexsmooth] = max(bincountsmooth(1:nbins));
minmaxsmoothdiff = maxindexsmooth - minindexsmooth;
thlevel_index = round(minindexsmooth + thparam*minmaxsmoothdiff);
thlevel = edges(thlevel_index);
% axis([0,max(edges),0,5000]);

end

