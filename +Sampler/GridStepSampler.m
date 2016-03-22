classdef GridStepSampler < Sampler.IndependentSampler

    properties
        nsamples
    end
    
    methods
        function [obj] = GridStepSampler(dataManager, nsamples, varargin)
            
            if (~exist('dataManager', 'var'))
                dataManager = Data.DataManager('steps');
            else
                dataManager = dataManager.getDataManagerForName('steps');
            end
            obj = obj@Sampler.IndependentSampler(dataManager, 'steps');
            obj.addSamplerPool('InitStateAction', 2);
            obj.addSamplerPool('TransitionSampler', 5);
            obj.addSamplerPool('RewardSampler', 8);
            obj.nsamples = nsamples;
        end
        
        %% create samples
        function [] = createSamples(obj, data, varargin)
            layerIndex = varargin;

            reservedStorage = prod(obj.nsamples);
            data.reserveStorage(reservedStorage, layerIndex{:});
            data.resetFeatureTags();

            % append index           
            activeIndex = layerIndex;
            activeIndex{length(varargin) + 1} = ':'; %1:reservedStorage;

            %create the samples
            obj.createSamplesFromPool('InitStateAction', data, activeIndex{:});

            obj.createSamplesFromPool('TransitionSampler', data, activeIndex{:});
            obj.createSamplesFromPool('RewardSampler', data, activeIndex{:});
        end
        
        %%  Sampler Pools add, flush, set ( flush and set )
        function [] = setTransitionFunction(obj, transitionFunction, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleNextState';
            end
            obj.addSamplerToPoolInternal( 'TransitionSampler', samplerName, transitionFunction, 1);            
        end
        
        
        function [] = setRewardFunction(obj, rewardFunction, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleReward';
            end
            obj.addSamplerToPoolInternal( 'RewardSampler', samplerName, rewardFunction, 1);            
        end
        
        function setInitStateActionSampler(obj, initSampler,samplerName)
            obj.addSamplerToPoolInternal( 'InitStateAction', samplerName, initSampler, 1);       
        end
        
        
        function [] = addTransitionFunction(obj, transitionFunction, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleNextState';
            end
            obj.addSamplerToPoolInternal( 'TransitionSampler', samplerName, transitionFunction);            
        end
        

        
        function [] = addRewardFunction(obj, rewardFunction, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleReward';
            end
            obj.addSamplerToPoolInternal( 'RewardSampler', samplerName, rewardFunction);            
        end
        
       function addInitStateActionSampler(obj, initSampler)
            obj.addSamplerToPoolInternal( 'InitStateAction', 'sampleInitStateAction', initSampler);       
        end
        
        
        function [] = flushTransitionFunction(obj)
            obj.flushSamplerPool('TransitionSampler');
        end
        
        function [] = flushPolicy(obj)
            obj.flushSamplerPool('Policy');      
        end
        
        function [] = flushRewardFunction(obj)
            obj.flushSamplerPool('RewardSampler');        
        end
        
        function [] = flushInitialStateSampler(obj)
            obj.flushSamplerPool('InitSamples');      
        end   
        
        %%
    end
    
    methods (Access = protected)
        function [] = endTransition(obj, data, varargin)
            layerIndex = varargin;
            nextState = data.getDataEntry(obj.transitionElementOldStep, layerIndex{:});
            numElements = size(nextState,1);
            layerIndex{end} = layerIndex{end} + 1;
            data.setDataEntry(obj.transitionElementNewStep, nextState, layerIndex{:});
            data.setDataEntry('timeSteps', ones(numElements,1) * layerIndex{end}, layerIndex{:});
        end
        
        function [] = initSamples(obj, data, varargin)
            %initStates = data.getDataEntry('initStates', varargin{1:end-1});
            %data.setDataEntry('states', initStates, varargin{:});
            %data.setDataEntry('timeSteps', 1, varargin{:});
            obj.createSamplesFromPool('InitSamples', data, varargin{:});
            data.setDataEntry('timeSteps', 1, varargin{:});
        end
        
        function [] = createSamplesForStep(obj, data, varargin)
            obj.createSamplesFromPool('Policy', data, varargin{:});
            obj.createSamplesFromPool('TransitionSampler', data, varargin{:});
            obj.createSamplesFromPool('RewardSampler', data, varargin{:});
        end
        

         
    end
    
end