function [] = assertTrue( obj )
%ASSERTTRUE Asserts that the input is true. If false, throws an error.

if ~obj
    error('statement is not true.');
end

end

