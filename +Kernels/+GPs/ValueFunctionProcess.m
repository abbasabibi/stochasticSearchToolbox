
classdef ValueFunctionProcess < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function & Kernels.SLKernelReferenceSet & Learner.ParameterOptimization.HyperParameterObject
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    
    properties (SetObservable, AbortSet)

        discountFactor = 0.98;        
        fixedPointRegularizationFactor = 10^-8;  
        priorMean = 0;
        
    end
    
    properties
           
        cholL
        H3
        
        alpha
        aplhaNext
        
    end    
                   
    
    properties(Access=protected)
        referenceSetNext = [];
        referenceSetNextIndices;  

        nextInputDataEntryReferenceSet
        nextValidityDataEntry
        referenceSetNextIndicator
        parentReferenceSetNextIndicator
    
    end
    
    methods
        function obj = ValueFunctionProcess(dataManager, valueKernel, varOut, varIn, dimIndicesOut)
            
            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, varOut, varIn, 'ValueFunctionProcess');
            obj = obj@Kernels.SLKernelReferenceSet(dataManager, valueKernel, varIn, varOut);
                        
            obj.registerMappingInterfaceDistribution();
            
            obj.linkProperty('discountFactor');
            obj.linkProperty('fixedPointRegularizationFactor');
            obj.linkProperty('priorMean', 'ValueFunctionProcessPriorMean');
                        
            
        end
        
        function [] = setHyperParameters(obj, hyperParameters)
            numParamsKernel = obj.kernel.getNumHyperParameters();
            obj.kernel.setHyperParameters(hyperParameters(1:numParamsKernel));
            obj.fixedPointRegularizationFactor = hyperParameters(numParamsKernel + 1);
            obj.priorMean = hyperParameters(numParamsKernel + 2);
            
        end
        
        function [hyperParameters] = getHyperParameters(obj)
            hyperParameters = [obj.kernel.getHyperParameters(), obj.fixedPointRegularizationFactor, obj.priorMean];
        end
        
        function [numParameters] = getNumHyperParameters(obj)
            numParameters = obj.kernel.getNumHyperParameters() + 2;
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = [obj.kernel.getExpParameterTransformMap(), true, false];
        end
        
        
        %===
        function [] = setReferenceSetNext(obj, nextStateReferenceSet)            
            obj.referenceSetNext = nextStateReferenceSet;

        end
        
        function [referenceSet] = getReferenceSetNext(obj)
            referenceSet = obj.referenceSetNext;
        end
        
        function [tag] = getKernelReferenceSetTagNext(obj)
            tag = obj.nextKernelReferenceTag;
        end
        

        function [K] = getKernelMatrixNext(obj)                       
            K = obj.kernel.getGramMatrix(obj.getReferenceSetNext(), obj.getReferenceSetNext());
        end
        
        function [K] = getKernelVectorsNext(obj, sampleMatrix)
            K = obj.kernel.getGramMatrix(obj.getReferenceSetNext(), sampleMatrix);
        end 
        
        function [referenceSetIndices] = getReferenceSetIndicesNext(obj)
            referenceSetIndices = obj.referenceSetNextIndices;
        end
        
        function [referenceSetSize] = getReferenceSetSizeNext(obj)
            if islogical(obj.referenceSetNextIndices)
                referenceSetSize = sum(obj.referenceSetNextIndices);
            else
                referenceSetSize = length(obj.referenceSetNextIndices);
            end
        end
        %====
        
        
        function [] = setVFPModel(obj, L, H3, reward)
            
            obj.H3 = H3;
            obj.cholY = chol(L);
            
            obj.alpha = obj.cholY\(obj.cholY'\reward);
            obj.alphaNext = - obj.discountFactor * H3' * obj.alpha;

        end       
                
        function [meanGP] = getExpectation(obj, numElements, inputData)
            meanGP = obj.getExpectationAndSigmaFunction(numElements, inputData);
        end
        
        function [meanGP, sigmaGP] = getExpectationAndSigma(obj, ~, inputData)
            sigma2 = zeros(size(inputData, 1), 1);
            if (~isempty(obj.alpha))
                kVec = obj.getKernelVectors(inputData)';
                kVecNext = obj.getKernelVectorsNext(inputData)';
                
                meanGP = kVec * obj.alpha + kVecNext * obj.alphaNext;
                
                if (nargout > 1)       
                    F = kVec - obj.discountFactor * obj.H3; 
                    temp = obj.cholL' \ F';
                    temp = bsxfun(@times, temp', temp'); 
                    sigma2 = sum(temp,2);
                end
            else
                meanGP = zeros(size(inputData,1), length(obj.dimIndicesOut));
            end
            if (nargout > 1)
                kernelSelf = obj.fixedPointRegularizationFactor * obj.kernel.getGramDiag(inputData);
                sigma2 = kernelSelf - obj.fixedPointRegularizationFactor * sigma2;
                sigma2(sigma2 < 0) = 0;
                sigmaGP = sigma2;
            end
            
            meanGP = meanGP + obj.priorMean;
        end
                       
                
    end
end

