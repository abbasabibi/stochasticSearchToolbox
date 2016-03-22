classdef OptimizerFactory < Common.IASObject;
    %OPTIMIZERFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function obj = OptimizerFactory()
            obj = obj@Common.IASObject();
        end
        
    end
    
    methods(Static)
        function optimizer = createOptimizer(numParams, name, lowerBound, upperBound, standardValue)
            
            if (size(lowerBound,1) > 1)
                lowerBound = lowerBound';
            end
            
            if (size(upperBound,1) > 1)
                upperBound = upperBound';
            end
            
            % get global settings
            settings = Common.Settings();
            
            % Set default value
            if (~settings.hasProperty([name,'OptiAlgorithm']))
                if (exist('standardValue', 'var'))
                    settings.setProperty([name,'OptiAlgorithm'], standardValue);
                else
                    settings.setProperty([name,'OptiAlgorithm'],'NLOPT_LD_LBFGS');                    
                end
            end
            
            algorithm = settings.getProperty([name,'OptiAlgorithm']);
            
            switch algorithm
                
                case 'FMinUnc' % Matlab FMinUnc
                    optimizer = Optimizer.FMinUnc(numParams, true, false, name);
                case 'FMinCon' % Matlab FMinCon
                    optimizer = Optimizer.FMinCon(numParams, lowerBound, upperBound, name);
                case 'CMA-ES'
                    optimizer = Optimizer.CMAOptimizer(numParams, lowerBound, upperBound, name);
                otherwise
                    
                    %==== NLopt Local gradient-based optimization =========
                    if (strcmp(algorithm(1:5), 'NLOPT')) % starts with 'NLOPT_LD'
                        optimizer = Optimizer.NLOptOptimizer(numParams, lowerBound, upperBound, name);
                    else
                        error('Optimizer %s not known!!\n', algorithm);
                    end
            end
        end
        
    end
end

