classdef SpectralFilter < Filter.AbstractFilter
    %SPECTRALFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K1
        K2
        K21
        K23
        iK2
        
        K2B
        K12B
        
        B
        A
        
        state1KernelReferenceSet
        state2KernelReferenceSet
        state3KernelReferenceSet
        
        initialMean
        
        outputData;
        
        name = 'SpectralFilter';
    end
    
    methods
        function obj = SpectralFilter(dataManager, stateDims, obsDims, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet, name)
            obj = obj@Filter.AbstractFilter(dataManager, stateDims, obsDims);
            
            obj.state1KernelReferenceSet = state1KernelReferenceSet;
            obj.state2KernelReferenceSet = state2KernelReferenceSet;
            obj.state3KernelReferenceSet = state3KernelReferenceSet;
            
            if exist('name','var')
                obj.name = name;
            end
        end
        
        function [mus] = filterData(obj, observations, observationPoints)
            T = size(observations,1);
            N = size(observations,3);
            
            if size(obj.initialMean,2) == 1
                mean = repmat(obj.initialMean,1,N);
            else
                mean = obj.initialMean;
            end
            
            mus = zeros(T, obj.outputDims{1}, N);
            
            if nargin < 3
                observationPoints = true(T,1);
            else
                observationPoints = logical(observationPoints);
            end
            
            
            for t = 1:T
                [xMu] = obj.outputTransformation(mean);
                mus(t,:,:) = permute(xMu,[3,2,1]);
                
                if observationPoints(t)
                    k2x_ = obj.state2KernelReferenceSet.getKernelVectors(permute(observations(t,:,:),[3,2,1]));
                else
                    k2x_ = obj.K2B * mean;
                end
                
                
                 mean = obj.K23 * ((obj.iK2*k2x_) .* (obj.A * mean));
                % normalized to [0,1]; 
                mean = bsxfun(@rdivide,mean,(max(mean) - min(mean)));% - min(mean);

            end
        end
        
        function xMu = outputTransformation(obj, mean)
            [~, ind] = max(obj.K12B * mean);
            xMu = obj.outputData(ind,:);
        end
    end
    
end

