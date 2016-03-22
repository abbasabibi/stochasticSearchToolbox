classdef DirectPolicyIteration < Learner.WeightedML.RLByWeightedML
    properties
        
    end
    
    
    methods (Static)
        function [learner] = CreateFromTrial(trial)
            if (trial.isProperty('stateFeatures') && ~isempty( trial.stateFeatures) )
                if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling)
                    learner = Learner.ActorCritic.DirectPolicyIteration(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName(), 'importanceWeights');
                else
                    learner = Learner.ActorCritic.DirectPolicyIteration(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName());
                end
                %learner = Learner.ActorCritic.REPSStateActionDistribution(trial.dataManager, trial.policyLearner, trial.qValueName, trial.stateFeatures.getFeatureName());
            else
                learner = Learner.ActorCritic.DirectPolicyIteration(trial.dataManager, trial.policyLearner);
            end
        end
    end
    
    % Class methods
    methods
        function obj = DirectPolicyIteration(dataManager, policyLearner, qValueName, stateFeatureName, varargin)
            if (~exist('qValueName','var'))
                qValueName = 'qValues';
            end
            obj = obj@Learner.WeightedML.RLByWeightedML(dataManager, policyLearner, qValueName, 'qValueWeighting', 'steps');
        end
        
        function [weights] = computeWeighting(obj, rewards, stateFeatures, sampleWeighting)
            if (~exist('sampleWeighting', 'var'))
                sampleWeighting = ones(size(rewards,1),1);
            end
            
            weights = exp(rewards);
        end       
    end
end

