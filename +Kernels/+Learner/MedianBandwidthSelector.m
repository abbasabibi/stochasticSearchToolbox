classdef MedianBandwidthSelector < Learner.Learner
    %sets the bandwidth to a certain constant * the median of the distances
    properties
        kernel
        referenceSet
        referenceSetLearner
        
        updateReferenceSet = true;
        dataManager
    end
    
    properties(SetObservable,AbortSet)
        kernelMedianBandwidthFactor = 1.0;
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, featureName)
            kernelLearner = Kernels.Learner.MedianBandwidthSelector(trial.dataManager, ... 
            trial.(featureName), trial.([featureName, 'ReferenceSetLearner']), trial.([featureName(1:end-6), 'Features']));
        end
    end
    
    
    methods
        function obj = MedianBandwidthSelector(dataManager, kernel, referenceSetLearner, referenceSet)
            obj = obj@Learner.Learner();
            obj.kernel = kernel;
            obj.referenceSet = referenceSet;
            obj.dataManager = dataManager;
            obj.referenceSetLearner = referenceSetLearner;
            if (isa(referenceSet, 'char'))
                obj.linkProperty('kernelMedianBandwidthFactor', ['kernelMedianBandwidthFactor', upper(referenceSet(1)), referenceSet(2:end)]);
            else
                obj.linkProperty('kernelMedianBandwidthFactor', ['kernelMedianBandwidthFactor', referenceSet.name]);
            end
            
        end
        
        function [] = setWeightName(obj, weightName)
            if (~isempty(obj.referenceSetLearner))
                obj.referenceSetLearner.setWeightName(weightName);
            end
        end
                       
        function [] = updateModel(obj, data)
            if (obj.updateReferenceSet && ~isempty(obj.referenceSetLearner))
                obj.referenceSetLearner.updateModel(data);
            end
            if (isa(obj.referenceSet, 'char'))
                referenceSet = data.getDataEntry(obj.referenceSet);
                isPeriodic = obj.dataManager.getPeriodicity(obj.referenceSet);
            else
                referenceSet = obj.referenceSet.getReferenceSet();
                isPeriodic = obj.dataManager.getPeriodicity(obj.referenceSet.inputDataEntryReferenceSet);
            end
            if (size(referenceSet,1) > 500)
                index = randperm(size(referenceSet,1));
                referenceSet = referenceSet(index(1:500),:);
            end
            
            bandWidth = zeros(1, size(referenceSet, 2));
            for i = 1:size(referenceSet,2)
                distances = repmat(referenceSet(:,i), 1, size(referenceSet,1));
                distances = (distances - distances');
                
                if (isPeriodic(i))
                    distances(distances > pi) = distances(distances > pi) - 2 * pi;
                    distances(distances < - pi) = distances(distances < - pi) + 2 * pi;                    
                end                
                distances = distances.^2;
                
                if (numel(obj.kernelMedianBandwidthFactor) == 1)
                    bandWidth(i) = sqrt(median(distances(:))) * obj.kernelMedianBandwidthFactor;
                else
                    bandWidth(i) = sqrt(median(distances(:))) * obj.kernelMedianBandwidthFactor(i);
                end
            end
            bandWidth(bandWidth == 0) = 1; %catch constant dimensions
            obj.kernel.setBandWidth(bandWidth);            
        end                
        
    end
    
end

