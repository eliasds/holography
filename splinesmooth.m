function [ smoothdepvar ] = splinesmooth( indvar, depvar, smoothparam )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.SmoothingParam = 0.00743936556435324;

if nargin == 1
    depvar = indvar;
    indvar = (1:length(indvar))';
elseif nargin == 3
    opts.SmoothingParam = smoothparam;
end

warningID = 'curvefit:prepareFittingData:removingNaNAndInf';
warning('off',warningID)
[xData, yData] = prepareCurveData( indvar, depvar );
warning('on',warningID)

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );

smoothdepvar = NaN(size(indvar));
smoothdepvar(xData) = fitresult(xData);

%{
% Plot fit with data.
figure( 'Name', 'Spline ' );
plot( fitresult, xData, yData );
% Label axes
xlabel t
ylabel z
grid on
%}
end

