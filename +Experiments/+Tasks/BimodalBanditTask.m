classdef BimodalBanditTask < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = BimodalBanditTask ()
            obj = obj@Experiments.Tasks.BanditTask('BimodalBanditTask ');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            
            trial.setprop('dimContext', 0);
            trial.setprop('dimParameters', 2);
            trial.setprop('dimLowDimManifold', 2);
            
        end
        
        function setupEnvironment(obj, trial)
           
            
            numDimensions = trial.dimParameters + trial.dimContext;
            
            storeSeed = rng;
            rng(1000);
%             rewardCenter = randn(2, numDimensions);
            rewardCenter = [0 5; 0 -5];
%             rewardDistance = randn(trial.dimLowDimManifold, numDimensions);
            rewardDistance = eye(numDimensions);
            rewardDistance = rewardDistance' * rewardDistance;
            rng(storeSeed);
            
            trial.contextSampler =  Environments.BanditEnvironments.SquaredReward(trial.sampler, trial.dimContext, trial.dimParameters, rewardCenter, rewardDistance);
            trial.returnSampler = trial.contextSampler;
        end
        
    end
end


