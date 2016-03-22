classdef linearDIst < Environments.EpisodicContextualParameterLearningTask
    
    properties
        
        taskDim = 5;
        
    end
    
    
    methods
        
        function obj = linearDIst(episodeSampler)
            
           % obj.linkProperty('taskDim');
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, 1, 1);            
            obj.dataManager.setRange('contexts', ones(1,obj.dimContext) * -20, ones(1,obj.dimContext) * (20));
            obj.dataManager.setRange('parameters', ones(1,obj.dimParameters) * - 150, ones(1,obj.dimParameters) * 150);
            
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            reward = -1*sum((parameters-(5*contexts + 2)).^2 , 2);
            %contextFactor = (1 + cos(contexts) .* 5).^2;
            %reward = sum(bsxfun(@times,rewardTerm,contextFactor),2);
            
        end
        
    end
    
end