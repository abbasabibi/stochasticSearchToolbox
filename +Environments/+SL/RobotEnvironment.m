classdef RobotEnvironment < Data.DataManipulator
    
    properties
        dimJoints;
        
        additionalInputVariables = {};
        additionalOutputVariables = {};
        
        validLastEpisode;
        
        robotTask;
        
        usedStates;
        controlledJoints;
        dimState;
        dimControl;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps = 2000;
    end
    
    methods
        function obj = RobotEnvironment(dataManager, dimJoints, usedStates, controlledJoints)
            % usedStates and controlledJoints are binary vectors defining
            % i) which of the joints and external states are part of the 'states'
            % and 'nextStates' of the learning algorithm and ii) which of 
            % the joints are controlled by the algorithm. The ordering for
            % usedStates is: [bias, joints pos, joints vel, external states].
            
            obj = obj@Data.DataManipulator(dataManager);
            obj.dimJoints = dimJoints;
          
            %%% entry for the state
            if(exist('usedStates','var') && ~isempty(usedStates)) % usedStates is defined
                obj.usedStates = usedStates;
                obj.dimState = sum(usedStates) - usedStates(1); % usedStates(1) is for bias, we won't store it
                obj.dataManager.addDataEntry('steps.states', obj.dimState);
                obj.dataManager.addDataEntry('steps.nextStates', obj.dimState);
                subDataManager = obj.dataManager.getSubDataManager();
                subDataManager.addDataAlias('jointPositions', 'states', find(usedStates(2:dimJoints+1)));
                subDataManager.addDataAlias('jointVelocities', 'states', find(usedStates(dimJoints+2:2*dimJoints+1)));
            else
                obj.dimState = dimJoints * 2;
                obj.dataManager.addDataEntry('steps.states', obj.dimState);
                obj.dataManager.addDataEntry('steps.nextStates', obj.dimState);
                subDataManager = obj.dataManager.getSubDataManager();
                subDataManager.addDataAlias('jointPositions', 'states', 1:2:2*dimJoints);
                subDataManager.addDataAlias('jointVelocities', 'states', 2:2:2*dimJoints);
            end

            %%% entry for the control
            if(exist('controlledJoints','var') && ~isempty(controlledJoints)) % controlledJoints is defined
                obj.controlledJoints = controlledJoints;
                obj.dimControl = sum(controlledJoints);
            else
                obj.dimControl = dimJoints;
            end
            obj.dataManager.addDataEntry('steps.actions', obj.dimControl);

            
            obj.dataManager.addDataEntry('robotContexts', 10);            
            obj.linkProperty('numTimeSteps');            
            obj.registerEpisodeSamplingFunctions();
        end
        
        function [] = setTask(obj, task)
            obj.robotTask = task;
            obj.registerEpisodeSamplingFunctions();
        end

        
        function [numTimeSteps] = getNumTimeSteps(obj)
            numTimeSteps = obj.numTimeSteps;
        end
        
        function [] = registerEpisodeSamplingFunctions(obj)
            robotTaskEntries = {};
            additionalParameters = {};
            if (~isempty(obj.robotTask))
                robotTaskEntries = obj.robotTask.additionalDataEntries;
                additionalParameters = obj.robotTask.additionalParameters;
                if (obj.robotTask.useSLReward)
                    obj.registerSLReturnAsReward();
                end
            end
            
            
            obj.addDataManipulationFunction('sampleEpisode', {obj.additionalInputVariables}, {'states', 'actions', 'nextStates', obj.additionalOutputVariables{:}, robotTaskEntries{:}}, Data.DataFunctionType.PER_EPISODE);
            obj.addDataManipulationFunction('getRobotContext', additionalParameters, {'robotContexts'}, Data.DataFunctionType.PER_EPISODE, true);
            
           
        end
        
        function [] = addAdditionalInputVariablesForEpisode(obj, inputVariables)
            obj.additionalInputVariables = {obj.additionalInputVariables{:}, inputVariables };
            obj.registerEpisodeSamplingFunctions();
        end
        
        function [] = addAdditionalOutputVariablesForEpisode(obj, outputVariables)
            obj.additionalOutputVariables = {obj.additionalOutputVariables{:}, outputVariables };
            obj.registerEpisodeSamplingFunctions();
        end
        
        function valid = isValidLastEpisode(obj)
            valid = obj.isValidLastEpisode;
        end
        
    end
    
    methods (Abstract)
        [states, actions, nextStates] = sampleEpisode(obj, contexts, varargin);
        [contexts] = getRobotContext(obj, numElements, contexts);
    end
end
