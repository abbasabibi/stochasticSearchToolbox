classdef RandomMedianBandwidthSelector < Learner.Learner & Data.DataManipulator
    %sets the bandwidth to a certain constant * the median of the distances
    properties
        kernelReferenceSet
    end
    
    properties(SetObservable,AbortSet)
        kernelMedianBandwidthFactor = 1.0;
        numDataPointsForBandwidthSelection = 500;
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, featureName)
            kernelLearner = Kernels.Learner.MedianBandwidthSelector(trial.dataManager, ...
                trial.(featureName), trial.([featureName, 'ReferenceSetLearner']));
        end
    end
    
    
    methods
        function obj = RandomMedianBandwidthSelector(dataManager, kernelReferenceSet)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.kernelReferenceSet = kernelReferenceSet;
            
            if ~strcmp(kernelReferenceSet.name, '')
                obj.linkProperty('kernelMedianBandwidthFactor', [kernelReferenceSet.name '_kernelMedianBandwidthFactor']);
                obj.linkProperty('numDataPointsForBandwidthSelection', [kernelReferenceSet.name '_numDataPointsForBandwidthSelection']);
            else
                obj.linkProperty('kernelMedianBandwidthFactor');
                obj.linkProperty('numDataPointsForBandwidthSelection');
            end
            
            if obj.dataManager.isDataAlias(obj.kernelReferenceSet.validityDataEntry) || obj.dataManager.isDataEntry(obj.kernelReferenceSet.validityDataEntry)
                obj.addDataManipulationFunction('setBandwidth', {obj.kernelReferenceSet.inputDataEntryReferenceSet, obj.kernelReferenceSet.validityDataEntry}, {});
            else
                obj.addDataManipulationFunction('setBandwidth', {obj.kernelReferenceSet.inputDataEntryReferenceSet}, {});
            end
            warning('This class should be merged with MedianBandwidthSelector!');
        end
        
        function setBandwidth(obj, data, valid)
            
            if exist('valid', 'var')
                data = data(logical(valid),:);
            end
            rand_idx = randi(size(data,1),obj.numDataPointsForBandwidthSelection, 1);
            data = data(rand_idx,:);
            
            isPeriodic = obj.dataManager.getPeriodicity(obj.kernelReferenceSet.inputDataEntryReferenceSet);
            
            bandWidth = zeros(1, size(data, 2));
            for i = 1:size(data,2)
                distances = repmat(data(:,i), 1, size(data,1));
                distances = (distances - distances');
                
                if (isPeriodic(i))
                    distances(distances > pi) = distances(distances > pi) - 2 * pi;
                    distances(distances < - pi) = distances(distances < - pi) + 2 * pi;
                end
                distances = distances.^2;
                
                bandWidth(i) = sqrt(median(distances(:))) * obj.kernelMedianBandwidthFactor;
            end
            if obj.kernelReferenceSet.kernel.ARD
                obj.kernelReferenceSet.kernel.setBandWidth(bandWidth);
            else
                obj.kernelReferenceSet.kernel.setBandWidth(mean(bandWidth));
            end
        end
        
        function [] = updateModel(obj, data)
            obj.callDataFunction('setBandwidth', data);
        end
        
    end
    
end

