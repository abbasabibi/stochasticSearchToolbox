classdef PolicyEvalNIAPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %%% N: NValue is N_t(s,a) = E_{s'~ p(.|s,a), a'~ pi_t+1(. | s')} [ Q_t+1 (s', a') ]
    %%% I: uses Importance Sampling
    %%% A: uses additional samples
    properties
        qLearner;
        nLearner;
        policy;
        stateDistrib;
        currentTimeStep;
        saFeatureGenerator;
        rewardGenerator;
        useImportanceSampling;
        
        dataVirtual;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
        nbSampledActionPerState;
    end
    
    methods
        function obj = PolicyEvalNIAPreprocessor(trial, useImportanceSampling, learnerDataName, saFeaturesName, qLearnerClass, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('nbSampledActionPerState');
            
            
            obj.policy = trial.actionPolicy;
            obj.stateDistrib = trial.stateDistribution;
            obj.saFeatureGenerator = trial.stateActionFeatures;
            obj.rewardGenerator = trial.rewardFunction;
            
            if (exist('learnerDataName', 'var') && ~isempty(learnerDataName))
                obj.dataNamePreprocessor = learnerDataName;
            end
            
            if (~exist('useImportanceSampling', 'var') || isempty(useImportanceSampling))
                useImportanceSampling = false;
            end
            obj.useImportanceSampling = useImportanceSampling;
            
            if (~exist('saFeaturesName', 'var') || isempty(saFeaturesName))
                saFeaturesName = 'SquaredStatesActions';
            end
            
            inputNEstimate = {saFeaturesName, 'states', 'actions', 'nextStates', 'timeIndependentSAProba'};
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('policyEvalName', 'var'))
                policyEvalName = 'qValue';
            end
            
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            obj.dataManager.addDataEntry([layerName, '.', policyEvalName], 1);
            
            qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, {policyEvalName}, inputNEstimate(1), 'qApproximator');
            qFApprox.initObject();
            nFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, {policyEvalName}, inputNEstimate(1), 'nApproximator');
            nFApprox.initObject();
            
            obj.qLearner = qLearnerClass(obj.dataManager, qFApprox);
            obj.nLearner = qLearnerClass(obj.dataManager, nFApprox);
            
            obj.addDataManipulationFunction('learnQValue', {'states'}, {'actions', policyEvalName});
            obj.addDataManipulationFunction('learnNValue', inputNEstimate, {});
        end
        
        function learnNValue(obj, saFeatures, states, actions, nextStates, timeIndependentSAProba)
            %%% estimating N_{t-1}(s,a) = E_{s'~ p(.|s,a), a'~ pi_t(. | s')} [ Q_t (s', a') ]
            % I- computing E_{a ~ pi_t(.|s')} [phi(s', a)]
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
            if(obj.useImportanceSampling)
                prevPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep - 1);
                prevStateDistrib = obj.stateDistrib.getDistributionForTimeStep(obj.currentTimeStep - 1);
                qWeighting =  exp(prevStateDistrib.getDataProbabilities([], states)...
                    + prevPolicy.getDataProbabilities(states, actions))...
                    ./ timeIndependentSAProba;
            else
                qWeighting = ones(size(saFeatures, 1), 1);
            end
            
            %N_{currentTimeStep-1}(s,a)
            obj.nLearner.learnFunction(saFeatures, obj.qLearner...
                .functionApproximator.getExpectation(size(meanFeatures, 1),...
                meanFeatures), qWeighting);
        end
        
        function [actions, qvalue] = learnQValue(obj, states)
            %Learn Q(s,a)
            currPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
            actions = currPolicy.sampleFromDistribution(size(states, 1), states);
            virtualSaFeatures = obj.saFeatureGenerator.getFeaturesInternal(size(states, 1), [states actions]);
            virtualRewards = obj.rewardGenerator.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
            if(obj.currentTimeStep ~= obj.numTimeSteps)
                obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards + obj.nLearner.functionApproximator.getExpectation(size(virtualSaFeatures, 1), virtualSaFeatures));
            else
                obj.qLearner.learnFunction(virtualSaFeatures, virtualRewards);
            end
            qvalue = obj.qLearner.functionApproximator.getExpectation(size(virtualSaFeatures, 1), virtualSaFeatures);
            
            weird = length(find(qvalue > 0));
            if(weird ~= 0)
                warning([mfilename, ': qvalue should not be positive!!!']);
                %                qvalue(qvalue > 0) = min(qvalue) * ones(weird, 1);
            end
        end
        
        function dataPrepro = preprocessData(obj, data)
            % create a copy of the data
            dataPrepro = data.dataManager.getDataObject(0);
            for i = 1:obj.nbSampledActionPerState
                dataPrepro.mergeData(data);
            end
            
            % set the qvalues
            for t = obj.numTimeSteps:-1:1
                obj.currentTimeStep = t;
                
                % compute Q_t
                obj.callDataFunction('learnQValue', dataPrepro, :, t);
                
                % compute N_{t-1}
                if(t ~= 1)
                    if(obj.useImportanceSampling)
                        obj.callDataFunction('learnNValue', data);
                    else
                        obj.callDataFunction('learnNValue', data, :, t-1);
                    end
                end
            end
        end
        
        %% called before learning policy \pi_t
        function dataPrepro = preprocessDataForTimeStep(obj, data, t)
            %if first call: create the data with replicated states
            if(t == obj.numTimeSteps)
                obj.dataVirtual = data.dataManager.getDataObject(0);
                for i = 1:obj.nbSampledActionPerState
                    obj.dataVirtual.mergeData(data);
                end
            end
            
            %learn QValue for current time-step
            obj.currentTimeStep = t;
            obj.callDataFunction('learnQValue', obj.dataVirtual, :, t);
            
            dataPrepro = obj.dataVirtual;
        end
        
        %% called after learning policy \pi_t
        function postprocessDataForTimeStep(obj, data, preprocessedData, t)
            if(t ~= 1)
                obj.currentTimeStep = t;
                
                % learn Qvalue under updated policy
                obj.callDataFunction('learnQValue', obj.dataVirtual, :, t);
                
                % compute N_{t-1}
                if(obj.useImportanceSampling)
                    obj.callDataFunction('learnNValue', data);
                else
                    obj.callDataFunction('learnNValue', data, :, t-1);
                end
            end
        end
        
    end
end


