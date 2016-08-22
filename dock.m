%% Set figure windows to dock/undock by default

function dock(var)

if nargin < 1
    set(0,'DefaultFigureWindowStyle','docked')
elseif strcmp(var,'undock')
    set(0,'DefaultFigureWindowStyle','normal')
else
    set(0,'DefaultFigureWindowStyle','docked')
end