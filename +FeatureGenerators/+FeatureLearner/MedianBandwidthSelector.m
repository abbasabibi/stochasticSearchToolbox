classdef MedianBandwidthSelector < Learner.Learner
    %sets the bandwidth to a certain constant * the median of the distances
    properties
        kernel
    end
    
    properties(SetObservable,AbortSet)
        kernelMedianBandwidthFactor = 1.0;
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, featureName)
            kernelLearner = FeatureGenerators.FeatureLearner.MedianBandwidthSelector(trial.dataManager, trial.(featureName));
        end
    end
    
    
    methods
        function obj = MedianBandwidthSelector(dataManager, kernel)
            obj.kernel = kernel;
            
            obj.linkProperty('kernelMedianBandwidthFactor');
        end
        
        
        function obj = updateModel(obj, data)
            referenceSet = obj.kernel.getReferenceSet();
            
            bandWidth = zeros(1, size(referenceSet, 2));
            for i = 1:size(referenceSet,2)
                distances = repmat(referenceSet(:,i), 1, size(referenceSet,1));
                distances = (distances - distances').^2;
                
                bandWidth(i) = sqrt(median(distances(:))) * obj.kernelMedianBandwidthFactor;
            end
            obj.kernel.setBandwidth(bandWidth);
        end
    end
    
end

