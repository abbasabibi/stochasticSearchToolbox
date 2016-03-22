classdef ObservationPointsPreprocessorConfigurator < Experiments.Configurator
    %WINDOWPREPROCESSORCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = ObservationPointsPreprocessorConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('observationPointsPreprocessorName', 'observationPointsPreprocessor');
            trial.setprop('obsPoints');
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial); 
            
            trial.setprop('observationPointsPreprocessor',DataPreprocessors.ObservationPointsPreprocessor(trial.dataManager,trial.observationPointsPreprocessorName));
            
            trial.preprocessors = {trial.preprocessors{:} trial.observationPointsPreprocessor};
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.observationPointsPreprocessor);
            
        end
    end
    
end

