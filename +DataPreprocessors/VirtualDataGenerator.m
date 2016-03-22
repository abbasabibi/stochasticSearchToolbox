classdef VirtualDataGenerator < DataPreprocessors.DataPreprocessor
    
    properties
        dataManager;
        samplerVirtual;                      
        virtualData;        
        learners = {};
        
        originalSampler
        
        
    end
    
    % Class methods
    methods
        function obj = VirtualDataGenerator(dataManager, sampler)
            
            obj = obj@DataPreprocessors.DataPreprocessor();
            
            obj.dataManager = dataManager;
            obj.originalSampler = sampler;
            
            if (~Common.Settings().hasProperty('numSamplesEpisodesVirtual'))
                Common.Settings().setProperty('numSamplesEpisodesVirtual', 1000);
            end
            
            obj.dataNamePreprocessor = 'virtualData';
        end
        
        function [] = initObject(obj)
            obj.createVirtualSampler(obj.originalSampler);
        end
        
        function [] = addLearner(obj, learner)
            obj.learners{end + 1} = learner;
        end
        
        function [newData] = preprocessData(obj, data)
            if (isempty(obj.virtualData))
                obj.virtualData = obj.dataManager.getDataObject(0);
            end
            learningModelTime = tic;
            for i = 1:length(obj.learners)
                obj.learners{i}.updateModel(data);
            end
            fprintf('Time To Learn the Model: %f\n', toc(learningModelTime));
            samplingTime = tic;            
            obj.samplerVirtual.createSamples(obj.virtualData);
            fprintf('Time To Sample from Learned the Model: %f\n', toc(samplingTime));
            
            newData = obj.virtualData;
            obj.virtualData = [];
        end
        
    end
    
    methods (Abstract)
        [] = createVirtualSampler(obj, sampler);
        
    end
end
