classdef TestStepLearner < Experiments.ConfiguredLearner
    
    properties
        
    end
    
    methods
        function obj = TestStepLearner()
            obj = obj@Experiments.ConfiguredLearner('TestLearner', Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            
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
                                    
            trial.setprop('actionPolicy',@Distributions.Gaussian.GaussianActionPolicy);
            %trial.setprop('learner',@Experiments.test.DummyLearner);
            trial.setprop('learner',@Learner.StepBasedRL.StepBasedRLWeightedML);
            
            %trial.setprop('virtualSampler',@Sampler.VirtualSampler.EpisodicVirtualSampler);            
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
                               
            obj.setupActionPolicy(trial);            
            obj.setupLearner(trial);
        end
                        
        function setupActionPolicy(obj, trial)
            trial.setprop('actionPolicy');
            if(isa(trial.actionPolicy,'function_handle'))
                trial.actionPolicy=trial.actionPolicy(trial.dataManager);
                trial.actionPolicy.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
            end                        
        end
                     
        function setupLearner(obj, trial)
            trial.setprop('learner');
            trial.dataManager.addDataEntry('qSA', 1);
            if(isa(trial.learner,'function_handle'))
                trial.learner=trial.learner(trial.dataManager);%, '', 'returns', 'returnWeighting', 'qSA', 'qSA');
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.learner);
            trial.scenario.addInitObject(trial.actionPolicy);
            trial.scenario.addInitObject(trial.learner);
        end
        
    end
    
end
