classdef MedianBandwidthSelectorAndGPVariance < Kernels.Learner.MedianBandwidthSelector & Learner.AbstractInputOutputLearnerInterface
    %sets the bandwidth to a certain constant * the median of the distances
    properties
        gp                  
        gpLearner
    end
    
    properties(SetObservable,AbortSet)
        GPVarianceFunctionFactor = 1.0;
        GPVarianceNoiseFactor = 0.001;
        
        GPRecomputeNoiseVariance = true;
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.MedianBandwidthSelectorAndGPVariance(trial.dataManager, trial.(gpName));
        end
        
        function [kernelLearner] = CreateWithStandardReferenceSet(dataManager, GP)
            referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
            kernelLearner = Kernels.Learner.MedianBandwidthSelectorAndGPVariance(dataManager, GP, referenceSetLearner);
            %kernelLearner.setWeightName('sampleWeights');
        end
    end
    
    
    methods
        function obj = MedianBandwidthSelectorAndGPVariance(dataManager, gp, gpReferenceSetLearner, gpLearner)
            obj = obj@Kernels.Learner.MedianBandwidthSelector(dataManager, gp.kernel, gpReferenceSetLearner, gp);
            obj = obj@Learner.AbstractInputOutputLearnerInterface(dataManager, gp);
            obj.gp = gp;
            
            if (~exist('gpLearner', 'var'))
                obj.gpLearner =  Kernels.Learner.GPHyperParameterLearner.createGPLearner(dataManager, gp);
            else
                obj.gpLearner = gpLearner;
            end
            
            obj.linkProperty('GPVarianceFunctionFactor', ['GPVarianceFunctionFactor', upper(gp.outputVariable(1)), gp.outputVariable(2:end)]);
            obj.linkProperty('GPVarianceNoiseFactor', ['GPVarianceNoiseFactor', upper(gp.outputVariable(1)), gp.outputVariable(2:end)]);
        end
        
        function [] = setWeightName(obj, weightName)
            
            obj.gpLearner.setWeightName(weightName);
            obj.setWeightName@Learner.AbstractInputOutputLearnerInterface(weightName);
            obj.setWeightName@Kernels.Learner.MedianBandwidthSelector(weightName);
        end
        
        function [] = setInputVariablesForLearner(obj, varargin)
            obj.setInputVariablesForLearner@Learner.AbstractInputOutputLearnerInterface(varargin{:});
            
            obj.gpLearner.setInputVariablesForLearner(varargin{:});
        end
        
        function [] = setOutputVariableForLearner(obj, outputVariable)
            obj.setOutputVariableForLearner@Learner.AbstractInputOutputLearnerInterface(outputVariable);           
            
            obj.gpLearner.setOutputVariableForLearner(outputVariable);
        end
              
        
        function [] = updateModel(obj, data)
            obj.updateModel@Kernels.Learner.MedianBandwidthSelector(data);
            
            outputData = obj.gp.getReferenceSetOutputs();
                        
            range = obj.dataManager.getRange(obj.outputVariable);
            range = range(obj.gp.getDimIndicesForOutput()).^2;

            % Compute error^2 and set it as initial guess for variance
            inputData = data.getDataEntry(obj.gp.inputDataEntryReferenceSet);
            outputData = data.getDataEntry(obj.gpLearner.outputVariable);

            outputVar = max(var(outputData(:)), 10^-8);
            
            obj.gp.GPPriorVariance = mean(obj.GPVarianceFunctionFactor * outputVar);
            obj.gp.GPRegularizer = mean(obj.GPVarianceNoiseFactor * outputVar);
            
            obj.gpLearner.updateModel(data);
                        
            
            if (~isempty(obj.gp.weightName))
                weighting = data.getDataEntry(obj.gp.weightName);            
            else
                weighting = ones(size(inputData,1),1);                            
            end
            
            validId = not(any(isnan(inputData),2));
            inputData = inputData(validId, :);
            outputData = outputData (validId, :);
            weighting = weighting(validId, :);

            weighting = weighting / max(weighting);
            
            
            predOutputData = obj.gp.getExpectation(size(inputData,1), inputData);
            
            weighting = weighting / sum(weighting);            
            biasTerm = ( sum(weighting)^2 - sum(weighting.^2));
            
            outputData2 = outputData(:,obj.gp.getDimIndicesForOutput());
            % we need the mean in case the GP is over multiple dimension
            outputVar = mean(sum(bsxfun(@times, (outputData2 - predOutputData).^2, weighting))) / biasTerm;
            
            obj.gp.GPRegularizer  = outputVar;
            
            obj.gpLearner.learnFunction(inputData, outputData, weighting);
            
            
        end
    end       
end

