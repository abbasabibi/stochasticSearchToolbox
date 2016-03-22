classdef DiscreteInputOutputDistributionLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        logLikelihoodIterations
        useDesiredProbs
    end
    
    properties (SetObservable,AbortSet)
        
    end
    
    % Class methods
    methods
        function obj = DiscreteInputOutputDistributionLearner(dataManager, constantDistribution, useDesiredProbs, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, constantDistribution, varargin{:});
            
            if (~exist('useDesiredProbs', 'var'))
                useDesiredProbs = false;
            end
            
             if (useDesiredProbs)
                outputLvl   = obj.dataManager.getDataEntryDepth(softMaxApproximator.outputVariable);
                subManager  = obj.dataManager.getDataManagerForDepth(outputLvl);
                outputName  = [constantDistribution.outputVariable, 'DesiredProbs'];
                subManager.addDataEntry( outputName, subManager.getMaxRange(softMaxApproximator.outputVariable) );
            
                obj.setOutputVariableForLearner(outputName)
            end
            
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting) %inputData = features, outputData = desiredProbs, 
            
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            
            weightedDesProb = bsxfun(@times, outputData, weighting);
            
            minRange = obj.dataManager.getMinRange(obj.functionApproximator.inputVariables);
            maxRange = obj.dataManager.getMaxRange(obj.functionApproximator.inputVariables);
            
            probabilities = obj.functionApproximator.itemProbs;
            
            for i = minRange : maxRange
                [~,idx] = find(inputData==i);
                probabilities(i-minRange+1,:) = sum(weightedDesProb(idx,:),1);                                
            end
                        
            probabilities = probabilities / sum(probabilities,2);
            
            %With or without log?
            obj.functionApproximator.setItemProb(probabilities);
                    
            
        end
    end
    
end


%%

