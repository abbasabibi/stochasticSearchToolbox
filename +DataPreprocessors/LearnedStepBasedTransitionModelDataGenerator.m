classdef LearnedStepBasedTransitionModelDataGenerator < DataPreprocessors.VirtualDataGenerator
    
    properties
       
        learnedTransitionFunction;
        learnedContextDistribution;
        learnedInitialStateDistribution;
        
    end
    
    % Class methods
    methods
        function obj = LearnedStepBasedTransitionModelDataGenerator(dataManager, sampler, learnedTransitionFunction, learnedContextDistribution, learnedInitialStateDistribution)
            
            obj = obj@DataPreprocessors.VirtualDataGenerator(dataManager, sampler);
                       
            obj. originalSampler = sampler;
            obj.learnedTransitionFunction = learnedTransitionFunction;
            
            if (exist('learnedContextDistribution', 'var'))                                
                obj.learnedContextDistribution = learnedContextDistribution;
            end
            if (exist('learnedInitialStateDistribution', 'var'))                                
                obj.learnedInitialStateDistribution = learnedInitialStateDistribution;
            end
            
               
            
        end
        
        function [] = createVirtualSampler(obj, sampler)
            obj.samplerVirtual = Sampler.EpisodeWithStepsSampler(obj.dataManager, 'episodesVirtual');
            obj.samplerVirtual.copyPoolsFromSampler(sampler);
            
            obj.samplerVirtual.stepSampler.flushTransitionFunction();
            obj.samplerVirtual.setTransitionFunction(obj.learnedTransitionFunction);
            
            if (~isempty(obj.learnedContextDistribution))
                obj.samplerVirtual.setContextSampler(obj.learnedContextDistribution);
            end
            
            if (~isempty(obj.learnedInitialStateDistribution))
                obj.samplerVirtual.setInitialStateSampler(obj.learnedInitialStateDistribution);
            end        
        end          
    end
end
