classdef BanditLearningSetup < Experiments.ConfiguredLearner
    
    properties
    end
    
    methods
        function obj = BanditLearningSetup(learnerName)
            obj = obj@Experiments.ConfiguredLearner(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@ Experiments.ConfiguredLearner(trial, evaluationCriterion);
            trial.learner.addDefaultCriteria(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredLearner(trial);
            
            trial.setprop('contextFeatures', @FeatureGenerators.SquaredFeatures);            
            
            trial.setprop('parameterPolicy', @Distributions.Gaussian.GaussianParameterPolicy);
            trial.setprop('parameterPolicyLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('useFeaturesForPolicy', false);
            trial.setprop('learner', @Learner.EpisodicRL.CMALearner.CreateFromTrial);
            
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.setupFeatures(trial);
            obj.setupParameterPolicy(trial);
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
        
        end
        
        function setupFeatures(obj, trial)
            if (~isempty(trial.contextFeatures))
                trial.contextFeatures = trial.contextFeatures(trial.dataManager, 'contexts');                                   
            end
        end
        
        function setupParameterPolicy(obj, trial)            
            
            trial.parameterPolicy=trial.parameterPolicy(trial.dataManager);
            if (trial.useFeaturesForPolicy)
                trial.parameterPolicy.setFeatureGenerator(trial.contextFeatures);
            end
            if (~isempty(trial.parameterPolicyLearner))
                trial.parameterPolicyLearner=trial.parameterPolicyLearner(trial.dataManager, trial.parameterPolicy);
            end
        end
        
        function setupLearner(obj, trial)            
            if(~isempty(trial.learner))                
                trial.learner=trial.learner(trial);                
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            
            obj.setupScenarioForLearners@Experiments.ConfiguredLearner(trial);
            
            trial.scenario.addInitObject(trial.parameterPolicy);
            
            if(~isempty(trial.parameterPolicyLearner))
                trial.scenario.addInitObject(trial.parameterPolicyLearner);
            end
            
            trial.scenario.addSampler(trial.virtualSampler);
            trial.scenario.addLearner(trial.virtualSampler);
            
        end
        
        function registerSamplers(obj, trial)
            
            if (trial.isProperty('parameterPolicy') &&  ~isempty(trial.parameterPolicy))
                if (~trial.dataManager.isDataAlias('parameters'))
                    warning('EXP', 'policysearchtoolbox:Experiments:Tasks:BanditTasks; You set a parameter policy, but no parameters are defined --- ignoring\n');
                else
                    trial.sampler.setParameterPolicy(trial.parameterPolicy);
                end
            end
            
            virtualSampler = Sampler.VirtualSampler.EpisodicVirtualSampler(trial.dataManager, trial.sampler);
            trial.setprop('virtualSampler', virtualSampler);
        end
    end
    
end


