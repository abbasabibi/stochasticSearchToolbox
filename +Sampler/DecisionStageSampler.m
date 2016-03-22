classdef DecisionStageSampler < Sampler.SequentialSampler
    properties (SetAccess = protected, GetAccess = public)
        stepSampler
        
        contextDistribution
        returnSampler
        parameterPolicy
    end
    
    properties
        
    end
    
    methods
        function [obj] = DecisionStageSampler(dataManager, stageSamplerName, stepSampleName)
            
            if (~exist('stageSamplerName', 'var'))
                stageSamplerName = 'decisionStages';
            end
            
            if (~exist('stepSampleName', 'var'))
                stepSampleName = 'steps';
            end
            
            if (exist('dataManager', 'var'))
                dataManagerStage = dataManager.getDataManagerForName(stageSamplerName);
            else
                dataManagerStage = [];
            end
            
            if (~exist('dataManager', 'var') || isempty(dataManagerStage))
                dataManagerStage = Data.DataManager(stageSamplerName);
            end
            
            obj = obj@Sampler.SequentialSampler(dataManagerStage,  stageSamplerName, 'decisionSteps');
            obj.createStepSampler(dataManagerStage, stepSampleName);
            obj.dataManager.setSubDataManager(obj.stepSampler.getDataManagerForSampler());
            obj.dataManager.addDataAlias('contexts', {});
            
            obj.addSamplerPool('InitialStage', 1);
            
            obj.addSamplerPool('ParameterPolicy', 10);
            obj.addSamplerPool('SubSteps', 50);
            obj.addSamplerPool('FinalReward', 60);
            obj.addSamplerPool('Return', 70);
            obj.addSamplerPool('EndStage', 90);
            
            obj.addElementsForTransition('nextContexts', 'contexts');
            
            obj.dataManager.addDataEntry('decisionSteps', 1);
            obj.addSamplerFunctionToPool('SubSteps', stepSampleName, obj.stepSampler);
        end
        
        function [] = initObject(obj)
            obj.dataManager.addDataEntry('nextContexts', obj.dataManager.getNumDimensions('contexts'));
        end
        
        function [] = createStepSampler(obj, dataManager, stepSamplerName)
            obj.stepSampler = Sampler.StepSampler([], stepSamplerName);
        end
        
        function [] = copyPoolsFromSampler(obj, sampler)
            obj.copyPoolsFromSampler@Sampler.IndependentSampler(sampler);
            obj.stepSampler.copyPoolsFromSampler(sampler.stepSampler);
        end
        
        function [dataManager] = getStepDataManager(obj)
            dataManager = obj.stepSampler.getDataManagerForSampler();
        end
        
        function [stepSampler] = getStepSampler(obj)
            stepSampler = obj.stepSampler;
        end
        
        function setStepSampler(obj, stepSampler)
            obj.stepSampler = stepSampler;
        end
        
        function [] = setEndStateTransitionSampler(obj, transitionSampler, samplingFunctionName)
            if ( ~exist('samplingFunctionName', 'var') || isempty(samplingFunctionName) )
                samplerName = 'sampleStageTransition';
            end                       
            obj.addSamplerFunctionToPool('EndStage', samplerName, transitionSampler, -1);
        end
        
        function [] = setActionPolicy(obj, actionPolicy)
            obj.stepSampler.setPolicy(actionPolicy);
        end
        
        function [] = setInitialStateSampler(obj, initStateSampler)
            obj.stepSampler.setInitialStateSampler(initStateSampler);
        end
        
        function [] = setTransitionFunction(obj, transitionFunction)
            obj.stepSampler.setTransitionFunction(transitionFunction);
        end
        
        function [] = setRewardFunction(obj, rewardFunction)
            obj.stepSampler.setRewardFunction(rewardFunction);
            
            if (rewardFunction.isSamplerFunction('sampleFinalReward'))
                obj.setFinalRewardFunction(rewardFunction);
            end
        end
        
        function [] = setReturnFunction(obj, rewardSampler, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleReturn';
            end
            if (strcmp(samplerName, 'sampleReturn'))
                obj.returnSampler = rewardSampler;
            end
            
            obj.addSamplerFunctionToPool('Return', samplerName, rewardSampler, -1);
        end
        
        function [] = setFinalRewardFunction(obj, rewardSampler, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleFinalReward';
            end
            obj.addSamplerFunctionToPool('FinalReward', samplerName, rewardSampler, -1);
        end
        
        function [] = setParameterPolicy(obj, parameterSampler, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleParameter';
            end
            if (strcmp(samplerName, 'sampleParameter'))
                obj.parameterPolicy = parameterSampler;
            end
            
            obj.addSamplerFunctionToPool('ParameterPolicy', samplerName, parameterSampler, -1);
        end
        
        function [numSamples] = getNumSamples(obj, data, varargin)
            numSamples = obj.isActiveSampler.toReserve;
            numSamples(2) = obj.stepSampler.isActiveSampler.toReserve();
        end
        
        
    end
    
    methods (Access = protected)
        function [] = initSamples(obj, data, varargin)
            %initStates = data.getDataEntry('initStates', varargin{1:end-1});
            %data.setDataEntry('states', initStates, varargin{:});
            %data.setDataEntry('timeSteps', 1, varargin{:});
            obj.createSamplesFromPool('InitialStage', data, varargin{:});
            numElements = data.getNumElementsForIndex(length(varargin),varargin{:});
            data.setDataEntry('decisionSteps',  ones(numElements,1) , varargin{:});
        end
        
        function [] = createSamplesForStep(obj, data, varargin)
            obj.createSamplesFromPoolsWithPriority(10, 80, data, varargin{:});
            layerIndexEndStage = [varargin, -1];
            
            obj.createSamplesFromPool('EndStage', data, layerIndexEndStage{:});
        end
        
        function [] = endTransition(obj, data, varargin)
            layerIndex = varargin;
            layerIndexNew = layerIndex;
            % layerIndexEndStage accesses last index of the next layer of
            % the current decision stage
            
            layerIndexNew{end} = layerIndexNew{end} + 1;
            obj.endTransition@Sampler.SequentialSampler(data, varargin{:});
            numElements = data.getNumElementsForIndex(numel(layerIndexNew), layerIndexNew{:});
            data.setDataEntry('decisionSteps', ones(numElements,1) * layerIndexNew{end}, layerIndexNew{:});
        end
    end
end