classdef SLBallOnABeamConfiguratorByReward < Environments.SL.Tasks.SLTask & Common.IASObject
    
    properties (SetObservable, AbortSet)
        lengthSupraStep;
        nbSupraSteps; 
        usedStates;
        controlledJoints;
    end       
    
    methods
        function obj = SLBallOnABeamConfiguratorByReward()
            obj = obj@Common.IASObject();
            obj = obj@Environments.SL.Tasks.SLTask('BallOnABeamByReward');
            obj.linkProperty('lengthSupraStep');
            obj.linkProperty('nbSupraSteps');
            obj.linkProperty('usedStates');
            obj.linkProperty('controlledJoints');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Environments.SL.Tasks.SLTask(trial);
            trial.settings.setProperty('numInitialSamplesEpisodes', 10);
            trial.settings.setProperty('numSamplesEpisodes', 4);
            trial.settings.setProperty('numMaxSamples', 20);
            trial.setprop('SLtask', @Environments.SL.Tasks.SLBallOnABeamTaskByReward);   
            trial.setprop('SLenvironment', @Environments.SL.SLLinearFeedbackEnvironment);
        end
        
        function setupEnvironment(obj, trial)    
            trial.SLrobot = trial.SLrobot();
            trial.SLenvironment = trial.SLenvironment(trial.dataManager, ...
                trial.SLrobot, obj.usedStates, obj.controlledJoints);    %modified        
            trial.SLtask = trial.SLtask(trial.dataManager, trial.SLrobot);
            trial.SLenvironment.setTask(trial.SLtask);
        end        
    end
end


