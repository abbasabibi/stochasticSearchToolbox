classdef StepBasedComposedLearnedModelLearningSetup < Experiments.Learner.StepBasedComposedTimeDependentLearningSetup
    
    properties
        
    end
    
    methods
        function obj = StepBasedComposedLearnedModelLearningSetup(learnerName)
            obj = obj@Experiments.Learner.StepBasedComposedTimeDependentLearningSetup(learnerName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.Learner.StepBasedComposedTimeDependentLearningSetup(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedComposedTimeDependentLearningSetup(trial);
                                    
            trial.setprop('learnedModelPerTimeStep',@Distributions.Gaussian.GaussianTransitionFunction);
            trial.setprop('learnedModel',@Distributions.TimeDependent.ComposedTimeDependentDistribution);
            
            trial.setprop('learnedModelPerTimeStepLearner',@Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('learnedModelLearner',@Learner.SupervisedLearner.TimeDependentLearner);            
            
            
            trial.setprop('policyInput', 'states');
            
        end
            
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Learner.StepBasedComposedTimeDependentLearningSetup(trial);
            
            obj.setupLearnedModel(trial);                                   
        end
        
        function [] = setupScenarioForLearners(obj, trial)            
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedComposedTimeDependentLearningSetup(trial);         
            trial.scenario.addInitObject(trial.learnedModelDataGenerator);
        end
        
        function setupLearnedModel(obj, trial)
            trial.learnedModel=trial.learnedModel(trial.dataManager, trial.learnedModelPerTimeStep);
            trial.learnedModelLearner=trial.learnedModelLearner(trial.dataManager, trial.learnedModel, trial.learnedModelPerTimeStepLearner);
            
            trial.setprop('learnedModelDataGenerator');
            trial.learnedModelDataGenerator = DataPreprocessors.LearnedStepBasedTransitionModelDataGenerator(trial.dataManager, trial.sampler, trial.learnedModel);
            trial.learnedModelDataGenerator.addLearner(trial.learnedModelLearner);
            
            
            trial.addPreprocessor(trial.learnedModelDataGenerator, true);
        end
        
    end
    
end
