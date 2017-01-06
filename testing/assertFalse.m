function [] = assertFalse( obj )
%ASSERTFALSE Asserts that obj is false. If not false, throws an error.

if obj
    error('statement is not false.');
end

end

