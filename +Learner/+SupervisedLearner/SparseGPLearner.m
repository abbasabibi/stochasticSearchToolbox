classdef SparseGPLearner < Learner.SupervisedLearner.GPLearner
    % The LinearFeatureFunctionMLLearner is a Learner.SupervisedLearner.SupervisedLearner
    % that will model a learner via weighted linear regression
    properties(SetObservable, AbortSet)     
      
        SparseGPInducingOutputRegularization = 10^-6;
    end
    
    
    
  
    % Class methods
    methods
        function obj = SparseGPLearner(dataManager, gaussianProcess, varargin)
            obj = obj@Learner.SupervisedLearner.GPLearner(dataManager, gaussianProcess, varargin{:});
            
            outputVariable = gaussianProcess.outputVariable;
            obj.linkProperty('SparseGPInducingOutputRegularization', ['SparseGPInducingOutputRegularization', upper(outputVariable(1)), outputVariable(2:end)]);
%            obj.unlinkProperty(['SparseGPInducingOutputRegularization', upper(outputVariable(1)), outputVariable(2:end)]);
            
            obj.learnWithReferenceSet = false;
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
            % @param inputData input data of the training set
            % @param outputData output data of the training set
            % @param weighting weighting for each datapoint
            GP = obj.functionApproximator;
            
            if obj.learnWithMean
                meanOutput = mean(outputData);
                outputData = outputData - meanOutput;
            else
                outputData = outputData - GP.priorMean;
            end
            
            K = GP.GPPriorVariance * GP.getKernelMatrix();
                                               
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
             % Check for NaNs and remove
            index = not(any(isnan(inputData),2));
            inputData = inputData(index,:);
            outputData = outputData(index,:);
            weighting = weighting(index,:);
            
            weighting = weighting / max(weighting);                          
            GPRegularizerEffective = GP.GPRegularizer;
            counter = 1;
            while true                
                Ky = K + eye(size(K)) * GPRegularizerEffective;
                try
                    cholKy = chol(Ky);
                    break;
                catch
                    GPRegularizerEffective = GPRegularizerEffective * 2;
                end
                counter = counter + 1;
                assert(counter < 100);
            end
            
            kernelVectors = GP.GPPriorVariance * GP.getKernelVectors(inputData)';
            featureVectors = (kernelVectors / cholKy) / cholKy';
            featureVectorsW = bsxfun(@times, featureVectors, weighting);
            y = (featureVectorsW'*featureVectors + eye(size(featureVectors,2)) * obj.SparseGPInducingOutputRegularization) \ featureVectorsW' * outputData(:, GP.getDimIndicesForOutput());
            
            alpha = cholKy \ (cholKy' \ y);
                       
            if obj.learnWithMean
                GP.setGPModel(alpha, cholKy, meanOutput);
            else
                GP.setGPModel(alpha, cholKy);
            end          
        end
        
        %%% Hyper Parameter Functions
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.getNumHyperParameters@Learner.SupervisedLearner.GPLearner() + 1;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@Learner.SupervisedLearner.GPLearner(params(1:end-1));            
            obj.SparseGPInducingOutputRegularization = params(end);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.getHyperParameters@Learner.SupervisedLearner.GPLearner(), obj.SparseGPInducingOutputRegularization];
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = [obj.getExpParameterTransformMap@Learner.SupervisedLearner.GPLearner(), true];
        end
    end
    
end
