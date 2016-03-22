classdef ValueFunctionREPS < Learner.EpisodicRL.EpisodicREPS
    
    properties
    end
    
    methods (Static)
        function [learner] = createFromTrial(trial)
            learner = Learner.SteadyStateRL.ValueFunctionREPS(dataManager, policyLearner, policyEvaluationLearner, QFunction);            
        end
        
    end
    
    methods
        function [obj] = ValueFunctionREPS(dataManager, policyLearner, policyEvaluationLearner, QFunction)

            policyEvaluationProcessor = PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, QFunction);
            
            obj = obj@Learner.EpisodicRL.EpisodicREPS(dataManager, policyLearner, 'stateActionValues', 'rewardWeighting', 'stateFeatures');
            obj.addDataPreprocessor(policyEvaluationProcessor );
                        
        end
        
    end
    
end

