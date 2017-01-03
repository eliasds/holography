function [] = assertMatrixEquals( expected, actual )
%ASSERTEQUALS Asserts that each entry of expected equals its corresponding
%entry in actual. Throws an error if this is not the case.

if ~isequal(expected, actual)
    error('objects are not equal.');
end


end

