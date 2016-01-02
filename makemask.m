function mask = makemask( resizeVal, varargin )
%makemask creates an image of specified dimentions
%   makemask creates one of the following images which can then be used to
%   mask, or overlay, another image of equal size.
%   'stripes6' %%creates 6 vertical stripes
%   'knife' %%(same as 'half' or 'lefthalf') creates a knife edge
%   'righthalf' %%creates a knife edge
%   'tophalf' %%creates a knife edge
%   'bottomhalf' %%creates a knife edge
%   'NEquad' %%creates a knife edge
%   'SEquad' %%creates a knife edge in one quadrant
%   'NWquad' %%creates a knife edge in one quadrant
%   'SWquad' %%creates a knife edge in one quadrant
%   'file', 'filename' %%loads a mat file and resizes it
%   'var', varname, %%loads a global variable and resizes it
%   'open' %%no mask is made. Mask value is 1.

north = (1:resizeVal/2);
south = (resizeVal/2+1:resizeVal);
east = (resizeVal/2+1:resizeVal);
west = (1:resizeVal/2);

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'STRIPES6'
            mask = ones(resizeVal);
            mask(:,1:resizeVal/6) = 0;
            mask(:,1+2*resizeVal/6:3*resizeVal/6) = 0;
            mask(:,1+4*resizeVal/6:5*resizeVal/6) = 0;
            varargin(1) = [];
            
        case {'HALF', 'KNIFE', 'LEFTHALF'}
            mask = ones(resizeVal);
            mask(:,west) = 0;
            varargin(1) = [];
            
        case 'RIGHTHALF'
            mask = ones(resizeVal);
            mask(:,east) = 0;
            varargin(1) = [];
        
        case 'TOPHALF'
            mask = ones(resizeVal);
            mask(north,:) = 0;
            varargin(1) = [];
            
        case 'BOTTOMHALF'
            mask = ones(resizeVal);
            mask(south,:) = 0;
            varargin(1) = [];
        
        case 'NEQUAD'
            mask = ones(resizeVal);
            mask(north,east) = 0;
            varargin(1) = [];
            
        case 'SEQUAD'
            mask = ones(resizeVal);
            mask(south,east) = 0;
            varargin(1) = [];
        
        case 'SWQUAD'
            mask = ones(resizeVal);
            mask(south,west) = 0;
            varargin(1) = [];
            
        case 'NWQUAD'
            mask = ones(resizeVal);
            mask(north,west) = 0;
            varargin(1) = [];
            
        case {'FILE', 'SPIRAL'}
            mask = load1(varargin{2});
            mask = imresize(mask,[resizeVal,resizeVal],'nearest','colormap','original');
            varargin(1:2) = [];
            
        case 'VAR'
            mask = imresize(varargin{2},[resizeVal,resizeVal],'nearest','colormap','original');
            varargin(1:2) = [];
            
        case 'OPEN'
            mask = 1;
            varargin(1:2) = [];
        
        otherwise
            error(['Unexpected option: ' varargin{1}])
            
    end
end

mask = round(mask);

end

