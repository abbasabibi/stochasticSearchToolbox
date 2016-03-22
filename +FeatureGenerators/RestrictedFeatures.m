classdef RestrictedFeatures < FeatureGenerators.FeatureGenerator
    % RestrictedFeatures: for variables that have a min and a max in the
    % data manager but are not restricted to that range. Add a restricted
    % version of those to the datamanager
    
    properties
    
    end
    
    methods
        function [obj] = RestrictedFeatures(dataManager, featureVariables, stateIndices)
            % @param dataManager DataManger to operate on
            % @param featureVariables Set of dataentries  in the DataManager as strings
            % @param stateIndices subset of the dataentries this feature generator will handle
            if (~exist('stateIndices', 'var') || isempty(stateIndices) )
                stateIndices = ':';
            end
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'Restricted', stateIndices);
                        
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)
            maxrange = obj.dataManager.getMaxRange(obj.featureVariables);
            minrange = obj.dataManager.getMinRange(obj.featureVariables);
            features = bsxfun(@min, maxrange, bsxfun(@max, minrange, inputMatrix));
            
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = obj.dataManager.getNumDimensions(obj.featureVariables);
            

        end
        
    end
    
end


