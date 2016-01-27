function [Imin_w,thresh] = windowing(Imin, num_w)

% Splits input Imin into num_w*num_w windows and process each one
% separately

step = floor(length(Imin) / num_w);
Imin_w = zeros(size(Imin));
thresh = zeros(num_w);

for i = 0:num_w - 1
    
    for j = 0:num_w - 2
        if i == num_w - 1
            section = Imin(i*step+1 : end, j*step+1 :(j+1)*step);
            
            %process section
            section(:) = section(:).*(i+j)/(2*num_w);
            % finish process section
            
            Imin_w(i*step+1:end,j*step+1 :(j+1)*step) = section;
            continue
        end
        
        section = Imin(i*step+1 : (i+1)*step, j*step+1 :(j+1)*step);
        
        %process section
        section(:) = section(:).*(i+j)/(2*num_w);
        %finish process section
        
        Imin_w(i*step+1 : (i+1)*step, j*step+1 :(j+1)*step) = section;
    end
    
    if i == num_w - 1
        section = Imin(i*step+1 : end, (num_w-1)*step+1 : end);
        
        %process section
        section(:) = section(:).*(i+num_w-1)/(2*num_w);
        %finish process section
        
        Imin_w(i*step+1 : end, (num_w-1)*step+1 : end) = section;
        continue
    end
    
    section = Imin(i*step+1 : (i+1)*step, (num_w-1)*step+1 : end);
    
    %process section
    section(:) = section(:).*(i+num_w-1)/(2*num_w);
    %finish process section
    
    Imin_w(i*step+1 : (i+1)*step, (num_w-1)*step+1 : end) = section;
end

imagesc(Imin_w)

end