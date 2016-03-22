classdef NoisePreprocessorConfigurator < Experiments.Configurator
    %NOISEPREPROCESSORCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = NoisePreprocessorConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('noisePreprocessorName', 'noisePreprocessor');
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial); 
            
            trial.setprop('noisePreprocessor',DataPreprocessors.AdditiveGaussianNoisePreprocessor(trial.dataManager,trial.noisePreprocessorName));
            
            trial.preprocessors = {trial.preprocessors{:} trial.noisePreprocessor};
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.noisePreprocessor);
            trial.scenario.addInitObject(trial.noisePreprocessor);
            
        end
    end
    
end

