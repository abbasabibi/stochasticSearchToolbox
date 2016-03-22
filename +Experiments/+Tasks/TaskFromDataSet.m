classdef TaskFromDataSet < Experiments.ConfiguredTask
    
    properties
        fileName
        fileNameTest;
    end
    
    methods
        function obj = TaskFromDataSet(taskName, fileName)
            obj = obj@Experiments.ConfiguredTask(taskName, Experiments.LearnerType.TypeA);
            obj.fileName = fileName;

        end

        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredTask(trial);
            
            trial.setprop('inputName');
            trial.setprop('outputName');
            trial.setprop('outputIdx',':');

            trial.setprop('processedInputs', 'inputs');
            trial.setprop('processedOutputs', 'outputs');           

            trial.setprop('sampler');
            trial.setprop('dataManager');
            
            trial.setprop('fileNameTest');
        end

        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredTask(trial);
            
            Common.Settings().setProperty('numIterations', trial.numIterations);
            
        end
        
        function [fileName] = getFileName(obj, trial)
            fileName = obj.fileName;
        end
                       
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Sampler.SamplerFromFile(trial.dataManager, obj.getFileName(trial));
            
            trial.dataManager = trial.sampler.getEpisodeDataManager();            
            trial.dataManager.addDataAlias('inputs', trial.inputName);
            trial.dataManager.addDataAlias('outputs', trial.outputName, trial.outputIdx);
            
            trial.dataManager.finalizeDataManager();
            
        end
        
        function registerSamplers(obj, trial)
            
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            
        end                
    end
    
end


