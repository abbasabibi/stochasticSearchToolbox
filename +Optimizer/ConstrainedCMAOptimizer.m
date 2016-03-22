classdef ConstrainedCMAOptimizer < Optimizer.CMAOptimizer;
    
    properties
        upperParamLogBounds
        lowerParamLogBounds
    end
    
    properties
        barrierFactor = 1e3;
    end
    
    properties(SetObservable,AbortSet)
        initUpperParamLogBounds
        initLowerParamLogBounds
        initUpperParamLogBoundsIdx = [];
        initLowerParamLogBoundsIdx = [];
    end
    
    methods
        function obj = ConstrainedCMAOptimizer(numParams, lowerBound, upperBound, varargin)
            obj = obj@Optimizer.CMAOptimizer(numParams, lowerBound, upperBound, varargin{:});
            
            obj.upperParamLogBounds =  50 * ones(1,numParams);
            obj.lowerParamLogBounds = -40 * ones(1,numParams);
            
            obj.linkProperty('initUpperParamLogBounds',[obj.optimizationName '_initUpperParamLogBounds']);
            obj.linkProperty('initLowerParamLogBounds',[obj.optimizationName '_initLowerParamLogBounds']);
            
            obj.linkProperty('initUpperParamLogBoundsIdx',[obj.optimizationName '_initUpperParamLogBoundsIdx']);
            obj.linkProperty('initLowerParamLogBoundsIdx',[obj.optimizationName '_initLowerParamLogBoundsIdx']);
            
            if ischar(obj.initUpperParamLogBoundsIdx) && not(strcmp(obj.initUpperParamLogBoundsIdx,':'))
                obj.initUpperParamLogBoundsIdx = eval(strrep(obj.initUpperParamLogBoundsIdx,'end',num2str(numParams)));
            end
            
            if ischar(obj.initLowerParamLogBoundsIdx) && not(strcmp(obj.initLowerParamLogBoundsIdx,':'))
                obj.initLowerParamLogBoundsIdx = eval(strrep(obj.initLowerParamLogBoundsIdx,'end',num2str(numParams)));
            end
            
            obj.upperParamLogBounds(obj.initUpperParamLogBoundsIdx) = obj.initUpperParamLogBounds;
            obj.lowerParamLogBounds(obj.initLowerParamLogBoundsIdx) = obj.initLowerParamLogBounds;
        end
        
        function [muCMA, nextCovMat] = computeNewMeanAndVariance(obj, MuA, SigmaA, rewards, parameters)
            % add cost of a barrier function
            % upper margins
            upper_error = bsxfun(@minus,obj.upperParamLogBounds,parameters);
            upper_value = obj.barrierFactor * 1./exp(obj.barrierFactor * upper_error);
            
            % lower margins
            lower_error = bsxfun(@minus,parameters,obj.lowerParamLogBounds);
            lower_value = obj.barrierFactor * 1./exp(obj.barrierFactor * lower_error);
            
            rewards = rewards + sum(upper_value,2) + sum(lower_value,2);
            
            [muCMA, nextCovMat] = obj.computeNewMeanAndVariance@Optimizer.CMAOptimizer(MuA, SigmaA, rewards, parameters);
        end

% DOES NOT WORK
%         function [parameters] = sampleParameters(obj, numParamSamples, meanParam, covParam)
%             parameters = obj.sampleParameters@Optimizer.CMAOptimizer(numParamSamples, meanParam, covParam);
%             
%             % squash constrained parameters
%             L = repmat(obj.upperParamLogBounds - obj.lowerParamLogBounds,numParamSamples,1);
%             x_0 = bsxfun(@plus,L ./ 2, obj.lowerParamLogBounds);
%             
%             k = 1e-4 * L;
%             centeredParameters = parameters + x_0;
%             
%             parameters = bsxfun(@plus,L ./ (1 + exp(-k .* centeredParameters)), obj.lowerParamLogBounds);
%         end
        
%         function setUpperMeanBounds(obj,upperMeanBounds,idx)
%             if ~exist('idx','var')
%                 idx = 1:length(obj.upperMeanBounds);
%             end
%             
%             obj.upperMeanBounds(idx) = log(upperMeanBounds);
%         end
%         
%         function setLowerMeanBounds(obj,lowerMeanBounds,idx)
%             if ~exist('idx','var')
%                 idx = 1:length(obj.lowerMeanBounds);
%             end
%             
%             obj.lowerMeanBounds(idx) = log(lowerMeanBounds);
%         end
    end
    
    
    
end

