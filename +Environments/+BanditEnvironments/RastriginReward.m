
classdef RastriginReward < Environments.EpisodicContextualParameterLearningTask
    
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
        function obj = RastriginReward(episodeSampler, dimContext, dimParameters)
            obj = obj@Environments.EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters);
           
            
            obj.dataManager.setRange('contexts', ones(1, dimContext) * 0, ones(1, dimContext) * 3);

            obj.dataManager.setRange('parameters', ones(1, dimParameters) * -20, ones(1, dimParameters) * 20);
            
              
            obj.A = randn(dimContext,dimParameters) + 5*ones(dimContext , dimParameters);
            
            obj.linkProperty('rewardNoise');
    
        end
        
        function [reward] = sampleReturn(obj, contexts, parameters)
            
               for(i=1:size(parameters,1))
                
                parameters(i,:) = parameters(i,:) + contexts(i,:)*obj.A ; 
                
            end
            
            x = [parameters];
            

             [P,N] = size(x);
             scale=10.^((0:N-1)'/(N-1));
             scale=repmat(scale',P,1);
             reward = 10*N + sum((scale.*x).^2 - 10*cos(2*pi.*(scale.*x)),2);
  
            
            
            reward = -1.*reward;
            
        end
        
    end
    
end

