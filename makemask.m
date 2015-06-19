function mask = makemask( size, varargin )
%makemask Summary of this function goes here
%   Detailed explanation goes here

north = (1:size/2);
south = (size/2+1:size);
east = (size/2+1:size);
west = (1:size/2);

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'STRIPES6'
            mask = ones(size);
            mask(:,1:size/6) = 0;
            mask(:,1+2*size/6:3*size/6) = 0;
            mask(:,1+4*size/6:5*size/6) = 0;
            varargin(1) = [];
            
        case 'HALF'
            mask = ones(size);
            mask(:,west) = 0;
            varargin(1) = [];
        
        case 'LEFTHALF'
            mask = ones(size);
            mask(:,west) = 0;
            varargin(1) = [];
            
        case 'RIGHTHALF'
            mask = ones(size);
            mask(:,east) = 0;
            varargin(1) = [];
        
        case 'TOPHALF'
            mask = ones(size);
            mask(north,:) = 0;
            varargin(1) = [];
            
        case 'BOTTOMHALF'
            mask = ones(size);
            mask(south,:) = 0;
            varargin(1) = [];
        
        case 'NEQUAD'
            mask = ones(size);
            mask(north,east) = 0;
            varargin(1) = [];
            
        case 'SEQUAD'
            mask = ones(size);
            mask(south,east) = 0;
            varargin(1) = [];
        
        case 'SWQUAD'
            mask = ones(size);
            mask(south,west) = 0;
            varargin(1) = [];
            
        case 'NWQUAD'
            mask = ones(size);
            mask(north,west) = 0;
            varargin(1) = [];
        
        otherwise
            error(['Unexpected option: ' varargin{1}])
            
    end
end

end

