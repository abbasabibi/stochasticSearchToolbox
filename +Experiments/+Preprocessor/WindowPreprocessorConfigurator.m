classdef WindowPreprocessorConfigurator < Experiments.Configurator
    %WINDOWPREPROCESSORCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = WindowPreprocessorConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name 'WindowPreprocessorName'], 'windowPreprocessor');
            Common.Settings().setProperty([obj.name '_inputNames'], 'inputs');
            trial.setprop('processedInputs', 'inputsWindows');
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);             
            
            preprocessor = DataPreprocessors.GenerateDataWindowsPreprocessor(trial.dataManager,trial.([obj.name 'WindowPreprocessorName']));
            trial.setprop([obj.name 'WindowPreprocessor'],preprocessor);
            
            
            trial.preprocessors = {trial.preprocessors{:} trial.([obj.name 'WindowPreprocessor'])};
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.([obj.name 'WindowPreprocessor']));
            
        end
    end
    
end

