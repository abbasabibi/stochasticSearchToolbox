classdef TestLearner < Experiments.ConfiguredLearner
    
    properties
        
    end
    
    methods
        function obj = TestLearner()
            obj = obj@Experiments.ConfiguredLearner('TestLearner', Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            trial.learner.addDefaultCriteria(trial, evaluationCriterion);
%             evaluationCriterion.addCriterion('preLoop','virtSampler',[],[],[],false);
%             evaluationCriterion.addCriterion('preLoop','obj.stateFeatureGenerator','stateFeatureGenerator',[],[],false);
%             
% 
% %            evaluationCriterion.addCriterion('startLoop','obj.model','model',Experiments.StoringType.ACCUMULATE);
% 
%             evaluationCriterion.addCriterion('endLoop', 'newRealData.reward', 'avgRewardReal', Experiments.StoringType.ACCUMULATE, @(rew)sum(mean(rew,1),2));
%             evaluationCriterion.addCriterion('endLoop', 'newRealData', 'realData', Experiments.StoringType.STORE_PER_ITERATION);
% 
%             evaluationCriterion.addCriterion('endLoop', 'newVirtData.reward', 'avgRewardVirt', Experiments.StoringType.ACCUMULATE, @(rew)sum(mean(rew,1),2));
%             %evalCriterion.addCriterion('endLoop', 'newVirtData', 'virtData', Experiments.StoringType.STORE_PER_ITERATION);
% 
%             evaluationCriterion.addCriterion('endLoop', 'obj.numVirtualSamples', 'numVirtualSamples', Experiments.StoringType.STORE_PER_ITERATION);
%             evaluationCriterion.addCriterion('endLoop', 'numOverflowSamples', 'numOverflowSamples', Experiments.StoringType.STORE_PER_ITERATION);
%             evaluationCriterion.addCriterion('endLoop', 'data');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredLearner(trial);
                                    
            trial.setprop('parameterPolicy',@Distributions.Gaussian.GaussianLinearInFeatures);
            trial.setprop('learner',@Experiments.test.DummyLearner);

            trial.setprop('virtualSampler',@Sampler.VirtualSampler.EpisodicVirtualSampler);            
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
                               
            obj.setupParameterPolicy(trial);            
            obj.setupLearner(trial);
            obj.setupVirtualSampler(trial);
        end
                        
        function setupParameterPolicy(obj, trial)
            trial.setprop('parameterPolicy');
            if(isa(trial.parameterPolicy,'function_handle'))
                trial.parameterPolicy=trial.parameterPolicy(trial.dataManager, 'parameters', [], 'parameterPolicy');
                trial.parameterPolicy.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
            end                        
        end
        
        function setupVirtualSampler(obj, trial)
            trial.setprop('virtualSampler');
            if(isa(trial.virtualSampler,'function_handle'))
                trial.virtualSampler=trial.virtualSampler(trial.settings, trial.dataManager, trial.environment, trial.parameterPolicy);
            end 
        end
        
        function setupLearner(obj, trial)
            trial.setprop('learner');
            if(isa(trial.learner,'function_handle'))
                trial.learner=trial.learner(trial.settings);
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.virtualSampler);            
            trial.scenario.addLearner(trial.learner);         
            trial.scenario.addSampler(trial.virtualSampler); 
            
            trial.scenario.addInitObject(trial.parameterPolicy);
        end
        
    end
    
end
