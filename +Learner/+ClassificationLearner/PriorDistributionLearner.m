classdef PriorDistributionLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties
        logLikelihoodIterations
        useDesiredProbs
    end
    
    properties (SetObservable,AbortSet)
        
    end
    
    % Class methods
    methods
        function obj = PriorDistributionLearner(dataManager, constantDistribution, useDesiredProbs, varargin)
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
            
            numClasses = obj.functionApproximator.numItems;
            
            if (size(outputData, 2) == 1)
                outputData = full(ind2vec(outputData'))';
                if (size(outputData,2) < numClasses)
                    outputData = [outputData, zeros(size(outputData,1),numClasses - size(outputData,2))];
                end
            end
            
            
            weightedDesProb = bsxfun(@times, outputData, weighting);
            prior = sum( weightedDesProb, 1);
            
            prior = prior / sum(prior,2);
            
            %With or without log?
            obj.functionApproximator.setItemProb(prior);
                    
            
        end
    end
    
end


%%

