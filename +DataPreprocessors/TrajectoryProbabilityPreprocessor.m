classdef TrajectoryProbabilityPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
    properties
        transitionProbName;
        policyProbName;
        trajectoryProbName;
        
        dynamicalSystem
        layer;
    end
    
    % Class methods
    methods
        function obj = TrajectoryProbabilityPreprocessor(dataManager, dynamicalSystem, layer, transitionProbName, policyProbName, trajectoryProbName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.dynamicalSystem = dynamicalSystem;
            obj.dynamicalSystem.registerControlNoiseInData();
            if (~exist('transitionProbName', 'var'))
                transitionProbName = 'logProbTrans';
            end
            
            if (~exist('policyProbName', 'var'))
                policyProbName = 'logQAs';
            end
            
            if (~exist('trajectoryProbName', 'var'))
                trajectoryProbName = 'logProbTrajectory';
            end
            
            if (~exist('layer', 'var'))
                layer = 'steps';
            end
            
            obj.transitionProbName = transitionProbName;
            obj.policyProbName = policyProbName;            
            obj.trajectoryProbName = trajectoryProbName;
            
            obj.dataManager.addDataEntry('steps.logProbTrans', 1);            
            obj.dataManager.addDataEntry([layer, '.', trajectoryProbName], 1);
            
            obj.layer = obj.dataManager.getDataManagerDepth(layer);
            
            
            obj.addDataManipulationFunction('computeTrajectoryProbabilityPerEpisode', {obj.transitionProbName, obj.policyProbName}, {obj.trajectoryProbName});
            
        end
        
        function [loqProbTrajectory] = computeTrajectoryProbabilityPerEpisode(obj, transitionProb, policyProb)
            if (obj.layer == 1)
                loqProbTrajectory = sum(transitionProb(end:-1:1)) + sum(policyProb(end:-1:1));
            else
                loqProbTrajectory = cumsum(transitionProb(end:-1:1)) + cumsum(policyProb(end:-1:1));
                loqProbTrajectory = loqProbTrajectory(end:-1:1);
            end
        end
        
        function data = preprocessData(obj, data)
            obj.dynamicalSystem.callDataFunction('getTransitionProbabilities', data);
            for i = 1:data.getNumElements()
                obj.callDataFunction('computeTrajectoryProbabilityPerEpisode', data, i, :);
            end
        end
        
    end
end
