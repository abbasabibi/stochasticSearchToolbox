classdef GenerateGridPreprocessor < DataPreprocessors.VirtualDataGenerator
    %GRIDPREPROCESSOR Creates a grid sampler 
    % generates s-a-s-r tuples based on independently samples
    % (s,a) pairs
    
    properties
        initsampler
    end
    
    methods
        function obj = GenerateGridPreprocessor(dataManager, sampler, initsampler)
            obj = obj@DataPreprocessors.VirtualDataGenerator(dataManager, sampler);
            obj.initsampler = initsampler; 
        end
        function [] = createVirtualSampler(obj, sampler)
            
            stepSampler = Sampler.GridStepSampler(obj.dataManager.getDataManagerForName('steps'), obj.initsampler.nsamples);
            stepSampler.copySamplerFunctionsFromPool(sampler.stepSampler, 'TransitionSampler');
            stepSampler.copySamplerFunctionsFromPool(sampler.stepSampler, 'RewardSampler');
            %stepSampler.setTransitionFunction(env, 'sampleNextState');
            %stepSampler.setRewardFunction(env, 'sampleReward');
            stepSampler.setInitStateActionSampler( obj.initsampler,'sampleInitStateAction');
            
            obj.samplerVirtual = Sampler.EpisodeSampler(obj.dataManager,'gridEpisodes');
            obj.samplerVirtual.addSamplerFunction('Episodes', 'steps', stepSampler); 
            
            obj.samplerVirtual.numSamples = 1;
        end
    end
    
end

