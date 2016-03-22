%%
classdef RadialFeatures < FeatureGenerators.FeatureGenerator
    %%
    properties
        min;
        max;
        centers;
    end
    
    properties (SetObservable,AbortSet)
        
        rbfScale = 1;
        rbfBandwidth = 0.5;
        rbfNormalized = true;
        rbfNumDimCenters = 4;
        
    end
    
    %%
    methods
        %%
        function [obj] = RadialFeatures(dataManager, featureVariables, stateIndices)
            
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'RBF', stateIndices);
            
            obj.linkProperty('rbfScale');
            obj.linkProperty('rbfBandwidth');
            obj.linkProperty('rbfNormalized');
            obj.linkProperty('rbfNumDimCenters');
            
            
            obj.min = obj.dataManager.getMinRange(featureVariables);
            obj.max = obj.dataManager.getMaxRange(featureVariables);
            
            
            if(length(obj.rbfNumDimCenters) == 1)
                
                obj.rbfNumDimCenters = repmat(obj.rbfNumDimCenters,1,length(obj.min));
            end
            
            if(length(obj.rbfBandwidth) == 1)
                
                obj.rbfBandwidth = repmat(obj.rbfBandwidth,1,length(obj.min));
            end
            
            obj.setNumFeatures(prod(obj.rbfNumDimCenters));
            obj.centers = obj.rbfCenters();
            
        end
        
        %%
        function [centers] = rbfCenters ( obj )
            
            d = length(obj.min);
            nrFeatures = [obj.rbfNumDimCenters 1];
            centersSize = prod ( nrFeatures );
            centers=[];
            
            for i = 1:d
                
                featurePeriod = prod ( nrFeatures ( i+1:end ) );
                rowPeriod = centersSize / ( featurePeriod*nrFeatures(i) );
                rowSignal=[];
                
                for j = 1:nrFeatures(i)
                    
                    c = ( obj.max ( i ) - obj.min( i ) ) * ( j / nrFeatures ( i ) ) + obj.min ( i ) ;
                    rowSignal = [rowSignal repmat(c,1,featurePeriod)];
                    
                end
                
                centers = [ centers; repmat(rowSignal, 1, rowPeriod) ];
                
            end
            
            centers=centers';
            
        end
        
        function [numFeatures] = getNumFeatures(obj)
            
            numFeatures = prod(obj.rbfNumDimCenters);
            
        end
        
        
        
        
        %%
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            
            Q = diag(1./(obj.rbfBandwidth .^2));
            aQ = inputMatrix * Q ;
            sqdist = bsxfun ( @plus , sum ( aQ .* inputMatrix , 2 ) ,sum ( obj.centers * Q .* obj.centers , 2 )' ) -2* aQ * obj.centers' ;
            K = exp(-0.5* sqdist);
            
            if(obj.rbfNormalized)
                %K = K./(sqrt(prod(repmat(obj.rbfBandwidth,1,numel(obj.centers)) .^2)*(2*pi)^(numel(obj.centers))));
                K=bsxfun (@rdivide,K,sum(K,2));
                
            end
            K = obj.rbfScale * K;
            
            features=K;
        end
        
    end
    
end


