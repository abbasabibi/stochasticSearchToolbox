classdef ImportanceSamplingLastKPreprocessor  < Experiments.Configurator
    % 
  
    
    methods
        function obj = ImportanceSamplingLastKPreprocessor()
            obj = obj@Experiments.Configurator('ImportanceSamplingPreProc');
    
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
        
            trial.setprop('importancePreprocessor', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);
            

        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial); 
            
            trial.importancePreprocessor = trial.importancePreprocessor(trial);
            
        end
           
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.importancePreprocessor, true);
            trial.scenario.addInitObject(trial.importancePreprocessor);            
        end
    end    
end
