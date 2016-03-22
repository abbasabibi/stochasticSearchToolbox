classdef SLBallInACupConfigurator < Environments.SL.Tasks.SLTask
    
    properties        
    end
    
    methods
        function obj = SLBallInACupConfigurator()
            obj = obj@Environments.SL.Tasks.SLTask('BallInACup');
        end
        
        function preConfigureTrial(obj, trial)

            obj.preConfigureTrial@Environments.SL.Tasks.SLTask(trial);
            trial.settings.setProperty('numInitialSamplesEpisodes', 20);
            trial.settings.setProperty('numSamplesEpisodes', 10);
            trial.settings.setProperty('numMaxSamples', 100);
            trial.setprop('SLtask', @Environments.SL.Tasks.SLBallInACupTask);
        end
        
        function postConfigureTrial(obj, trial)                        
            obj.postConfigureTrial@Environments.SL.Tasks.SLTask(trial);            
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Environments.SL.Tasks.SLTask(trial, evaluationCriterion);          
        end        
    end
end


