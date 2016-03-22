
classdef NaoBanditTaskHeightChange < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = NaoBanditTaskHeightChange()
            obj = obj@Experiments.Tasks.BanditTask('NaoBandit');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
         
        end
        
        function setupEnvironment(obj, trial)
                                   
            trial.contextSampler =  Environments.NaoWalking.ParallelNaoWalkBanditHeightChange(trial.sampler); %NaoWalkBanditHeightChange(trial.sampler);
            trial.returnSampler = trial.contextSampler;
        end
        
    end
end
