function [filesort, numfiles] = filesortstruct( filename, varargin )
%filesortstruct.m Creates a directory list with fileparts
%   Creates a directory list with extra fields for fileparts

dirflag = false;

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'DIR'
            dirflag = true;
            varargin(1) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])

    end
end

filesort = dir(filename);

if dirflag == true || strcmpi(filename,'DIR')
    isdirlog = ~[filesort.isdir];
    filesort(isdirlog) = [];
    isdot = logical(strcmp('.',{filesort.name}) + strcmp('..',{filesort.name}));
    filesort(isdot) = [];
    numfiles = numel(filesort);
else
    numfiles = numel(filesort);
    for L = 1:numfiles
        [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
            fileparts([filesort(L).name]);
    end
end

end

