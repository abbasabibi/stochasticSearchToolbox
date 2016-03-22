classdef TabularInputOutputDistributionLearner < Learner.SupervisedLearner.SupervisedLearner
    
    
    properties (SetObservable,AbortSet)
        
    end
    
    % Class methods
    methods
        function obj = TabularInputOutputDistributionLearner(dataManager, constantDistribution, useDesiredProbs, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, constantDistribution, varargin{:});
        end
                
        function [] = learnFunction(obj, inputData, outputData, weighting) %inputData = features, outputData = desiredProbs,
            
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
 
            oldItemProb = obj.functionApproximator.getItemProb();  
                        
            probabilities = obj.functionApproximator.itemProb;
            pSize = size(probabilities);
            for i = 1 : pSize(1)
                for j = 1 : pSize(2)
                    idx = find(inputData(:,i)==1 & outputData==j);
                    if numel(idx)==0
                        probabilities(i,j) = oldItemProb(i,j);
                    else
                        probabilities(i,j) = sum(weighting(idx));
                    end
                end
            end
            sumIdx = find(sum(probabilities,2)==0);
            probabilities(sumIdx,:) = ones(size(sumIdx,1),size(probabilities,2));
            
            probabilities = bsxfun(@rdivide,probabilities, sum(probabilities,2));

            obj.functionApproximator.setItemProb(probabilities);            
        end
    end
    
end


%%

