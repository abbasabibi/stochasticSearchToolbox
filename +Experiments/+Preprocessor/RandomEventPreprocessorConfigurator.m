classdef RandomEventPreprocessorConfigurator < Experiments.Configurator
    %WINDOWPREPROCESSORCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = RandomEventPreprocessorConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('randomEventPreprocessorName', 'randomEventPreprocessor');
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial); 
            
            trial.setprop('randomEventPreprocessor',DataPreprocessors.RandomEventPreprocessor(trial.dataManager,trial.randomEventPreprocessorName));
            
            trial.preprocessors = {trial.preprocessors{:} trial.randomEventPreprocessor};
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.randomEventPreprocessor);
            trial.scenario.addInitObject(trial.randomEventPreprocessor);
            
        end
    end
    
end

