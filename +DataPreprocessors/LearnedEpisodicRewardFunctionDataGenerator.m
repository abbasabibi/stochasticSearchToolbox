classdef LearnedEpisodicRewardFunctionDataGenerator < DataPreprocessors.VirtualDataGenerator
    
    properties
        learnedRewardFunction;
        learnedContextDistribution;
        
    end
    
    % Class methods
    methods
        function obj = LearnedEpisodicRewardFunctionDataGenerator(dataManager, sampler, learnedRewardFunction, rewardFunctionLearner, learnedContextDistribution, contextDistributionLearner)
            
            obj = obj@DataPreprocessors.VirtualDataGenerator(dataManager, sampler);
                                 
            obj.learnedRewardFunction = learnedRewardFunction;
            if (~obj.learnedRewardFunction.isSamplerFunction('sampleReturn'))
                obj.learnedRewardFunction.addDataFunctionAlias('sampleReturn', 'getExpectation');
            end
            if (exist('learnedContextDistribution', 'var'))                                
                obj.learnedContextDistribution = learnedContextDistribution;
               
            end
            
            if (~exist('rewardFunctionLearner', 'var'))
                rewardFunctionLearner = [];
            end
            
            if (~isempty(rewardFunctionLearner))
                obj.addLearner(rewardFunctionLearner);
            end
            
            if (~isempty(contextDistributionLearner))
               obj.addLearner(contextDistributionLearner);               
            end
           
                                              
        end
        
        function [] = createVirtualSampler(obj, sampler)
            obj.samplerVirtual = Sampler.EpisodeSampler(obj.dataManager, 'episodesVirtual');
            %obj.samplerVirtual.copyPoolsFromSampler(sampler);
            
            obj.samplerVirtual.setParameterPolicy(sampler.parameterPolicy);
            obj.samplerVirtual.setReturnFunction(obj.learnedRewardFunction);
            
            if (~isempty(obj.learnedContextDistribution))
                obj.samplerVirtual.setContextSampler(obj.learnedContextDistribution);
            else
                if (~isempty(sampler.contextDistribution))
                    obj.samplerVirtual.setContextSampler(sampler.contextDistribution);
                end
            end
                
        end
        
    end
end
