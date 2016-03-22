classdef SinDistReward < Environments.EpisodicContextualParameterLearningTask
    
    properties
        
        taskDim = 5;
        
    end
    
    
    methods
        
        function obj = SinDistReward(episodeSampler)
            
           % obj.linkProperty('taskDim');
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, 3, 3);            
            obj.dataManager.setRange('contexts', ones(1,obj.dimContext) * 0, ones(1,obj.dimContext) * (2*pi));
            obj.dataManager.setRange('parameters', ones(1,obj.dimParameters) * - 5, ones(1,obj.dimParameters) * 5);
            
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            rewardTerm = -((parameters-sin(contexts)).^2);
            contextFactor = (1 + cos(contexts) .* 5).^2;
            reward = sum(bsxfun(@times,rewardTerm,contextFactor),2);
            
        end
        
    end
    
end