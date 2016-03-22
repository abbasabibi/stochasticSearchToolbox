classdef ConfiguredTask < Experiments.Configurator;
    
    properties(SetAccess = protected)
        acceptedLearnerTypes = Experiments.LearnerType.empty();
        
       
    end
    
    methods
        
        function obj = ConfiguredTask(name, acceptedLearnerTypes)
            obj = obj@Experiments.Configurator(name);
            obj.acceptedLearnerTypes = acceptedLearnerTypes;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            Common.SettingsManager.activateDebugMode();
            trial.setprop('sampler', [], false);
            trial.setprop('dataManager', [], false);
            trial.setprop('scenario', [], false);
        end
        
        function [] = addDefaultCriteria(obj, trial, criteria)
            
        end
        
        function tf = isCompatibleLearner(obj, learner)
            tf = any(ismember(obj.acceptedLearnerTypes, learner.type,'R2012a'));
        end
    end
    
    
end

