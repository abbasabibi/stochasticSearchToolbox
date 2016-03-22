classdef StepBasedRKHSREPSNoPol < Experiments.Learner.StepBasedLearningSetup
    
    properties
        
    end
    
    methods
        function obj = StepBasedRKHSREPSNoPol(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.Learner.StepBasedLearningSetup(trial, evaluationCriterion);

            if(isprop(trial.modelLearner,'expparamsopt'))
                evaluationCriterion.addCriterion('endLoop', 'trial.modelLearner', 'paramsopt', Experiments.StoringType.STORE_PER_ITERATION, @(learner)learner.expparamsopt);
            end
            if(isprop(trial.policyLearner,'expparamsopt'))
                evaluationCriterion.addCriterion('endLoop', 'trial.policyLearner', 'paramsoptPolicy', Experiments.StoringType.STORE_PER_ITERATION, @(learner)learner.expparamsopt);
            end
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);

            %learners
            trial.setprop('modelLearner',...
                @(trial) Learner.ModelLearner.RKHSModelLearner(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.stateActionFeatures) )
                        
            trial.setprop('learner',@(trial) ...
                Learner.SteadyStateRL.REPS_infhorizon_iter(trial.dataManager, ...
                {}, 'rewards', 'sampleWeights',trial.stateFeatures.outputName, ...
                trial.modelLearner.outputName));                        
       
            Common.Settings().setProperty('maxNumOptiIterations',15);
            Common.Settings().setProperty('tolKL',0.1);
            Common.Settings().setProperty('epsilonAction',0.5);
            
            trial.setprop('policyParameters',[]);


        end
        

        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);

        end

                     
        function setupLearner(obj, trial)
            
            trial.modelLearner= trial.modelLearner(trial);

            trial.learner=trial.learner(trial);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            
            
%             if any(strcmp(methods(trial.stateFeatures), 'updateModel'))
%                 %learning feature extractors
%                 trial.scenario.addLearner(trial.stateFeatures);
%                 trial.scenario.addLearner(trial.nextStateFeatures);
%                 trial.scenario.addLearner(trial.stateActionFeatures);
%                 trial.scenario.addLearner(trial.actionFeatures);              
%             end
%             
            

%             trial.scenario.addLearner(trial.policyFeatures);         
            trial.scenario.addLearner(trial.modelLearner);
                        
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);
            %trial.scenario.addLearner(trial.policyVisualize);   
                                    
%            trial.scenario.addInitObject(trial.stateFeatures);
%            trial.scenario.addInitObject(trial.nextStateFeatures);
%            trial.scenario.addInitObject(trial.stateActionFeatures);
%            trial.scenario.addInitObject(trial.actionFeatures);
%            trial.scenario.addInitObject(trial.policyFeatures); 

        end
        
    end
    
end
