classdef PolicyEvaluationDiscreteUniformActionSamplesPreProcessor < PolicyEvaluation.PolicyEvaluationPreProcessor
    
    properties(SetAccess=protected)
        dataManager
        
        minRange
        maxRange
        
        actionVariable
        
        importanceSampler
        stateFeatureName
        
    end
    
    properties (SetObservable,AbortSet)
        iterationsForStateDistribution=5;
    end
    
    methods (Static)
        function obj = CreateFromTrial(trial)
            if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling)
                obj = PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction, trial.actionPolicy, trial.stateFeatures.outputName, trial.importanceSampler);
            else
                obj = PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor(trial.dataManager, trial.policyEvaluationLearner, trial.policyEvaluationFunction, trial.actionPolicy, trial.stateFeatures.outputName);
            end
        end
    end
    
    methods
        %%
        function obj = PolicyEvaluationDiscreteUniformActionSamplesPreProcessor(dataManager, policyEvaluationLearner, valueFunction, actionPolicy, stateFeatureName, importanceSampler)
            
            obj = obj@PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, policyEvaluationLearner, valueFunction);
            obj.dataManager = dataManager;
            
            if (exist('importanceSampler', 'var'))
                obj.importanceSampler =importanceSampler;
            end
            
            if (exist('stateFeatureName', 'var'))
                obj.stateFeatureName = stateFeatureName;
            else
                obj.stateFeatureName = 'states';
            end
            
            
            obj.minRange = dataManager.getMinRange(actionPolicy.outputVariable);
            obj.maxRange = dataManager.getMaxRange(actionPolicy.outputVariable);
            obj.actionVariable = actionPolicy.outputVariable;
            
            obj.linkProperty('iterationsForStateDistribution');
        end
        
        function [] = updateModel(obj, data)
            
            obj.policyEvaluationLearner.updateModel(data);
            
            additionalData = obj.dataManager.getDataObject(0);
            
            astates = data.getDataEntry(obj.stateFeatureName);
            
            iterNr = data.getDataEntry('iterationNumber');
            timeSteps = data.getDataEntry('timeSteps');
            idx = find(timeSteps==0 | timeSteps==1);
            %iter = zeros(size(timeSteps));
            %iter(idx)=1;
            %iter = cumsum(iter);
            %iter = floor(iter/(max(iter+1)/max(iterNr)))+1;
            %iterWeight = abs(max(iterNr)-(1:max(iterNr)));
            %iterWeight = 0.9.^iterWeight;
            
            %
            samples = numel(iterNr(iterNr>(max(iterNr)-obj.iterationsForStateDistribution)));
            minIdx = idx(max(1,end-samples+1));
            astates = astates(minIdx:end,:);
            
            states = unique(astates,'rows');
            [~,sidx] = ismember(astates,states,'rows');
            stateDist = hist(sidx,size(states,1))';
            
            %stateIterDist = zeros(max(iterNr),size(states,1));
            %for i=1:max(iterNr)
            %    stateIterDist(i,:) = hist(sidx(iter==i),size(states,1));
            %end
            %stateDist = (iterWeight*stateIterDist)';
            numActions = obj.maxRange-obj.minRange+1;
            additionalData.reserveStorage([1, size(states,1) * (numActions)]);
            additionalStates = repmat(states,numActions, 1);
            additionalActions = (obj.minRange:obj.maxRange)';
            additionalActions = kron(additionalActions,ones(size(states,1), 1));
            
            additionalData.setDataEntry(obj.stateFeatureName, additionalStates);
            if (additionalData.isDataEntry([obj.stateFeatureName, 'Tag']))
                additionalData.setDataEntry([obj.stateFeatureName, 'Tag'], ones(size(additionalStates,1),1));
            end
            
            additionalData.setDataEntry(obj.actionVariable, additionalActions);
            
            obj.valueFunction.callDataFunction('getExpectation', additionalData);
            
            if (~isempty(obj.importanceSampler))
                obj.importanceSampler.preprocessData(additionalData);
                weights = additionalData.getDataEntry('importanceWeights');
                weights = weights * length(stateDist);
                weights = weights .* repmat(stateDist,numActions, 1);
                %weights = weights/sum(weights);
                additionalData.setDataEntry('importanceWeights',weights);
            end
            obj.updateLearner(additionalData);
        end
        
      
    end
end

