classdef StepBasedLearningSetupPolicyEvaluation < Experiments.Learner.StepBasedLearningSetup
    
    properties
        
    end
    
    methods
        function obj = StepBasedLearningSetupPolicyEvaluation(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);                    
            
            trial.setprop('learner', @Learner.ActorCritic.REPSStateActionDistribution.CreateFromTrial);
            
            trial.setprop('featurePreprocessor', @PolicyEvaluation.DiscreteActionStateFeatureGenerator);
            trial.setprop('featurePreprocessorNext', @PolicyEvaluation.DiscreteActionNextStateFeatures);
            trial.setprop('policyEvaluationFunction', @Functions.ValueFunctions.LinearQFunction);
            trial.setprop('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTemporalDifferenceLearning.CreateFromTrialLearnQFunction);
            trial.setprop('policyEvaluationFeature', @PolicyEvaluation.PolicyEvaluationFeatureGenerator);
            
            trial.setprop('rewardName', 'rewards'); %For LSTD                    
            trial.setprop('qValueName', 'qValues');                     
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            obj.setupPolicyEvaluation(trial);

        end
        
        
        function [] = setupPolicyEvaluation(obj, trial)
            
            trial.featurePreprocessorNext =  trial.featurePreprocessorNext(trial.dataManager,trial.nextStateFeatures.outputName, trial.actionPolicy.outputVariable);
            trial.featurePreprocessor =  trial.featurePreprocessor(trial.dataManager, trial.stateFeatures.outputName, trial.actionPolicy.outputVariable);
            
            trial.policyEvaluationFunction = trial.policyEvaluationFunction(trial.dataManager, trial.featurePreprocessor.outputName);
            trial.policyEvaluationLearner = trial.policyEvaluationLearner(trial);
            trial.policyEvaluationFeature = trial.policyEvaluationFeature(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction);
            
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.policyEvaluationFeature);
                        
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);
                        
            trial.scenario.addInitObject(trial.policyEvaluationFunction);
            trial.scenario.addInitObject(trial.policyEvaluationLearner);
        end
        
    end
    
end
