classdef GridSampler < Sampler.IndependentSampler
    %GRIDSAMPLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        minValues
        maxValues
        nsamples
    end
    
    methods
        function obj = GridSampler(dataManager, outputVariable, nsamples)
            % min, max, nsamples n by 1 vector
            
            
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, 'gridSampler'};
            end
            obj = obj@Sampler.IndependentSampler(superargs{:});
            
            % list of all names in the aliases
            if(~iscell(outputVariable))
                outputVariable = {outputVariable};
            end
            namescell = cellfun(@(x) obj.dataManager.getDataManagerForEntry(x).dataAliases.(x).entryNames, outputVariable ,'UniformOutput',false);
            names = cat(2, namescell{:});
            obj.minValues =cell2mat(cellfun(...
                @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).minRange, ...
                names, 'UniformOutput',false));
            obj.maxValues = cell2mat(cellfun(...
                @(x) obj.dataManager.getDataManagerForEntry(x).dataEntries(x).maxRange, ...
                names, 'UniformOutput',false));
            
            obj.nsamples = nsamples;
            
            % make sampler pool
            obj.addSamplerPool('gridSamplerPool', 1);
            
            % register function
            obj.addDataManipulationFunction('sampleGrid', {}, outputVariable)
            obj.addSamplerToPoolInternal( 'gridSamplerPool', 'sampleGrid', obj, 1);
            
        end
        
        function n = getNumSamples(obj, newData )
            n = prod(obj.nsamples);
        end
        
        
        function [output] = sampleGrid(obj, numElements)
            elements = prod(obj.nsamples);
            
            
            %if(numElements ~= elements)
            %    error('GridCreator:wrong number of samples')
            %end
            
            numdims =numel(obj.minValues);
            % create cell array with vector of possible values for each dim
            possiblevalues = cell(numdims,1);
            for i = 1:numdims
                possiblevalues{i} = linspace(obj.minValues(i), obj.maxValues(i), obj.nsamples(i));
            end
            %generate output grid
            grids = cell(numdims,1);
            [grids{:}]=ndgrid(possiblevalues{:});
            output = cell2mat(cellfun(@(x) reshape(x,[numel(x), ones(1,numdims-1) ] ) ,grids,'UniformOutput',false)'); 
            
            
            
        end
    end
    
end

