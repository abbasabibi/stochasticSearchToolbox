classdef StandardOptimisationFunctions < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = StandardOptimisationFunctions()
            obj = obj@Experiments.Tasks.BanditTask('StandardOptimisationTask');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            
            trial.setprop('dimContext', 0);
            trial.setprop('dimParameters', 20);
            trial.setprop('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);
           
            
        end
        
        function setupEnvironment(obj, trial)     
            %trial.contextSampler =  Environments.BanditEnvironments.SquaredReward(trial.sampler, trial.dimContext, trial.dimParameters, rewardCenter, rewardDistance);
            %trial.standardRewardFunction = Environments.BanditEnvironments.SphereReward(trial.sampler, trial.dimContext, trial.dimParameters);
            trial.contextSampler = trial.standardRewardFunction(trial.sampler, trial.dimContext, trial.dimParameters);
            trial.returnSampler = trial.contextSampler;
        end
        
    end
end


