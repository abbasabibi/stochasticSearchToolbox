classdef SLBallOnABeamConfigurator < Environments.SL.Tasks.SLControllerTaskConfigurator
    
    properties        
    end
    
    methods
        function obj = SLBallOnABeamConfigurator()
            obj = obj@Environments.SL.Tasks.SLControllerTaskConfigurator('BallOnABeam');
        end
        
        function preConfigureTrial(obj, trial)

            obj.preConfigureTrial@Environments.SL.Tasks.SLControllerTaskConfigurator(trial);
            trial.settings.setProperty('numInitialSamplesEpisodes', 10);
            trial.settings.setProperty('numSamplesEpisodes', 4);
            trial.settings.setProperty('numMaxSamples', 20);
            trial.setprop('SLtask', @Environments.SL.Tasks.SLBallOnABeamTask);
    
        end
        
    end
end


