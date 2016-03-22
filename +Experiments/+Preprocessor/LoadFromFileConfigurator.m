classdef LoadFromFileConfigurator < Experiments.Configurator
    
    properties
        demonstrationFile
    end
    
    methods
        function obj = LoadFromFileConfigurator(demonstrationFile)
            obj = obj@Experiments.Configurator('InitialImitation');
            if (exist('demonstrationFile', 'var'))
                obj.demonstrationFile = demonstrationFile;
            else
                obj.demonstrationFile = [];
            end
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            if (isempty(obj.demonstrationFile))
                if (~isprop('demonstrationFile', trial) || isempty(trial.demonstrationFile))
                else
                    trial.setprop('initialDataFileName', trial.demonstrationFile);
                end
            else
                trial.setprop('initialDataFileName', obj.demonstrationFile);
            end
        end
        
%         
%         function [] = registerSamplers(obj, trial)           
%             register(Sampler.SamplerFromFile(trial.initialDataFileName));
%         end
        
        function [] = setupScenarioForLearners(obj, trial)
                  
          
            
            
            trial.scenario.addInitialDataPreprocessor(Sampler.SamplerFromFile(trial.dataManager, trial.initialDataFileName) );
                        
%             obj.setupScenarioForLearners@Experiments.ConfiguredLearner(trial);
            
        end
           
      
    end
    
end
