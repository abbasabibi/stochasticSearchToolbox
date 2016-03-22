classdef TimeIndependentStateActionProbabilities < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %%% time independent probabilities of state-action pairs
    properties
        stateDistrib;
        policy;
        currentTimeStep;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
    end
    
    methods
        function obj = TimeIndependentStateActionProbabilities(trial, probaName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            
            obj.policy = trial.actionPolicy;
            obj.stateDistrib = trial.stateDistribution;
            
            if (~exist('probaName', 'var'))
                probaName = 'timeIndependentSAProba';
            end
            
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            obj.dataManager.addDataEntry([layerName, '.', probaName], 1);
            obj.addDataManipulationFunction('computeProba', {'states', 'actions'}, {probaName});
        end
        
        function [probas] = computeProba(obj, states, actions)
            probas = zeros(size(states, 1), 1);
            for t = 1:obj.numTimeSteps
                currStateDistrib = obj.stateDistrib.getDistributionForTimeStep(t);
                currPolicy = obj.policy.getDistributionForTimeStep(t);
                probas = probas + exp(currStateDistrib.getDataProbabilities([], states) + currPolicy.getDataProbabilities(states, actions));
            end
            probas = probas / obj.numTimeSteps;
        end
        
        function data = preprocessData(obj, data)
            obj.callDataFunction('computeProba', data);
        end
    end
end

