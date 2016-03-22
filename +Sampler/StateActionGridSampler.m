classdef StateActionGridSampler < Sampler.GridSampler
    %StateActionGridSampler Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods
        function obj = StateActionGridSampler(dataManager, varargin)
            sdm = dataManager.getDataManagerForEntry('states');
            sdm.addDataAlias('stateactions', {'states','actions'});
            obj@Sampler.GridSampler(sdm, 'stateactions', varargin{:});
            obj.addDataFunctionAlias('sampleInitStateAction','sampleGrid');      
            obj.addDataFunctionAlias('sampleContext','sampleGrid');  
            
        end

        
        
        
    end
    
end

