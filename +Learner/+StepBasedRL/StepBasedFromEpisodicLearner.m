classdef StepBasedFromEpisodicLearner < Learner.StepBasedRL.StepBasedRLWeightedML
    
    properties
        LearnerPerTimeStep = {};
        episodicLearnerInitializer                
    end
    
    properties (SetObservable,AbortSet)
        numTimeSteps
    end
    
    % Class methods
    methods
        function obj = StepBasedFromEpisodicLearner(dataManager, policyLearner, learnerInitializer)
            
            obj = obj@Learner.StepBasedRL.StepBasedRLWeightedML(dataManager, policyLearner);  
            obj.linkProperty('numTimeSteps');          
            
            obj.LearnerPerTimeStep = cell(obj.numTimeSteps,1);
            for timeStepIdx = 1:obj.numTimeSteps
                obj.LearnerPerTimeStep{timeStepIdx} = learnerInitializer(obj.dataManager);
            end
        end
        
        
        
        function obj = initObject(obj, varargin)            
            for timeStepIdx = 1:obj.numTimeSteps
                % we need stateFeatureName and weightName?
                obj.LearnerPerTimeStep{timeStepIdx}.initObject();
            end
        end
        
        function [] = preparePolicyUpdate(obj, data)
            %iterate over time steps
            
            [~, numElementsList] = data.getNumElementsForDepth(2);
            for timeStepIdx = 1:numElementsList(1)
                obj.LearnerPerTimeStep{timeStepIdx}.callDataFunction('computeWeighting', data, :, timeStepIdx);
                fprintf('TimeStep %d:', timeStepIdx);
                obj.LearnerPerTimeStep{timeStepIdx}.printMessage(data);
            end
        end  
        
        
    end
  
end
