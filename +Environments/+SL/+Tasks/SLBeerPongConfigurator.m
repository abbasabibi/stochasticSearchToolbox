classdef SLBeerPongConfigurator < Environments.SL.Tasks.SLTask
    
    properties        
    end
    
    methods
        function obj = SLBeerPongConfigurator()
            obj = obj@Environments.SL.Tasks.SLTask('BeerPong');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Environments.SL.Tasks.SLTask(trial);
            Common.Settings().setProperty('numInitialSamplesEpisodes', 20);
            Common.Settings().setProperty('numSamplesEpisodes', 10);
            Common.Settings().setProperty('numMaxSamples', 100);
            trial.setprop('SLtask', @Environments.SL.Tasks.SLBeerPongTask);
        end      
    end
end
