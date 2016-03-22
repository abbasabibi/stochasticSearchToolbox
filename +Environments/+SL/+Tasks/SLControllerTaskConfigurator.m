classdef SLControllerTaskConfigurator < Environments.SL.Tasks.SLTask
    
    properties        
    end
    
    methods
        function obj = SLControllerTaskConfigurator(taskName)
            obj = obj@Environments.SL.Tasks.SLTask(taskName);
        end
        
        function preConfigureTrial(obj, trial)

            obj.preConfigureTrial@Environments.SL.Tasks.SLTask(trial);
            Common.Settings().setProperty('numTimeSteps', 1000);
            trial.setprop('SLenvironment', @Environments.SL.SLControllerEnvironment);            
        end
        
    end
end


