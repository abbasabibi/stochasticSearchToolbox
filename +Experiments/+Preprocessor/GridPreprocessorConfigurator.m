classdef GridPreprocessorConfigurator  < Experiments.Configurator
    % GridPreprocessorConfigurator
    properties
        
    end
    
    methods
        function obj = GridPreprocessorConfigurator(featureName)
            obj = obj@Experiments.Configurator(featureName);
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('gridSize', 10);
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial); 
            %sdm =trial.dataManager.getDataManagerForName('steps');
            
            if(size(trial.gridSize) == [1,1])
                trial.gridSize = trial.gridSize * ones (1,trial.dataManager.getNumDimensions('states')+trial.dataManager.getNumDimensions('actions'))
            end
            
            gridSampler = Sampler.StateActionGridSampler(trial.dataManager, trial.gridSize);
            
            trial.setprop('gridProcessor',DataPreprocessors.GenerateGridPreprocessor(trial.dataManager, trial.sampler, gridSampler ));
                
            
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.gridProcessor, true);
            trial.scenario.addInitObject(trial.gridProcessor);
            
        end
    end    
end
