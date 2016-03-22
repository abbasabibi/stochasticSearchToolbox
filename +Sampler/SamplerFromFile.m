classdef SamplerFromFile < Sampler.SamplerInterface
% Loads a data structure from file. The data structure has to have
% the same format as the internal data structure used from the Data class.
% Can be used for loading data for imitation learning

    properties(SetObservable,AbortSet)
        numImitationEpisodes    = 10;
        numImitationSteps       = inf;
        
    end
    
    properties (Access = protected)
        fileName
        dataEntries
        
        storedData;
        offsetEpisodes = 0;
    end
    
    methods       
        function [obj] = SamplerFromFile(dataManager, fileName)
            obj = obj@Sampler.SamplerInterface(dataManager);
            obj.fileName = fileName;    
                              
            obj.linkProperty('numImitationEpisodes');
            obj.linkProperty('numImitationSteps');

            load(obj.fileName);
            obj.storedData = data;
        end

        
        function [] = createSamples(obj, newData, varargin)
        
            if (length(obj.numImitationEpisodes) > 1)
                numEpisodes = obj.numImitationEpisodes(min(obj.iterIdx, length(obj.numImitationEpisodes)));
            else
                numEpisodes = obj.numImitationEpisodes;
            end
            
            indexData = obj.offsetEpisodes + [1, numEpisodes];
            
            if (indexData(2) > obj.storedData.getNumElements())
                warning('Requesting more data points than available in the file!\n');
                indexData(2) = obj.storedData.getNumElements();
            end
            indexData(1) = min(indexData(2), indexData(1));
            
            tempData = obj.storedData.cloneDataSubSet(indexData(1):indexData(2));
            obj.offsetEpisodes = obj.offsetEpisodes + numEpisodes;
            
            newData.copyValuesFromDataStructure(tempData.dataStructure);            
            
            if (isfield(newData, 'steps') && ~isinf(obj.numImitationSteps))
                [~, numStepsPerEpisode] = newData.getNumElementsForDepth(2);
                for i = 1:newData.getNumElementsForDepth(1)
                    newData.reserveStorage(min(numStepsPerEpisode(i), obj.numImitationSteps), i);
                end
            end
        end
        
        function data = preprocessData(obj, data)
            obj.createSamples(data);
        end
        
        function dataManager = getEpisodeDataManager(obj)
            dataManager = obj.storedData.getDataManager();
        end
        
    end
    
end