classdef StepBasedDynamicProgrammingQREPS < Learner.StepBasedRL.StepBasedREPS
    
    properties
        policyEvalPreprocessor;
    end
    
    methods
        function obj = StepBasedDynamicProgrammingQREPS(trial, qValueName)
            obj = obj@Learner.StepBasedRL.StepBasedREPS(trial.dataManager, trial.policyLearner, trial.stateFeatures.getFeatureName(), qValueName);            
            obj.policyEvalPreprocessor = trial.policyEvalPreprocessor(trial);
        end
        
        function [] = updateModel(obj, data)
            %dbloop(); % for debug. if you don't have this function... comment the line.
            changePoint = 0;%floor(obj.numTimeSteps);
            for t = obj.numTimeSteps:-1:changePoint+1
                disp(['---- Preprocess and update: timeStep ', num2str(t), ' ----'])
                preprocessedData = obj.policyEvalPreprocessor.preprocessDataForTimeStep(data, t);
                preprocessedData = updateModelForTimeStep(obj, preprocessedData, t);
                obj.policyEvalPreprocessor.postprocessDataForTimeStep(data, preprocessedData, t);
            end
            for t = changePoint:-1:1
                disp(['---- Preprocess: timeStep ', num2str(t), ' ----'])
                preprocessedData = obj.policyEvalPreprocessor.preprocessDataForTimeStep(data, t);
                obj.policyEvalPreprocessor.postprocessDataForTimeStep(data, preprocessedData, t);
            end
            for t = changePoint:-1:1
                disp(['---- Update: timeStep ', num2str(t), ' ----'])                           
                updateModelForTimeStep(obj, preprocessedData, t);
            end
        end
        
        function data = updateModelForTimeStep(obj, data, t)
            %compute weights
            obj.LearnerPerTimeStep{t}.callDataFunction('computeWeighting', data, :, t);
            
            %do ML update of the policy
            obj.policyLearner.updateModelForTimeStep(data, t);
        end
    end
end
