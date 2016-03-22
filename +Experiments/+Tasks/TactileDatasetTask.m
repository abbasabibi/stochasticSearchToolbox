classdef TactileDatasetTask < Experiments.Tasks.TaskFromDataSet
    
    properties
    end
    
    methods
        function obj = TactileDatasetTask()
            obj = obj@Experiments.Tasks.TaskFromDataSet('TactileData', Experiments.LearnerType.TypeA);
            obj.fileName = 'data/Tactile/dataTactile_train_dropped%d.mat';
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.TaskFromDataSet(trial);
            
                        
            trial.setprop('evaluationObservations');
            trial.setprop('evaluationGroundtruth');
            trial.setprop('evaluationValid');
            trial.setprop('evaluationObservationIndex');
            trial.setprop('evaluationMetric','mse');
            
            trial.setprop('inputName', {'pressure', 'electrodes', 'zVelocities'});
            trial.setprop('outputName', 'handVelocities');
            
        end
        
        function [fileName] = getFileName(obj, trial)
            fileName = sprintf(obj.fileName, trial.index);
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('fileNameTest', sprintf('data/Tactile/dataTactile_test_dropped%d.mat', trial.index));
            obj.postConfigureTrial@Experiments.Tasks.TaskFromDataSet(trial);
                        
        end
        
    end
    
end


