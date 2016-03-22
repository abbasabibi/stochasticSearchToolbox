classdef SLBallBouncingConfigurator < Environments.SL.Tasks.SLTask
    
    properties        
    end
    
    methods
        function obj = SLBallBouncingConfigurator()
            obj = obj@Environments.SL.Tasks.SLTask('BallBouncing');
        end
        
        function preConfigureTrial(obj, trial)

            obj.preConfigureTrial@Environments.SL.Tasks.SLTask(trial);
            trial.settings.setProperty('numInitialSamplesEpisodes', 20);
            trial.settings.setProperty('numSamplesEpisodes', 10);
            trial.settings.setProperty('numMaxSamples', 100);
            trial.settings.setProperty('numTimeSteps', 2000);
            trial.settings.setProperty('useTau', true);
            trial.settings.setProperty('useGoalPos', true);                       
            trial.settings.setProperty('useWeights', false);                        

            trial.settings.setProperty('SLtask', @Environments.SL.Tasks.SLBallBouncingTask);
        end
        
        function postConfigureTrial(obj, trial)                        
            obj.postConfigureTrial@Environments.SL.Tasks.SLTask(trial);            
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Environments.SL.Tasks.SLTask(trial, evaluationCriterion);          
        end        
    end
end


