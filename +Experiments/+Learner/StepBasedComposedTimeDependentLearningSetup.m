classdef StepBasedComposedTimeDependentLearningSetup < Experiments.Learner.StepBasedLearningSetup
    
    properties
        
    end
    
    methods
        function obj = StepBasedComposedTimeDependentLearningSetup(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.Learner.StepBasedLearningSetup(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            
            trial.setprop('stateFeatures', @FeatureGenerators.SquaredFeatures);            
            
            trial.setprop('actionPolicyPerTimeStep',  @Distributions.Gaussian.GaussianActionPolicy);            
            trial.setprop('actionPolicy',@Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('policyLearnerPerTimeStep',  @Learner.SupervisedLearner.LinearGaussianMLLearner);            
            trial.setprop('policyLearner',@Learner.SupervisedLearner.TimeDependentLearner);
            
            trial.setprop('learner',@Learner.StepBasedRL.StepBasedREPS.StepBasedREPSFromTrial);
            trial.setprop('preprocessors'); 
        end
                                        
        function setupActionPolicy(obj, trial)
            trial.actionPolicy=trial.actionPolicy(trial.dataManager, trial.actionPolicyPerTimeStep);
            trial.policyLearner=trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.policyLearnerPerTimeStep);
        end      
        
        function postConfigureTrial(obj, trial)            
            if (~isempty(trial.stateFeatures))
                trial.stateFeatures = trial.stateFeatures(trial.dataManager, 'states');    
            end
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);        
        end        
        
        function [] = setupScenarioForLearners(obj, trial)  
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);
            trial.scenario.addInitObject(trial.actionPolicy);
        end
        
        function setupLearner(obj, trial)
            obj.setupActionPolicy(trial);
            setupLearner@Experiments.Learner.StepBasedLearningSetup(obj, trial);
        end
    end
    
end
