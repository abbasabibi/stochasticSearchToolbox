
classdef SphereReward < Environments.EpisodicContextualParameterLearningTask
    
    properties

        rewardCenter = 0;
        rewardDistance = 0;
        A;
        
    end
    
    properties (SetObservable, AbortSet)
        rewardNoise = 0;
        rewardNoiseMult = 0;
    end
    
    methods
        function obj = SphereReward(episodeSampler, dimContext, dimParameters)
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters);
           
            
         obj.dataManager.setRange('contexts', ones(1, dimContext) * 0, ones(1, dimContext) *3);

            obj.dataManager.setRange('parameters', ones(1, dimParameters) * -5, ones(1, dimParameters) *5);   
            
            obj.A = randn(dimContext,dimParameters) +3*ones(dimContext , dimParameters);  
            
            obj.linkProperty('rewardNoise');
    
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            sample = [contexts, parameters];
              for(i=1:size(parameters,1))
                
                parameters(i,:) = parameters(i,:) + contexts(i,:)*obj.A ; 
                
              end
              sample = [parameters];
            reward =sum(sample.^2,2);
            reward = -1.*reward;
            
        end
        
    end
    
end

