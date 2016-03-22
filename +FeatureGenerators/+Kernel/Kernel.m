classdef Kernel < FeatureGenerators.FeatureGenerator & Learner.Learner & matlab.mixin.Copyable
    %KERNEL Base class for kernels
    % compute gram matrices of the form
    %   -------------------------------------------
    %   | k(x(1,:),y(1,:) | k(x(1,:),y(2,:) | ... |
    %   -------------------------------------------
    %   | k(x(2,:),y(1,:) | k(x(2,:),y(2,:) | ... |
    %   -------------------------------------------
    %   | ...             | ...             | ... |
    %   -------------------------------------------
    properties
        lambda=0.05
        %dimensionality
        referenceSet; %set of datapoints to compare to
        featureTag = 1;
        kernelname;
        tolearn;
        
        restrictNumFeatures = true;
    end
    
    methods (Abstract)
        [params] = getHyperParametersInternal(obj)
        [] = setHyperParametersInternal(obj, params)
        [G] = getGramMatrixInternal(data1, data2)
        [g] = getKernelDerivParamInternal(paramidx, data, precomputation )
        [g] = getKernelDerivDataInternal(refdata, curdata, precompute)
        [pre] = precomputeForDerivative(data)
        obj_out = clone(obj)
    end
    
    
    
    methods
        
        function obj = Kernel(dataManager, featureVariables, kernelname, stateIndices, numFeatures, tolearn)
            if(iscell(featureVariables))
                if(~iscell(featureVariables{1}))
                    featureVariables = {featureVariables};
                    % transform {a,b} to {{a,b}}
                else
                    assert(numel(featureVariables)==1, 'featureVariables should be a, {a,b}, or {{a,b}}, not {{a},{b}}');
                end
            else
                featureVariables = {{featureVariables}}; %transform a to {{a}}
            end
            
            obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, kernelname, stateIndices, numFeatures)
            obj@Learner.Learner()
            %obj.dimensionality = dimensionality;
            if(stateIndices == ':')
                obj.referenceSet =  cellfun(@(x) zeros(0, dataManager.getNumDimensions(x)), {featureVariables}, 'UniformOutput', false);
                obj.referenceSet = obj.referenceSet{1};
            else
                obj.referenceSet = zeros(0, numel(stateIndices));
            end
            
            obj.kernelname = kernelname;
            if(~exist('tolearn','var'))
                obj.tolearn = featureVariables;
            else
                if(iscell(tolearn))
                    if(~iscell(tolearn{1}))
                        obj.tolearn = {tolearn};
                        % transform {a,b} to {{a,b}}
                    else
                        assert(numel(tolearn)==1, 'featureVariables should be a, {a,b}, or {{a,b}}, not {{a},{b}}');
                        obj.tolearn = tolearn;
                    end
                else
                    obj.tolearn = {{tolearn}}; %transform a to {{a}}
                end
            end
        end
        
        function [referenceSet] = getReferenceSet(obj)
            referenceSet = obj.referenceSet;
        end
        
        function [G] = getWeightedGramMatrix(obj, data, weights)
            % gram matrix with weights
            % weights should be >0
            G = obj.getGramMatrixInternal(data(:, obj.stateIndices), data(:, obj.stateIndices)) + obj.lambda * diag(1./weights);
        end
        
        function [G] = getRegularizedGramMatrix(obj, data)
            % gram matrix with ridge
            G = obj.getGramMatrixInternal(data(:, obj.stateIndices), data(:, obj.stateIndices));
            G = G + obj.lambda * ones(size(G));
        end
        
        function [G] = getGramMatrix(obj, data1, data2)
            % gram matrix without ridge
            G = obj.getGramMatrixInternal(data1(:, obj.stateIndices), data2(:, obj.stateIndices));
        end
        
        function [v] = getGramDiag(obj, data)
            % get diagonal elements of gram matrix, i.e. kernel evaluated
            % between every datapoint and itself
            v = zeros(size(data,1),1);
            for i = 1:size(data,1)
                v(i) = obj.getGramMatrixInternal(data(i,obj.stateIndices), data(i, obj.stateIndices));
            end
        end
        
        function [params] = getHyperParameters(obj)
            % get lambda + hyperparameters, e.g. for optimization
            params = [obj.lambda, obj.getHyperParametersInternal() ];
        end
        
        function [] = setHyperParameters(obj, params)
            % set lambda + hyperparameters, e.g. from optimization
            obj.lambda = params(1);
            obj.setHyperParametersInternal(params(2:end));
            obj.featureTag = obj.featureTag + 1;
        end
        
        function [kernelVector] = getKernelVector(obj, inputVector)
            kernelVector = obj.getFeaturesInternal(1, inputVector);
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)
           
            if (~isempty(obj.referenceSet))
                kernel = obj.getGramMatrixInternal(inputMatrix(:, obj.stateIndices),obj.referenceSet);
            else
                kernel = [];
            end
                        
            if(obj.getNumFeaturesNonZero() > obj.getNumFeatures())
                warning('RKHSModelLearner:numFeatures','amount of features not supported')
                features = kernel(:,1:obj.getNumFeatures());
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(kernel,2));
                features = [kernel, zerofeatures];
            end
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = obj.numFeatures;
        end
        
        function [numFeatures] = getNumFeaturesNonZero(obj)
            numFeatures = size(obj.referenceSet,1);
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
        
        function obj = updateModel(obj, data)
            obj.featureTag = obj.featureTag + 1;
            %invalidates previously calculated features...
            % to make sure they will be calculated again.
            
            if(~isempty(obj.tolearn))
                
                celldata = data.getDataEntryCellArray(obj.tolearn);
                obj.referenceSet = celldata{1};
                %gets data of all input variables in one big array

                if (obj.restrictNumFeatures && size(obj.referenceSet,1)> obj.getNumFeatures())
                    s = RandStream('mt19937ar','Seed',obj.featureTag);
                    p = randperm(s,size(obj.referenceSet,1),obj.getNumFeatures());
                    obj.referenceSet = obj.referenceSet(p,:);
                end

                if(size(obj.referenceSet,1)> obj.getNumFeatures())
                    warning('KernelFeatures:numFeatures','Set bigger than max no. of features!');
                end
                obj.referenceSet = obj.referenceSet(:, obj.stateIndices);
            end
        end
        
        function [g] = getKernelDerivParam(obj, paramidx, data, precompute, weights )
            
            if(paramidx == 1)
                if(~exist('weights','var'))
                    g = eye(size(grammatrix));
                else
                    g = diag(1./weights);
                end
            else
                g = obj.getKernelDerivParamInternal(paramidx-1, data(:, obj.stateIndices), precompute);
            end
        end
        
        function [g] = getKernelDerivData(obj, refdata, curdata)
            % refdata = n * d
            % curdata = m * d
            % returns g = m*d*n. g(i,j,l) is:
            % d k(refdata(l,:), curdata(i,:))
            % ---------------------------
            % d curdata(i,d)
            
            
            g = obj.getKernelDerivDataInternal(refdata(:, obj.stateIndices), curdata(:, obj.stateIndices));
        end
        
        function C = convolve(obj, refdata, curdata)            
            C = obj.convolve(refdata(:, obj.stateIndices), curdata(:, obj.stateIndices));
        end
        
        function C = convolveInternal(obj, refdata, curdata)
            assert(false, 'Convolution not implemented for this kernel type')
        end
        
    end
    
end

