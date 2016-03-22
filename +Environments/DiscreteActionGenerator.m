classdef DiscreteActionGenerator < FeatureGenerators.FeatureGenerator
    %DISCRETEACTIONWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
        discreteActionBuckets;
        minValue;
        stepValue;
    end
    
    methods
        
        function obj = DiscreteActionGenerator(dataManager, environment)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,'actions','Discrete',':',dataManager.getNumDimensions('actions'));
            
            obj.linkProperty('discreteActionBuckets');
            
            if isempty(obj.discreteActionBuckets)
             obj.discreteActionBuckets = ones(dataManager.getNumDimensions('actions'))*10;
            end
            
            obj.minValue = obj.dataManager.getMinRange('actions');
            obj.stepValue = (obj.dataManager.getMaxRange('actions')-obj.dataManager.getMinRange('actions'))./(obj.discreteActionBuckets-1);
            
            obj.dataManager.setRange(obj.outputName, obj.dataManager.getMinRange('actions'), obj.dataManager.getMaxRange('actions'));
            obj.dataManager.setRange('actions', ones(dataManager.getNumDimensions('actions')), obj.discreteActionBuckets);
            
            manipulatorNames = environment.getDataManipulationFunctions();
            manipulators = environment.getDataManipulationFunctionsStruct();
            
            for k = 1:length(manipulatorNames)
                name = manipulatorNames{k};
                manipulator = manipulators.(name);
                idx = find(ismember(manipulator.inputArguments,'actions'));
                if ~isempty(idx)
                    newInput = manipulator.inputArguments;
                    newInput{idx} = obj.outputName;
                    environment.setInputArguments(name,newInput);
                end
            end
            
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = (inputMatrix-1)*obj.stepValue+obj.minValue;
        end
    end
    
end

