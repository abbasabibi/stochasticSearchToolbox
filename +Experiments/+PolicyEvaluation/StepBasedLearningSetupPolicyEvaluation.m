classdef StepBasedLearningSetupPolicyEvaluation < Experiments.Learner.StepBasedLearningSetup
    
    methods
        function obj = StepBasedLearningSetupPolicyEvaluation(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);                    
                    
            trial.setprop('useImportanceSampling', true);
            %trial.setprop('useImportanceSampling', false);
            
            %trial.setprop('importanceSampler',@DataPreprocessors.ImportanceSamplingActionExpectationObservedSamples);
            trial.setprop('importanceSampler',@DataPreprocessors.ImportanceSamplingLastKPolicies);
             
            trial.setprop('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);         
            
            trial.setprop('policyEvaluationDataName', 'data');
            trial.setprop('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessor.CreateFromTrial);
            %trial.setprop('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor.CreateFromTrial);
            
            trial.setprop('rewardName', 'rewards'); %For LSTD                    
            trial.setprop('qValueName', 'qValues');                     
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            obj.setupPolicyEvaluation(trial);

        end
        
        
        function [] = setupPolicyEvaluation(obj, trial)      
            if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling)
                trial.importanceSampler = trial.importanceSampler(trial.dataManager, trial.actionPolicy);
            else
                if(isprop(trial,'importanceSampler')) 
                    trial.importanceSampler = [];
                end
            end
            trial.policyEvaluationLearner = trial.policyEvaluationLearner(trial);
            trial.policyEvaluationPreProcessor = trial.policyEvaluationPreProcessor(trial);
            trial.policyEvaluationPreProcessor.setDataNameLearner(trial.policyEvaluationDataName);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            if (isprop(trial,'importanceSampler') && ~isempty(trial.importanceSampler))
                trial.scenario.addDataPreprocessor(trial.importanceSampler);
            end
                        
            trial.scenario.addLearner(trial.policyEvaluationPreProcessor);
                        
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);

            trial.scenario.addInitObject(trial.policyEvaluationLearner);
        end
        
    end
    
end
