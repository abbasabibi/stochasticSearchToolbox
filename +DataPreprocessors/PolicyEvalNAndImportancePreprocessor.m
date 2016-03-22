classdef PolicyEvalNAndImportancePreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %%% Importance sampling on N estimator.
    %%% N_t(s,a) = E_{s'~ p(.|s,a), a'~ pi_t+1(. | s')} [ Q_t+1 (s', a') ]
    properties
        qLearner;
        policy;
        stateDistrib;
        currentTimeStep;
        saFeatureGenerator;
        rewardGenerator;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
        nbSampledActionPerState;
    end
    
    methods
        function obj = PolicyEvalNAndImportancePreprocessor(trial, saFeaturesName, qLearnerClass, qFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('nbSampledActionPerState'); 
            
            
            obj.policy = trial.actionPolicy;
            obj.stateDistrib = trial.stateDistribution;
            obj.saFeatureGenerator = trial.stateActionFeatures;
            obj.rewardGenerator = trial.rewardFunction;
            
            if (trial.isProperty('learnerDataName')  && ~isempty(trial.learnerDataName))
                obj.dataNamePreprocessor = trial.learnerDataName;
            end
            
            if (~exist('saFeaturesName', 'var') || isempty(saFeaturesName))
                saFeaturesName = 'SquaredStatesActions';
            end
            
            inputNEstimate = {saFeaturesName, 'states', 'actions', 'nextStates', 'timeIndependentSAProba'};
            inputQEstimate = {'states', saFeaturesName, 'rewardsToCome'}; % 'rewardsToCome' for debug only
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, inputQEstimate(3), inputQEstimate(2), 'qApproximator');
            end
            
            if (~exist('policyEvalName', 'var'))
                policyEvalName = 'qValue';
            end
            
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            qFApprox.initObject();
            obj.qLearner = qLearnerClass(obj.dataManager, qFApprox);
            
            obj.dataManager.addDataEntry([layerName, '.', policyEvalName], 1);
            
            obj.addDataManipulationFunction('computeQValue', inputQEstimate, {policyEvalName});
            obj.addDataManipulationFunction('computeNFunction', inputNEstimate, {});
        end
        
        function computeNFunction(obj, saFeatures, states, actions, nextStates, timeIndependentSAProba)
            %%% estimating N_{currentTimeStep-1}
            % I- computing E_a ~ pi_t(.|s') [phi(s', a)] 
            % 1) getting average action and covrariance for each s' 
            actionPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
            [muAction, sigma] = actionPolicy.getExpectationAndSigma(size(nextStates, 1), nextStates);
            sigma = permute(sigma, [2 3 1]);
            covAction = sigma' * sigma;
            
            % 2) extracting quadratic in actions part of the features
            quadPart = [ones(1, size(nextStates, 2)) (2*ones(1,size(muAction, 2)))];
            quadPart = obj.saFeatureGenerator.getFeaturesInternal(size(quadPart, 1), quadPart);
            quadPart = quadPart(1, :) == 4;
            
            % 3) computing feature average (last line: E[a1 a2] = E[a1]E[a2] + cov(a1,a2))
            meanFeatures = [nextStates muAction];
            meanFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(meanFeatures, 1), meanFeatures);
            meanFeatures(:, quadPart) = meanFeatures(:, quadPart) + repmat(covAction(tril(ones(size(muAction, 2))) == 1)', size(meanFeatures, 1),1);
            
            % II- Importance sampling weights
            prevPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep - 1);
            prevStateDistrib = obj.stateDistrib.getDistributionForTimeStep(obj.currentTimeStep - 1);
            qWeighting =  exp(prevStateDistrib.getDataProbabilities([], states)...
                + prevPolicy.getDataProbabilities(states, actions))...
                ./ timeIndependentSAProba;
            
            %N_{currentTimeStep-1}(s,a)
            obj.qLearner.learnFunction(saFeatures, obj.qLearner...
                .functionApproximator.getExpectation(size(meanFeatures, 1),...
                meanFeatures), qWeighting);            
        end
        
        function [qvalue] = computeQValue(obj, states, stateActionFeatures, rewardsToCome)
            %Learn Q(s,a)
            currPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
            states = repmat(states, obj.nbSampledActionPerState * size(states, 1), 1);
            actions = currPolicy.sampleFromDistribution(size(states, 1), states);
            virtualSaFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(states, 1), [states actions]);
            virtualRewards = obj.rewardGenerator.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
            if(obj.currentTimeStep ~= obj.numTimeSteps)
                obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards + obj.qLearner.functionApproximator.getExpectation(size(virtualSaFeatures, 1), virtualSaFeatures));
            else
                obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards);
            end
            qvalue = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
            disp(var(qvalue - rewardsToCome) / var(rewardsToCome));
        end
        
        function data = preprocessData(obj, data)
            for t = obj.numTimeSteps:-1:1
                obj.currentTimeStep = t;
                obj.callDataFunction('computeQValue', data, :, t); % compute Q_t
                if(t ~= 1)
                    obj.callDataFunction('computeNFunction', data); % compute N_{t-1}
                end
            end
        end
        
    end
end


