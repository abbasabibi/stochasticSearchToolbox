classdef LogLinearFunction < Functions.Mapping & Functions.Function
    
    properties
        featureGenerator
        inputName
        outputName
        hasFeatures = false
        weights
        bias = 0
        minValue = 1e-3
    end
    
    methods
        function obj = LogLinearFunction(dataManager,inputname, outputname)

            obj@Functions.Function();
            obj@Functions.Mapping(dataManager);
            obj.registerCostToGoFunction();
            

            obj.inputName = inputname;
            obj.outputName = outputname;
        end
        
        function [] = setFeatureGenerator(obj, featureGenerator)
            obj.setInputVariables(featureGenerator.outputName);
            obj.featureGenerator = featureGenerator;
            obj.hasFeatures = true;
            
        end
        
        function [] = setWeightsAndBias(obj, weights, bias)
            if(~exist('bias','var'))
                bias = 0;
            end
            obj.bias = bias;
            obj.weights = weights;
            
            if (size(obj.weights,2) > 1)
                obj.weights = obj.weights';
            end
        end
        
        function [value] =  getExpectation(obj, numElements, inputFeatures)
            if (nargin == 2 && obj.dimInput > 0)
                assert('getExpectation function called with only 2 arguments, did you forget the numElements?');
            end
            if(isempty(obj.weights))
                value = obj.bias;
            else
                value = repmat(obj.bias', size(inputFeatures,1), 1);
                
                if (nargin == 3 && ~isempty(inputFeatures))
                    value = value + obj.featureGenerator.getExpectation(inputFeatures) * obj.weights;
                end
                minimumValue = obj.minValue;
                if(min(min(value))< 0)
                    value = value - min(min(value)) + minimumValue;  %to prevent imag. numbers...
                end
                value = log(value);
            end
        end
        
        function [deriv] =  getExpectationDerivative(obj, numElements, inputFeatures)
            if(isempty(obj.weights))
                deriv = zeros(size(inputFeatures));
            else
                
                if(obj.hasFeatures)              
                    %inputfeatures: n by d

                    f = obj.featureGenerator.getExpectation(inputFeatures) * obj.weights + obj.bias;
                    % expected features: n by m. Weights m by 1.
                    % f: n-by-1

                    dfeatures = obj.featureGenerator.getDerivative(inputFeatures) ;
                    % derivative features: n by d by m. 

                    g = sum(bsxfun(@times, permute(obj.weights, [2,3,1]), dfeatures),3);
                    % g: n-by-d
                    if(min(min(f))<0)
                        f = f - min(min(f)) + obj.minValue;
                    end
                    deriv = bsxfun(@rdivide, g, f); %take f plus a little bit
                else
                    g = repmat(obj.weights', size(inputFeatures,1), 1);
                    f = inputFeatures * obj.weights + obj.bias;
                    if(min(min(f))<0)
                        f = f - min(min(f)) + obj.minValue;
                    end
                    deriv = bsxfun(@rdivide, g, f);%take f plus a little bit
                end
            end
        end
        
    end
    
    methods (Access = protected)
        function registerCostToGoFunction(obj)
            obj.addDataManipulationFunction('getExpectationDerivative', {obj.inputName}, {obj.outputName});
        end        
    end
    
end