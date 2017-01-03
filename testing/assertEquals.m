function [] = assertEquals( expected, actual )
%ASSERTEQUALS Asserts two objects equals each other. Throws an error if 
%this is not the case. Uses default == to test for equality. If you would 
%like to compare matrices for entrywise equality, use assertMatrixEquals

if expected ~= actual
    error('Values are not equal.');
end

end

