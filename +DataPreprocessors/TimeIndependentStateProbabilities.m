classdef TimeIndependentStateProbabilities < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %%% time independent probabilities of states
    properties
        stateDistrib;
        currentTimeStep;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
    end
    
    methods
        function obj = TimeIndependentStateProbabilities(trial, probaName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            
            obj.stateDistrib = trial.stateDistribution;
            
            if (~exist('probaName', 'var'))
                probaName = 'timeIndependentSProba';
            end
            
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            obj.dataManager.addDataEntry([layerName, '.', probaName], 1);
            obj.addDataManipulationFunction('computeProba', {'states'}, {probaName});
        end
        
        function [probas] = computeProba(obj, states)
            probas = zeros(size(states, 1), 1);
            for t = 1:obj.numTimeSteps
                currStateDistrib = obj.stateDistrib.getDistributionForTimeStep(t);
                probas = probas + exp(currStateDistrib.getDataProbabilities([], states));
            end
            probas = probas / obj.numTimeSteps;
        end
        
        function data = preprocessData(obj, data)
            obj.callDataFunction('computeProba', data);
        end
    end
end

