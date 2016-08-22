function [ varargout ] = toc2( unitsin )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

time = toc;

nOutputs = nargout;

if time <= 181
    unitsout = 'seconds';
elseif time > 181 && time < 3600
    time = time / 60;
    unitsout = 'minutes';
elseif time > 3600
    time = time / 60 / 60;
    unitsout = 'hours';
end

disp(['Elapsed time is ',num2str(time),' ',unitsout,'.'])

if nOutputs > 0
    varargout{1} = time;
end

if nOutputs > 1
    varargout{2} = unitsout;
end


end

