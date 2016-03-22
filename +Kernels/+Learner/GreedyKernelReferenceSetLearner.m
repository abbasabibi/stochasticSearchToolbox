classdef GreedyKernelReferenceSetLearner < Kernels.Learner.AbstractKernelReferenceSetLearner

    methods
        function obj = GreedyKernelReferenceSetLearner(dataManager, kernelReferenceSet)
            obj = obj@Kernels.Learner.AbstractKernelReferenceSetLearner(dataManager, kernelReferenceSet);
        end                       
            
        function indicator = setReferenceSet(obj, data, inputDataMatrix, valid, parentIndicator)
            M = size(inputDataMatrix,1);
            
            if not(exist('parentIndicator','var'))
                parentIndicator = true(M,1);
            end
            
            if exist('valid', 'var')
                validInputDataMatrix = inputDataMatrix(logical(valid & parentIndicator),:);
                orig_index = find(valid & parentIndicator);
            else
                validInputDataMatrix = inputDataMatrix(logical(parentIndicator),:);
                orig_index = find(parentIndicator);
            end
            
            if (size(validInputDataMatrix,1) > obj.maxSizeReferenceSet)
                
                indexList = zeros(1,obj.maxSizeReferenceSet);
                kernelMatrix = zeros(obj.maxSizeReferenceSet+1,size(validInputDataMatrix,1));

                % selection of the first element
                indexList(1) = 1;%randi(size(data,2),1);

                for i = 2:obj.maxSizeReferenceSet
                    % compute kernel activations for last chosen kernel sample
                    kernelMatrix(i-1,:) = obj.kernelReferenceSet.kernel.getGramMatrix(validInputDataMatrix(indexList(i-1),:),validInputDataMatrix);
                    kernelMatrix(end,indexList(i-1)) = inf;

                    % sum over all kernel activations
                    kernel_activations = max(kernelMatrix,[],1);
                    [~, indexList(i)] = min(kernel_activations);
                end             
            else
                indexList = 1:size(validInputDataMatrix, 1);
            end            
            indexList = orig_index(indexList);
            
            % Thats now done in the super class as the reference set needs
            % the data
            %obj.kernelReferenceSet.setReferenceSet(inputDataMatrix(indexList,:), indexList);
            
            indicator = false(M,1);
            indicator(indexList) = true;
        end
    end
    
end

