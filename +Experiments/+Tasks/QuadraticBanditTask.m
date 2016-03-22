classdef QuadraticBanditTask < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = QuadraticBanditTask()
            obj = obj@Experiments.Tasks.BanditTask('QuadraticBandit');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            
            trial.setprop('dimContext', 0);
            trial.setprop('dimParameters', 20);
            trial.setprop('dimLowDimManifold', 2);
            
        end
        
        function setupEnvironment(obj, trial)
           
            
            numDimensions = trial.dimParameters + trial.dimContext;
            
            storeSeed = rng;
            rng(1000);
            rewardCenter = randn(1, numDimensions);
            rewardDistance = randn(trial.dimLowDimManifold, numDimensions);
            rewardDistance = rewardDistance' * rewardDistance;
            rng(storeSeed);
            
            trial.contextSampler =  Environments.BanditEnvironments.SquaredReward(trial.sampler, trial.dimContext, trial.dimParameters, rewardCenter, rewardDistance);
            trial.returnSampler = trial.contextSampler;
        end
        
    end
end


