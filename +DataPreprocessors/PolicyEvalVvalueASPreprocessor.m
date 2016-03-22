classdef PolicyEvalVvalueASPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %%% AS: Additional Samples
    properties
        qLearner;
        vLearner;
        vValues; % will store the vValues of next states
        
        % for importance sampling
        useImportanceSampling;
        currentTimeStep;
        policy;
        importanceWeights;
        stateDistrib;
        rewardFunction;
        sFeaturesGenerator;
        saFeaturesGenerator;
        nextStatesFeatures;
        
        % for dynamic programming
        useDynamicProgramming;
        dataVirtual;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
        nbSampledActionPerState;
    end
    
    % Class methods
    methods
        function obj = PolicyEvalVvalueASPreprocessor(trial, useImportanceSampling, learnerDataName, inputLearnQ, inputLearnV, qLearnerClass, vLearnerClass, qFApprox, vFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('nbSampledActionPerState');
            
            obj.policy = trial.actionPolicy;
            obj.stateDistrib = trial.stateDistribution;
            obj.rewardFunction = trial.rewardFunction;
            obj.sFeaturesGenerator = trial.stateFeatures;
            obj.saFeaturesGenerator = trial.stateActionFeatures;
            
            if (exist('learnerDataName', 'var') && ~isempty(learnerDataName))
                obj.dataNamePreprocessor = learnerDataName;
            end
            
            if (~exist('useImportanceSampling', 'var') || isempty(useImportanceSampling))
                useImportanceSampling = false;
            end
            obj.useImportanceSampling = useImportanceSampling;
            
            
            if (~exist('inputLearnQ', 'var') || isempty(inputLearnQ))
                inputLearnQ = {'states', 'actions', 'rewards', 'nextStates', 'SquaredStatesActions'};
            end
            
            if (~exist('inputLearnV', 'var') || isempty(inputLearnV))
                inputLearnV = {'states', 'actions', 'rewards', 'SquaredStates', 'rewardWeighting'};
            end
            
            if(~iscell(inputLearnQ))
                error('inputLearnQ should be a cell');
            end
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('vLearnerClass', 'var') || isempty(vLearnerClass))
                vLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, inputLearnQ(3), inputLearnQ(5), 'qApproximator');
            end
            
            if (~exist('vFApprox', 'var') || isempty(vFApprox))
                vFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, inputLearnV(3), inputLearnV(4), 'vApproximator');
            end
            
            
            if (~exist('policyEvalName', 'var'))
                policyEvalName = 'qValue';
            end
            
            if (~exist('layerName', 'var'))
                layerName = 'steps';
            end
            
            qFApprox.initObject();
            obj.qLearner = qLearnerClass(obj.dataManager, qFApprox);
            
            vFApprox.initObject();
            obj.vLearner = vLearnerClass(obj.dataManager, vFApprox);
            
            obj.dataManager.addDataEntry([layerName, '.', policyEvalName], 1);
            
            obj.addDataManipulationFunction('setQValue', {'states'}, {policyEvalName, 'actions'});
            obj.addDataManipulationFunction('learnQValue', inputLearnQ, {});
            obj.addDataManipulationFunction('learnVValue', inputLearnV, {});
            if(obj.useImportanceSampling)
                obj.addDataManipulationFunction('computeImportanceWeights',...
                    {'states', 'actions', 'timeIndependentSAProba'}, {});
            end
            obj.useDynamicProgramming = false;
        end
        
        function computeImportanceWeights(obj, states, actions, timeIndependentSAProba)
            % importance sampling weights
            currentPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
            currentStateDistrib = obj.stateDistrib.getDistributionForTimeStep(obj.currentTimeStep);
            obj.importanceWeights =  exp(currentStateDistrib.getDataProbabilities([], states)...
                + currentPolicy.getDataProbabilities(states, actions))...
                ./ timeIndependentSAProba;
        end
        
        function learnQValue(obj, states, actions, rewards, nextStates, stateActionFeatures)
            % first iteration: initializations
            if(obj.currentTimeStep == obj.numTimeSteps)
                obj.vValues = zeros(size(states, 1), 1);
                if(obj.useImportanceSampling)
                    obj.nextStatesFeatures = obj.sFeaturesGenerator.getFeaturesInternal(size(nextStates, 1), nextStates);
                end
            end
            
            % learning qValue
            if(obj.useImportanceSampling)
                currRewards = obj.rewardFunction.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
                obj.qLearner.learnFunction(stateActionFeatures, currRewards + obj.vValues, obj.importanceWeights);
            else
                obj.qLearner.learnFunction(stateActionFeatures, rewards + obj.vValues);
            end
        end
        
        function learnVValue(obj, states, actions, rewards, stateFeatures, rewardWeighting)
            % learning vValue (used in next time-step)
            if(obj.useImportanceSampling)
                currRewards = obj.rewardFunction.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
                obj.vLearner.learnFunction(stateFeatures, currRewards + obj.vValues, obj.importanceWeights);
                obj.vValues = obj.vLearner.functionApproximator.getExpectation(size(obj.nextStatesFeatures, 1), obj.nextStatesFeatures);
            else
                if(obj.useDynamicProgramming)
                    obj.vLearner.learnFunction(stateFeatures, rewards + obj.vValues, rewardWeighting);
                else
                    obj.vLearner.learnFunction(stateFeatures, rewards + obj.vValues);
                end
                obj.vValues = obj.vLearner.functionApproximator.getExpectation(size(stateFeatures, 1), stateFeatures);
            end
        end
        
        function [qvalue, actions] = setQValue(obj, states)
            currentPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
            actions = currentPolicy.sampleFromDistribution(size(states, 1), states);
            virtualSaFeatures = obj.saFeaturesGenerator.getFeaturesInternal(size(states, 1), [states actions]);
            qvalue = obj.qLearner.functionApproximator.getExpectation(size(virtualSaFeatures, 1), virtualSaFeatures);
        end
        
        function dataVirtual = preprocessData(obj, data)
            % create a copy of the data
            dataVirtual = data.dataManager.getDataObject(0);
            for i = 1:obj.nbSampledActionPerState
                dataVirtual.mergeData(data);
            end
            
            % set the qvalues
            for t = obj.numTimeSteps:-1:1
                obj.currentTimeStep = t;
                if(obj.useImportanceSampling)
                    obj.callDataFunction('computeImportanceWeights', data);
                    obj.callDataFunction('learnQValue', data);
                    obj.callDataFunction('learnVValue', data);
                else
                    obj.callDataFunction('learnQValue', data, :, t);
                    obj.callDataFunction('learnVValue', data, :, t);
                end
                obj.callDataFunction('setQValue', dataVirtual, :, t);
            end
        end
        
        function dataPrepro = preprocessDataForTimeStep(obj, data, t)
            % create a copy of the data
            if(t == obj.numTimeSteps)
                obj.dataVirtual = data.dataManager.getDataObject(0);
                for i = 1:obj.nbSampledActionPerState
                    obj.dataVirtual.mergeData(data);
                end
            end
            
            obj.currentTimeStep = t;
            if(obj.useImportanceSampling)
                error([mfilename, ': Importance sampling not possible with dyn prog']);
            else
                obj.callDataFunction('learnQValue', data, :, t);
            end
            obj.callDataFunction('setQValue', obj.dataVirtual, :, t);
            
            dataPrepro = obj.dataVirtual;
        end
        
        function postprocessDataForTimeStep(obj, data, preprocessedData, t)
            obj.currentTimeStep = t;
            obj.useDynamicProgramming = true;
            rewardWeighting = preprocessedData.getDataEntry('rewardWeighting', :, t);            
            data.setDataEntry('rewardWeighting', rewardWeighting, :, t);             
            if(obj.useImportanceSampling)
                error([mfilename, ': Importance sampling not possible with dyn prog']);
            else
                obj.callDataFunction('learnVValue', data, :, t);
            end
            obj.useDynamicProgramming = false;
        end
        
    end
end
