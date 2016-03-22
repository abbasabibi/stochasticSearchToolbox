
classdef RosenbrockReward < Environments.EpisodicContextualParameterLearningTask
    
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
        function obj = RosenbrockReward(episodeSampler, dimContext, dimParameters)
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters);
           
            
            obj.dataManager.setRange('contexts', ones(1, dimContext) * 0, ones(1, dimContext) *3);

            obj.dataManager.setRange('parameters', ones(1, dimParameters) * -5, ones(1, dimParameters) *5);   
            
            obj.A = randn(dimContext,dimParameters) +3*ones(dimContext , dimParameters);
            
            obj.linkProperty('rewardNoise');
    
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            for(i=1:size(parameters,1))
                
                parameters(i,:) = parameters(i,:) + contexts(i,:)*obj.A ; 
                
            end
            %bsxfun(@times, ones(size(parameters)),contexts);
            
            x = parameters;
            x = x';	
           % reward = 100*sum((x(:,(1:end-1)).^2 - x(:,(2:end))).^2,2) + sum((x(:,1:end-1)-1).^2,2);
            reward = 1e2*sum((x(1:end-1,:).^2 - x(2:end,:)).^2,1) + sum((x(1:end-1,:)-1).^2,1) ;
            %reward = (reward'-contexts).^2;
            
           %reward =sum(sample.^2,2);
            
            
            reward = -1.*(reward');% / 10^5;
            
        end
        
    end
    
end

