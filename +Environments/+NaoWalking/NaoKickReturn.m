classdef NaoKickReturn < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = NaoKickReturn()
            obj = obj@Experiments.Tasks.BanditTask('NaoBandit');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
         
        end
        
        function setupEnvironment(obj, trial)
                                   
            trial.contextSampler =  Environments.NaoWalking.NaoKickBandit(trial.sampler);
            trial.returnSampler = trial.contextSampler;
        end
        
    end
end