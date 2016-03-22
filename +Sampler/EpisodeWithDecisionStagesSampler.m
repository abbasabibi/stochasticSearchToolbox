classdef EpisodeWithDecisionStagesSampler < Sampler.IndependentSampler
    properties (SetAccess = protected, GetAccess = public)
         stageSampler
    end
    
    properties

    end
    
    methods
        function [obj] = EpisodeWithDecisionStagesSampler(dataManager, samplerNameEpisodes, samplerNameSteps)
            if (~exist('samplerNameEpisodes', 'var'))
                samplerNameEpisodes = 'episodes';
            end
            
            if (~exist('samplerNameSteps', 'var'))
                samplerNameSteps = 'decisionStages';
            end     
            
            if (~exist('dataManager', 'var'))
                dataManager = Data.DataManager(samplerNameEpisodes);
            end
            
            obj = obj@Sampler.IndependentSampler(dataManager, samplerNameEpisodes);
            obj.createStageSampler(dataManager, samplerNameSteps);
            obj.dataManager.setSubDataManager(obj.stageSampler.getDataManagerForSampler());
            
            %obj.dataManager.addDataAlias('initialContexts', {});
            obj.dataManager.finalizeDataManager();
            
            obj.addSamplerPool('InitEpisode', 1);
            obj.addSamplerPool('Episodes', 5);            
            obj.addSamplerPool('FinalReturn', 7);
            
            obj.addSamplerFunctionToPool('Episodes', samplerNameSteps, obj.stageSampler);                                       
        end
        
        function initObject(obj)
            obj.stageSampler.initObject();
        end
        
        function [] = setContextSampler(obj, contextSampler, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleContext';
            end
            
            obj.addSamplerFunctionToPool( 'InitEpisode', samplerName, contextSampler,- 1);
        end
        
        function [dataManager] = getEpisodeDataManager(obj)
            dataManager = obj.dataManager;
        end
        
        function [dataManager] = getStageDataManager(obj)
            dataManager = obj.stageSampler.dataManager;
        end
        
        function [dataManager] = getStepDataManager(obj)
            dataManager = obj.stageSampler.stepSampler.dataManager;
        end
      
        function [] = createStageSampler(obj, varargin)
            obj.stageSampler = Sampler.DecisionStageSampler(varargin{:});            
        end
        
        function [] = copyPoolsFromSampler(obj, sampler)
            obj.copyPoolsFromSampler@Sampler.EpisodeSampler(sampler);
            obj.stageSampler.copyPoolsFromSampler(sampler.stageSampler);
        end
        
        function [stageSampler] = getStageSampler(obj)
            stageSampler = obj.stageSampler;
        end
        
        function setStepSampler(obj, stageSampler)
            obj.stageSampler = stageSampler;
        end                
        
                                        
        function [] = setActionPolicy(obj, actionPolicy)
            obj.stageSampler.setPolicy(actionPolicy);
        end
        
        function [] = setInitialStateSampler(obj, initStateSampler)
            obj.stageSampler.setInitialStateSampler(initStateSampler);
        end
        
        function [] = setTransitionFunction(obj, transitionFunction)
            obj.stageSampler.setTransitionFunction(transitionFunction);
        end               
        
        function [] = setRewardFunction(obj, rewardFunction)
            obj.stageSampler.setRewardFunction(rewardFunction);                      
        end
        
        function [numSamples] = getNumSamples(obj, data, varargin)
            numSamples = [obj.getNumSamples@Sampler.IndependentSampler(data, varargin{:}), obj.stageSampler.getNumSamples()];            
        end
        
    end
end