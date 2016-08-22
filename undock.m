%% Set figure windows to dock/undock by default

function undock(var)

if nargin < 1
    set(0,'DefaultFigureWindowStyle','normal')
elseif strcmp(var,'dock')
    set(0,'DefaultFigureWindowStyle','docked')
else
    set(0,'DefaultFigureWindowStyle','normal')
end