classdef HuMoDTask < Experiments.Tasks.TaskFromDataSet
    
    properties
    end
    
    methods
        function obj = HuMoDTask(fileName)
            obj = obj@Experiments.Tasks.TaskFromDataSet('HuMoData', Experiments.LearnerType.TypeA);
            obj.fileName = fileName;

        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.TaskFromDataSet(trial);
            
                        
            trial.setprop('evaluationObservations');
            trial.setprop('evaluationGroundtruth');
            trial.setprop('evaluationValid');
            trial.setprop('evaluationObservationIndex');
            trial.setprop('evaluationMetric','mse');
            
            trial.setprop('inputName', {'markerX','markerY','markerZ'});
            trial.setprop('outputName', 'subjectVelocity');

            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Tasks.TaskFromDataSet(trial);
            
            
        end
        
    end
    
end


