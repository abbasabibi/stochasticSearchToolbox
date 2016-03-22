classdef SinDistQuadraticBanditTask < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        
        function obj = SinDistQuadraticBanditTask()
            
            obj = obj@Experiments.Tasks.BanditTask('SinDistQuadraticBandit');
        
        end
        
        function preConfigureTrial(obj, trial)
            
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            
            trial.setprop('dimContext', 1);
            trial.setprop('dimParameters', 1);
            trial.setprop('kernel', 1);
            
        end
        
        function setupEnvironment(obj, trial)
                                 
            trial.returnSampler =  Environments.BanditEnvironments.SinDistReward(trial.sampler);
            trial.contextSampler = Sampler.InitialSampler.InitialDuplicatorContextSampler(trial.sampler);
            
        end
        
    end
end


