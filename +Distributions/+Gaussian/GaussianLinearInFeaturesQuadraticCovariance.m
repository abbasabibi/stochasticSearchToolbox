classdef GaussianLinearInFeaturesQuadraticCovariance < Functions.FunctionLinearInFeatures & Distributions.DistributionWithMeanAndVariance & ParametricModels.ParametricModel
    % Result of bayesian linear regression
    
    properties (SetAccess = protected)
        cholA = [] % Matrix in the Cholesky decomposition
        %indexForCov
    end
    
    properties (SetObservable, AbortSet)
        initSigma = 0.1;
        priorVariance=1;
        regularizer= 10^-6;
    end
    
    methods
        
        function obj = GaussianLinearInFeaturesQuadraticCovariance(dataManager, outputVariable, inputVariables, functionName, varargin)
            % @param dataManager Data.DatManager to operate on
            % @param outputVariable set of output Variables of the gaussian function
            % @param inputVariables set of input Variables of the gaussian function
            % @param functionName name of the gaussian function
            % @param varargin optional featureGenerator, doInitWeights (see superclass Functions.FunctionLinearInFeatures)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Functions.FunctionLinearInFeatures(superargs{:});
            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@ParametricModels.ParametricModel();
            
            
            if (nargin >= 1)
                obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                obj.registerMappingInterfaceDistribution();
               
                obj.linkProperty('priorVariance', ['priorVariance', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                obj.unlinkProperty(['priorVariance', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);

                obj.linkProperty('regularizer', ['regularizer', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                obj.unlinkProperty(['regularizer', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
            end
            
            %obj.registerGradientModelFunction();

        end
        
%         function [numParameters] = getNumParameters(obj)
%             numParameters = obj.getNumParameters@Function.LinearInFeatures() + obj.numParameters + obj.dimOutput * (obj.dimOutput + 1) / 2;
%         end
        
        function [] = initObject(obj)
            
            obj.initObject@Functions.FunctionLinearInFeatures();
            obj.bias = 0;
        end
                        
        
        function [mean, sigma] = getExpectationAndSigma(obj, numElements, varargin)
            mean = obj.getExpectation(numElements, varargin{:});
            
            if ~isempty(obj.cholA)
                temp = obj.cholA' \ varargin{1}';
                var = obj.regularizer + sum(temp'.*temp',2);
                sigma = sqrt(var);
            else
                range = obj.dataManager.getRange(obj.outputVariable);
                sigma = diag(range .* obj.initSigma);
            end
        end
        
        function [covariance] = getCovariance(obj)
            % returns covariance matrix
            covariance = obj.cholA' * obj.cholA;
        end
        
        function [bias] = getMean(obj)
            bias = obj.bias;
        end
        
        
        function [] = setCovariance(obj, covMat)
            obj.cholA = chol(covMat);
        end
        
        function [] = setSigma(obj, cholA)
            % expects the squareroot of the Covariance in cholesky form
            obj.cholA = cholA;
        end
        
        function [] = setHyperParameters(obj, hyperParameters)
            setHyperParameters@Functions.FunctionLinearInFeatures(obj,hyperParameters(1:end-2));
            obj.priorVariance = hyperParameters(end - 1);
            obj.regularizer = hyperParameters(end);
        end
        
        function [hyperParameters] = getHyperParameters(obj)
            temp = getHyperParameters@Functions.FunctionLinearInFeatures(obj);
            hyperParameters = [temp, obj.priorVariance, obj.regularizer];
        end
        
        function [numParameters] = getNumHyperParameters(obj)
            temp = getNumHyperParameters@Functions.FunctionLinearInFeatures(obj);
            numParameters = temp + 2;
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            temp = getExpParameterTransformMap@Functions.FunctionLinearInFeatures(obj);
            expParameterTransformMap = logical([temp true true]);
        end
        
        function [gradient] = getLikelihoodGradient(obj, inputMatrix, outputMatrix)
            assert(False, 'not implemented yet')
        end
        
    end
end
