classdef StepBasedPIRKHS < Experiments.Learner.StepBasedLearningSetup
    
    properties
        
    end
    
    methods
        function obj = StepBasedPIRKHS(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.Learner.StepBasedLearningSetup(trial, evaluationCriterion);
   
            %if(isprop(trial.modelLearner,'expparamsopt'))
            %    evaluationCriterion.addCriterion('endLoop', 'trial.modelLearner', 'paramsopt', Experiments.StoringType.STORE_PER_ITERATION, @(learner)learner.expparamsopt);
            %end

            %evaluationCriterion.addCriterion('endLoop', 'trial.learner', 'repsAvgReward', Experiments.StoringType.STORE_PER_ITERATION, @(learner)learner.repsAvgReward);
            %evaluationCriterion.addCriterion('endLoop', 'trial.learner', 'repsPredReward', Experiments.StoringType.STORE_PER_ITERATION, @(learner)learner.repsPredReward);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            Common.Settings().setProperty('PathIntegralCostActionMultiplier',1.0)

            
            

            %policy 
            %trial.setprop('psifunction', @(trial) Functions.LogLinearFunction(trial.dataManager,'states', 'desirability'));
            %trial.setprop('actionPolicy', @(trial) Functions.PathIntegralPolicy(trial.dataManager, trial.psifunction, trial.transitionFunction ));

            %learner
            trial.setprop('learner',@Learner.SteadyStateRL.PI_RKHS.CreateFromTrial);                        
        end
        
       % function setupActionPolicy(obj, trial)
       %     trial.dataManager.finalizeDataManager()
            
            %trial.actionPolicy=trial.actionPolicy(trial);
       %     trial.dataManager.finalizeDataManager()
       % end
        
        function postConfigureTrial(obj, trial)
            %obj.setupFeatures(trial);
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);

        end
           
%         function setupFeatures(obj, trial)
%             trial.dataManager.finalizeDataManager()
% 
%             trial.stateFeatures1 = trial.stateFeatures1(trial);    
%             trial.stateFeatures2 = trial.stateFeatures2(trial);    
%             trial.stateFeatures = trial.stateFeatures(trial);     
%             
%             trial.nextStateFeatures1 = trial.nextStateFeatures1(trial);    
%             trial.nextStateFeatures2 = trial.nextStateFeatures2(trial); 
%             trial.nextStateFeatures = trial.nextStateFeatures(trial);
%         end
                        

                     
        function setupLearner(obj, trial)
            trial.learner=trial.learner(trial);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
%             if any(strcmp(methods(trial.stateFeatures), 'updateModel'))
%                 %learning feature extractors
%                 trial.scenario.addLearner(trial.stateFeatures);
%                 trial.scenario.addLearner(trial.nextStateFeatures);                       
%             end
                       
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);

%             trial.scenario.addInitObject(trial.stateFeatures);
%             trial.scenario.addInitObject(trial.nextStateFeatures);
%             trial.scenario.addInitObject(trial.psifunction);
        end
        
    end
    
end
