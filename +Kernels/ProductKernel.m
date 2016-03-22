classdef ProductKernel < Kernels.CompositeKernel
    %Product of kernels 
    
    
    methods 
        function obj = ProductKernel(dataManager, numDims, kernels, stateIndices, kernelName)
            
            obj@Kernels.CompositeKernel(dataManager,numDims, kernels, stateIndices, kernelName);            
                        
        end
        
        
        function [K] = getGramMatrix(obj, inputData1, inputVector2)
            K = ones(size(inputData1,1), size(inputVector2,1));
            for i = 1:size(obj.kernels,2)
                K = K.* obj.kernels{i}.getGramMatrix(inputData1(:,obj.stateIndices{i}), inputVector2(:,obj.stateIndices{i}));
            end
        end
        
        function [v] = getGramDiag(obj, inputVectors)
            % get diagonal elements of gram matrix, i.e. kernel evaluated
            % between every datapoint and itself
            v = ones(size(inputVectors,1), 1);
            for i = 1:size(obj.kernels,2)
                v = v.* obj.kernels{i}.getGramDiag(inputVectors(:,obj.stateIndices{i}));
            end
        end    
                
        function gradientMatrices = getKernelDerivParam(obj, data)
            % all kernel derivatives are zero except for the one
            % to which paramidx applies!
                                    
            % get index of kernel to derive
            % and index of paramidx within the kernel
            
            % use n params per kernel

            gramMatrix = obj.getGramMatrix(data, data);
                        
            gradientMatrices = zeros(size(gramMatrix, 1), size(gramMatrix,2), obj.getNumHyperParameters());
            paramIndex = 1;
            
            for i = 1:size(obj.kernels,2)
                
                gramMatrixLocal = obj.kernels{i}.getGramMatrix(data(:, obj.stateIndices{i}), data(:, obj.stateIndices{i}));
                gramMatrixLocal( gramMatrixLocal == 0) = 1;
                
                dgramMatrix = gramMatrix ./ gramMatrixLocal;
                gradientMatricesLocal = obj.kernels{i}.getKernelDerivParam(data(:, obj.stateIndices{i})); 
                %gradientMatricesLocal = cellfun(@(param_) param_ .* gramMatrix, gradientMatricesLocal);
                gradientMatricesLocal = bsxfun(@times, dgramMatrix, gradientMatricesLocal);
                paramIndexes = paramIndex:(paramIndex+obj.kernels{i}.getNumHyperParameters-1);
                paramIndex = paramIndex + obj.kernels{i}.getNumHyperParameters;
                gradientMatrices(:,:,paramIndexes) = gradientMatricesLocal;
            end       

            
        end
        
        function g = getKernelDerivData(obj, refdata, curdata)
            % refdata = n * d
            % curdata = m * d
            % returns g = m*d*n. g(i,j,l) is:
            % d k(refdata(l,:), curdata(i,:))
            % ---------------------------
            % d curdata(i,j)
            
            g = zeros(size(curdata,1), size(curdata,2), size(refdata,1));
            
            derivs = cell(size(obj.kernels,2),1);
            grammatrices = cell(size(obj.kernels,2));
            
            for i = 1:size(obj.kernels,2) % kernel whose derivative we want
                derivs{i} = obj.kernels{i}.getKernelDerivData(refdata(:,obj.stateIndices{i}), curdata(:,obj.stateIndices{i}));
                grammatrices{i} = obj.kernels{i}.getGramMatrix(refdata(:,obj.stateIndices{i}), curdata(:,obj.stateIndices{i}));
            end
            
            assert(false) % TODO;
            
            for dim = 1:size(refdata,2)
                %g_dim = ones(size(curdata,1), size(refdata,1));
                for i = 1:size(obj.kernels,2) % deriv of kernel i
                    d = obj.dims{i}; 
                    kern_dims = d(obj.kernels{i}.stateIndices); % dimensions that influence kernel i 
                    if (ismember(dim,kern_dims)) % if kernel i is influenced by dim
                        g_local = derivs{i}(:, kern_dims==dim ,: ); % select appropriate layer from derivs{i}
                        %g_local = derivs{i}(:, dim ,: );
                        for j = 1:size(obj.kernels,2)
                            if(i~=j)
                               g_local = g_local .* permute(grammatrices{j},[2,3,1 ] ); % multiply with appropriate grammatrices
                            end
                        end
                        g(:,:, dim) = g(:,:, dim) + g_local;

                        
                    end
                    
                end
                
            end
            
        end
        
        function proj = getFourierProjection(obj, numFeatures, randStream,x )
            proj = zeros(size(x,1), numFeatures);
            for i = 1:numel(obj.kernels)
                proj = proj + obj.kernels{i}.getFourierProjection(numFeatures, randStream,x(:,obj.stateIndices{i}));
            end
            
            
            
        end
        

                
    end  
    
    methods(Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            for i = 1:numel(obj.kernels)
                cpObj.kernels{i} = obj.kernels{i}.copy;
            end
        end
    end
    
end

