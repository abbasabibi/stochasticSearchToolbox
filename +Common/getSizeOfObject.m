function [sizes, names] = getSizeOfObject(obj, objectsSeen) 
    if (~exist('objectsSeen', 'var'))
        objectsSeen = {obj};
    end
    if (isobject(obj))
        props = properties(obj); 
    else
        props = fieldnames(obj); 
    end
    totSize = 0; 
    names = {};
    sizes = [];
    for ii=1:length(props) 
        currentProperty = getfield(obj, char(props(ii)));                
        names{end + 1} = char(props(ii));
        if (isobject(currentProperty))
            sizeLocal = 0;
            
            if (isa(currentProperty, 'containers.Map'))
                keys = currentProperty.keys;
            else
                keys = 1:numel(currentProperty);
            end
            
            for i = keys
                if (isa(currentProperty, 'containers.Map'))
                    currentProperty_i = currentProperty(i{1});
                else
                    currentProperty_i = currentProperty(i);
                end
                if (isobject(currentProperty_i))
                    if (~any(cellfun(@(x_) x_ == currentProperty_i, objectsSeen)))
                        objectsSeen{end + 1} = currentProperty_i;                
                        [sizesTemp, namesLocal] = Common.getSizeOfObject(currentProperty_i, objectsSeen);
                        sizeLocal = sizeLocal + sum(sizesTemp);
                    end                            
                elseif (isstruct(currentProperty))
                    [sizesTemp, namesLocal] = Common.getSizeOfObject(currentProperty_i, objectsSeen);
                    sizeLocal = sizeLocal + sum(sizesTemp);                    
                else
                    s = whos('currentProperty'); 
                    sizeLocal = sizeLocal + s.bytes;
                end
            end
            sizes(end + 1) = sizeLocal;
            
        elseif (isstruct(currentProperty))
            [sizesTemp, namesLocal] = Common.getSizeOfObject(currentProperty, objectsSeen);
            sizes(end + 1) = sum(sizesTemp);
        else
            s = whos('currentProperty'); 
            sizes(end + 1) = s.bytes;
        end      
        assert(numel(sizes) == numel(names));        
    end
    sizes = sizes * numel(obj);
end   
