classdef PolicyEvalVvaluePreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
    properties
        rewardToComeName;
        qLearner;
        vLearner;
        vValues; % will store the vValues of next states
        recursive;
        
        % for importance sampling
        useAllTrans;
        currentTimeStep;
        policy;
        stateDistrib;
        rewardFunction;
        sFeaturesGenerator;
        nextStatesFeatures;
    end
    
    properties (SetObservable, AbortSet)
        numTimeSteps;
    end
    
    % Class methods
    methods
        function obj = PolicyEvalVvaluePreprocessor(trial, recursive, useAllTrans, inputVars, qLearnerClass, vLearnerClass, qFApprox, vFApprox, policyEvalName, layerName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(trial.dataManager);
            obj.linkProperty('numTimeSteps');
            
            if (~exist('recursive', 'var') || isempty(recursive))
                recursive = true;
            end
            obj.recursive = recursive;
            
            if (trial.isProperty('learnerDataName')  && ~isempty(trial.learnerDataName))
                obj.dataNamePreprocessor = trial.learnerDataName;
            end
            
            if (~exist('useAllTrans', 'var') || isempty(useAllTrans))
                useAllTrans = false;
            end
            obj.useAllTrans = useAllTrans;
            
            if(obj.useAllTrans)
                obj.policy = trial.actionPolicy;
                obj.stateDistrib = trial.stateDistribution;
                obj.rewardFunction = trial.rewardFunction;
                obj.sFeaturesGenerator = trial.stateFeatures;
                obj.recursive = true;
            end
            
            if (~exist('inputVars', 'var') || isempty(inputVars))
                inputVars = {'rewardsToCome', 'SquaredStatesActions', 'SquaredStates', 'rewards'};
                if(obj.useAllTrans)
                    inputVars = {inputVars{:}, 'timeIndependentSAProba', 'states', 'actions', 'nextStates'};
                end
            end
            
            if(~iscell(inputVars))
                error('inputVars should be a cell');
            end
            
            if (~exist('qLearnerClass', 'var') || isempty(qLearnerClass))
                qLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('vLearnerClass', 'var') || isempty(vLearnerClass))
                vLearnerClass = @Learner.SupervisedLearner.LinearFeatureFunctionMLLearner;
            end
            
            if (~exist('qFApprox', 'var') || isempty(qFApprox))
                qFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, {inputVars{1}}, {inputVars{2}}, 'qApproximator');
            end
            
            if (~exist('vFApprox', 'var') || isempty(vFApprox))
                vFApprox = Functions.FunctionLinearInFeatures(obj.dataManager, {inputVars{1}}, {inputVars{3}}, 'vApproximator');
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
            
            tempQOutput = 'tempQValue';
            obj.dataManager.addDataEntry([layerName, '.', tempQOutput], 1);
            
            obj.addDataManipulationFunction('copyQValue', {tempQOutput, 'rewardsToCome'}, {policyEvalName}); %rewardsToCome for debug only. delete later
            obj.addDataManipulationFunction('computeQValue', inputVars, {tempQOutput});
        end
        
        function [qvalue] = computeQValue(obj, rewardsToCome, stateActionFeatures, stateFeatures, rewards, varargin)
            % varargin should either be empty (no importance sampling)
            % or contain: state-action-probas, states, actions and state-probas.
            if(isempty(obj.vValues))
                obj.vValues = zeros(size(rewards, 1), 1);
            end
            
            
            % learning qValue
            if(obj.useAllTrans)
                states = varargin{2};
                actions = varargin{3};
                if(isempty(obj.nextStatesFeatures))
                    nextStates = varargin{4};
                    obj.nextStatesFeatures = obj.sFeaturesGenerator.getFeaturesInternal(size(nextStates, 1), nextStates);
                end
                rewards = obj.rewardFunction.rewardFunction(states, actions, obj.currentTimeStep * ones(size(states, 1), 1));
                currentPolicy = obj.policy.getDistributionForTimeStep(obj.currentTimeStep);
                currentStateDistrib = obj.stateDistrib.getDistributionForTimeStep(obj.currentTimeStep);
                qWeighting =  exp(currentStateDistrib.getDataProbabilities([], states)...
                    + currentPolicy.getDataProbabilities(states, actions))...
                    ./ varargin{1};
            else
                qWeighting = ones(size(rewards, 1), 1);
            end
            obj.qLearner.learnFunction(stateActionFeatures, rewards + obj.vValues, qWeighting);
            qvalue = obj.qLearner.functionApproximator.getExpectation(size(stateActionFeatures, 1), stateActionFeatures);
            
            % learning vValue
%             if(obj.useAllTrans)
%                 vWeighting = exp(currentStateDistrib.getDataProbabilities([], states)) ./ varargin{2};
%             else
%                 vWeighting = ones(size(rewards, 1), 1);
%             end

            if(obj.recursive)
                obj.vLearner.learnFunction(stateFeatures, rewards + obj.vValues, qWeighting);
            else
                obj.vLearner.learnFunction(stateFeatures, rewardsToCome, qWeighting);
            end
            
            if(obj.useAllTrans)
                obj.vValues = obj.vLearner.functionApproximator.getExpectation(size(obj.nextStatesFeatures, 1), obj.nextStatesFeatures);
            else
                obj.vValues = obj.vLearner.functionApproximator.getExpectation(size(stateFeatures, 1), stateFeatures);
            end
        end
        
        function [qvalue] = copyQValue(obj, tempq, rewardsToCome)
            qvalue = tempq;
            disp(var(qvalue - rewardsToCome)/var(rewardsToCome)); %%% 1-r2: unexplained variance/normalized mean square error
        end
        
        function data = preprocessData(obj, data)
            obj.vValues = []; % stores the vValues of last iteration
            obj.nextStatesFeatures = [];
            for t = obj.numTimeSteps:-1:1
                if(obj.useAllTrans) % with importance sampling
                    obj.currentTimeStep = t;
                    obj.callDataFunction('computeQValue', data);
                    obj.callDataFunction('copyQValue', data, :, t);
                else
                    obj.callDataFunction('computeQValue', data, :, t);
                    obj.callDataFunction('copyQValue', data, :, t);
                end
            end
        end        
    end
end
