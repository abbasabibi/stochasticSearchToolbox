
classdef CigarTabReward < Environments.EpisodicContextualParameterLearningTask
    
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
        function obj = CigarTabReward(episodeSampler, dimContext, dimParameters)
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters);
           
            
            obj.dataManager.setRange('contexts', ones(1, dimContext) * 0, ones(1, dimContext) * 1);

            obj.dataManager.setRange('parameters', ones(1, dimParameters) * -20, ones(1, dimParameters) * 20);
            
            
            obj.A = randn(dimContext,dimParameters) + 50*ones(dimContext , dimParameters);
            
            obj.linkProperty('rewardNoise');
    
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
            for(i=1:size(parameters,1))
                
                parameters(i,:) = parameters(i,:) + contexts(i,:)*obj.A ; 
                
            end
            
            x = [parameters];
            
            x = [parameters];
            f = x(:,1).^2 + 1e8*x(:,end).^2 + 1e4*sum(x(:,2:(end-1)).^2,2);
            reward = x(:,1).^2 + 1e6*sum(x(:,2:end).^2,2);%+10*contexts;
            %reward = 100*sum((x(:,(1:end-1)).^2 - x(:,(2:end))).^2,2) + sum((x(:,1:end-1)-1).^2,2);
            %reward =sum(sample.^2,2);
            
            
            reward = -1.*reward/ 1e5;
            
        end
        
    end
    
end

