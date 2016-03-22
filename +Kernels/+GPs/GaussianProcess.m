
classdef GaussianProcess < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function & Kernels.SLKernelReferenceSet & Learner.ParameterOptimization.HyperParameterObject
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    
    properties (SetObservable, AbortSet)
        initSigma = true;
       
        GPPriorVariance = 0.1;
        GPRegularizer = 10^-6;

        GPMinVariance = 0;
        
        UseGPBug = false;
    end
    
    properties
           
        dimIndicesOut = 1;
        
        alpha;
        cholKy;
        priorMean = 0;
    end
    
    methods (Static)
        function [obj] = CreateSquaredExponentialGP(dataManager, varOut, varIn, dimIndicesOut)  
            if (iscell(varIn))
                varInName = cell2mat(varIn);
            else
                varInName = varIn;
            end
            localKernel = Kernels.ExponentialQuadraticKernel(dataManager, dataManager.getNumDimensions(varIn), [varInName, 'Kernel', num2str(dimIndicesOut)]);
            obj = Kernels.GPs.GaussianProcess(dataManager, localKernel, varOut, varIn, dimIndicesOut);
        end         
        
        function [obj] = CreateSquaredExponentialPeriodicGP(dataManager, varOut, varIn, dimIndicesOut)            
            if (iscell(varIn))
                varIn = cell2mat(varIn);
            end
            localKernel = Kernels.Kernel.createKernelSQEPeriodic(dataManager, varIn);
            obj = Kernels.GPs.GaussianProcess(dataManager, localKernel, varOut, varIn, dimIndicesOut);
        end            
       
    end
    
    methods
        function obj = GaussianProcess(dataManager, kernel, varOut, varIn, dimIndicesOut)
            
            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, varOut, varIn, 'GaussianProcess');
            obj = obj@Kernels.SLKernelReferenceSet(dataManager, kernel, varIn, varOut);
                        
            obj.registerMappingInterfaceDistribution();
            
            %obj.linkProperty('GPPriorVariance', ['GPPriorVariance', upper(varOut(1)), varOut(2:end)]);
            %obj.linkProperty('GPRegularizer', ['GPRegularizer', upper(varOut(1)), varOut(2:end)]);
            if (nargin >= 1)
                obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                
                obj.linkProperty('GPPriorVariance', ['GPPriorVariance', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
%                obj.unlinkProperty(['GPPriorVariance', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);

                obj.linkProperty('UseGPBug', ['UseGPBug', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                
                obj.linkProperty('GPRegularizer', ['GPRegularizer', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
%                obj.unlinkProperty(['GPRegularizer', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
            
                obj.linkProperty('GPMinVariance', ['GPMinVariance', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);
                
            end
            
            if (dataManager.isDataAlias(varOut))
                if (~exist('dimIndicesOut', 'var'))
                    dimIndicesOut = 1:dataManager.getNumDimensions(varOut);
                end
                obj.dimIndicesOut = dimIndicesOut;                                  

                range = dataManager.getRange(varOut);
                if (numel(obj.dimIndicesOut) == 1)
                    obj.GPPriorVariance = (range(obj.dimIndicesOut) * obj.initSigma).^2;
                else
                    obj.GPPriorVariance = mean((range * obj.initSigma).^2);
                end

            else
                if (~exist('dimIndicesOut', 'var'))
                    dimIndicesOut = 1;
                end
                obj.dimIndicesOut = dimIndicesOut;
            end
        end
        
        function [dimIndices] = getDimIndicesForOutput(obj)
            dimIndices = obj.dimIndicesOut;
        end
        
        function [] = setHyperParameters(obj, hyperParameters)
            obj.kernel.setHyperParameters(hyperParameters(1:end-2));
            obj.GPPriorVariance = hyperParameters(end - 1);
            obj.GPRegularizer = hyperParameters(end);
            assert(~isinf(obj.GPRegularizer) && ~isinf(obj.GPPriorVariance));
        end
        
        function [hyperParameters] = getHyperParameters(obj)
            hyperParameters = [obj.kernel.getHyperParameters(), obj.GPPriorVariance, obj.GPRegularizer];
        end
        
        function [numParameters] = getNumHyperParameters(obj)
            numParameters = obj.kernel.getNumHyperParameters() + 2;
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = [obj.kernel.getExpParameterTransformMap(), true, true];
        end
        
        function [] = setGPModel(obj, alpha, cholKy, priorMean)
            obj.alpha = alpha;
            obj.cholKy = cholKy;
            if nargin > 3
                obj.priorMean = priorMean;
            end
        end       
                
        function [meanGP] = getExpectation(obj, numElements, inputData)
            meanGP = obj.getExpectationAndSigmaFunction(numElements, inputData);
        end
        
        function [meanGP, sigmaGP] = getExpectationAndSigmaFunction(obj, ~, inputData)
            sigma2 = zeros(size(inputData, 1), 1);
            if (~isempty(obj.alpha))
                kVec = obj.GPPriorVariance * obj.getKernelVectors(inputData)';
                meanGP = kVec * obj.alpha;
                
                if (nargout > 1)                   
                    temp = obj.cholKy' \ kVec';
                    temp = bsxfun(@times, temp', temp'); 
                    sigma2 = sum(temp,2);
                end
            else
                meanGP = zeros(size(inputData,1), length(obj.dimIndicesOut));
            end
            if (nargout > 1)
                kernelSelf = obj.GPPriorVariance * obj.kernel.getGramDiag(inputData);
                sigma2 = kernelSelf - sigma2;
                sigma2(sigma2 < 0) = 0;
                sigmaGP = repmat(sqrt(sigma2), 1, numel(obj.dimIndicesOut));                                
            end
            
            meanGP = meanGP + obj.priorMean;
        end
        
        function [meanGP, sigmaGP] = getExpectationAndSigma(obj, numSamples, inputData)
            
            [meanGP, sigmaGP] = obj.getExpectationAndSigmaFunction(numSamples, inputData);
            if (obj.UseGPBug)
                sigmaGP = sigmaGP + sqrt(obj.GPRegularizer);
            else
                sigmaGP = sqrt(sigmaGP.^2 + obj.GPRegularizer);
            end
            sigmaGP(sigmaGP < obj.GPMinVariance) = obj.GPMinVariance;
            %sigmaGP = sigmaGP + sqrt(obj.GPRegularizer);
        end
        
       
                
    end
end

