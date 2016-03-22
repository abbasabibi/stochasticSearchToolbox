classdef RadialBasisFeatures < FeatureGenerators.FeatureGenerator
    %RBFNETWORK Radial basis fc network with given number of basis
    % nsamples is vector with number of basis per dimension
    
    properties
        kernel;
        minValues;
        maxValues;
    end
    
    properties (SetObservable, AbortSet)
        nGridSamples=1;
    end
    
    methods
        function [obj] = RadialBasisFeatures(dataManager, featureVariables, kernel, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'RBFgrid', stateIndices);
            
            obj.linkProperty('nGridSamples', ['nGridSamples', featureVariables{1}{:}]);
                        
            %obj.nsamples = nsamples;            
            obj.kernel = kernel;
            
            if(~iscell(featureVariables))
                featureVariables = {featureVariables };
            end
            % list of all names in the aliases
            namescell = cellfun(@(x) obj.dataManager.getDataManagerForEntry(x).dataAliases.(x).entryNames, featureVariables{1} ,'UniformOutput',false);
            names = cat(2, namescell{:});
            %obj.minValues = obj.dataManager.getDataManagerForEntry(outputVariable).dataEntries(outputVariable).minRange;
            %obj.maxValues = obj.dataManager.getDataManagerForEntry(outputVariable).dataEntries(outputVariable).maxRange;
            obj.minValues =cell2mat(cellfun(...
                @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).minRange, ...
                names, 'UniformOutput',false));
            obj.maxValues = cell2mat(cellfun(...
                @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).maxRange, ...
                names, 'UniformOutput',false));
            %doesn't handle aliases:
            %obj.minValues = cell2mat(cellfun(...
            %    @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).minRange, ...
            %    featureVariables, 'UniformOutput',false));
            %obj.maxValues = cell2mat(cellfun(...
            %    @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).maxRange, ...
            %    featureVariables, 'UniformOutput',false));
        end    
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            
            % calc reference points
            
            args = [obj.nGridSamples; obj.minValues; obj.maxValues ]; 
            cellargs = mat2cell(args, 3, ones(numel(obj.nGridSamples),1) );
            possiblevalues = cellfun(@(x) linspace(x(2), x(3), x(1)), cellargs,'UniformOutput',false);
            [grids{1:numel(cellargs)}]=ndgrid(possiblevalues{:});
            if(numel(cellargs)>1)
                refPoints = cell2mat(cellfun(@(x) reshape(x,[numel(x), ones(1,numel(cellargs)-1) ] ) ,grids,'UniformOutput',false)); 
            else
                refPoints = grids{1};
            end
            
                        
            
            % get kernel
            features = obj.kernel.getGramMatrix(inputMatrix,refPoints);
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = prod(Common.Settings().getProperty(['nGridSamples', obj.featureVariables{1}{:}]));
        end
        
    end
    
end

