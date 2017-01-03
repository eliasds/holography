function [] = assertNotNan( obj )
%ASSERTNAN Asserts that an object is not nan. Throws an error if this is
%not the case.

if isnan(obj)
    error('object is nan.');
end

end

