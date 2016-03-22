classdef SquaredReward < Environments.EpisodicContextualParameterLearningTask
    
    properties

        rewardCenter = 0;
        rewardDistance = 0;
        
    end
    
    properties (SetObservable, AbortSet)
        rewardNoise = 0;
        rewardNoiseMult = 0;
    end
    
    methods
        function obj = SquaredReward(episodeSampler, dimContext, dimParameters, rewardCenter, rewardDistance)
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters);
           
            obj.rewardCenter    = rewardCenter;
            obj.rewardDistance  = rewardDistance;
            
            obj.dataManager.setRange('contexts', ones(1, dimContext) * - 10, ones(1, dimContext) * 10);
            obj.dataManager.setRange('parameters', ones(1, dimParameters) * - 10, ones(1, dimParameters) * 10);    
            
            obj.linkProperty('rewardNoise');
            obj.linkProperty('rewardNoiseMult');
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            sample = [contexts, parameters];
            sample = sample + randn(size(sample)) * obj.rewardNoise;
            numCenters =size(obj.rewardCenter, 1);
            
            for j = 1 : numCenters
                sample = bsxfun(@minus, sample, obj.rewardCenter(j,:) );
                diff = zeros(size(sample,1), numCenters);
                for i = 1:size(sample,1)
                    diff(i,j) = sample(i,:) * obj.rewardDistance * sample(i,:)';
                end
            end
            
            diff    = min(diff,[],2);            
            reward  = - diff / 2 + randn(size(diff)) * obj.rewardNoiseMult .* (0.1 + diff);                            
            
        end
        
    end
    
end