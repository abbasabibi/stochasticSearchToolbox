classdef StepBasedActionHiREPS < Experiments.ConfiguredLearner
    
    properties
        modelFeatureName        
%         isInitKMeans = false;
        usesEM = false;
    end
    
    methods
        function obj = StepBasedActionHiREPS(learnerName, modelFeatureName, usesEM)
            obj = obj@Experiments.ConfiguredLearner(learnerName, Experiments.LearnerType.TypeA);
            obj.modelFeatureName = modelFeatureName;
            if(exist('usesEM', 'var') )
                obj.usesEM = usesEM;
            end
        end
        
        %%
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.ConfiguredLearner(trial, evaluationCriterion);

        end
        
        %%
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredLearner(trial);
            
%             trial.setprop('doKMeansInit', true);
            

            %learners
            trial.setprop('modelLearner',...
                @(trial) Learner.ModelLearner.SampleModelLearner(...
                trial.dataManager, ':', trial.(obj.modelFeatureName), [], [], trial.sampler.stepSampler.isActiveSampler.resetProbName));
                        
            trial.setprop('learner',@(trial) ...
                Learner.SteadyStateRL.HiREPSIter(trial.dataManager, ...
                trial.policyLearner, 'rewards', 'rewardWeightings','responsibilities', trial.(obj.modelFeatureName).outputName, trial.modelLearner.outputName));                        
       
%             Common.Settings().setProperty('maxNumOptiIterations',100);
            Common.Settings().setProperty('tolKL',0.1);
            Common.Settings().setProperty('epsilonAction',0.5);
            

        end
        

        %%
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
        end

           
        %%
        function setupLearner(obj, trial)            
            trial.modelLearner  = trial.modelLearner(trial);
            trial.learner       = trial.learner(trial);            
        end
        
        %%
        function [] = setupScenarioForLearners(obj, trial)
                  
            trial.scenario.addLearner(trial.modelLearner);
            
            if(obj.usesEM)
                trial.learner.addDataPreprocessor(trial.policyLearner);                
%                 trial.scenario.addDataPreprocessor(trial.policyLearner, true);                
            else
                respPreProcessor = DataPreprocessors.DataProbabilitiesPreprocessor(trial.dataManager, trial.actionPolicy, [], 'computeResponsibilities');
                trial.scenario.addDataPreprocessor(respPreProcessor, true);
            end
                        
            obj.setupScenarioForLearners@Experiments.ConfiguredLearner(trial);
            
        end
        
    end
    
end
