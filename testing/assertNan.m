function [] = assertNan( obj )
%ASSERTNAN Asserts that an object is nan. Throws an error if this is
%not the case.

if ~isnan(obj)
    error('object is not nan.');
end

end

