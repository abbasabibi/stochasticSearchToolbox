classdef SquaredFunction < Functions.Mapping & Functions.Function
    
    properties (SetAccess = private)
        R;
        r;
        bias;
    end

    methods
        
        
        

        function obj = SquaredFunction(dataManager, outputVariable, inputVariables, functionName) %Why in some functions first it i input and then output but in other functions it is in other way around
            
            superargs = {};
            
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName};
            end
            
         
            
            obj = obj@Functions.Mapping(superargs{:}); %what this class constructor does?
            obj = obj@Functions.Function();
            
            

            obj.registerMappingInterfaceFunction();
            
            
            
        end
        
        
        
        function [R,r,bias] = getParameters(obj)
            
            R = obj.R;
            r = obj.r;
            bias = obj.bias;
    
            
        end
        
         function setParameters(obj,R,r,bias)
            
            obj.R = R;
            obj.r = r;
            obj.bias = bias;
      
        end
        
        function [value] = getExpectation(obj, numElements, inputFeatures)
            
            if (nargin == 2 && obj.dimInput > 0)
                assert('getExpectation function called with only 2 arguments, did you forget the numElements?');
            end
                       
            
            value = diag(inputFeatures*obj.R*inputFeatures') + inputFeatures * obj.r' + repmat(obj.bias,size(inputFeatures,1),1) ;
            
        end
        
        
    end
end
