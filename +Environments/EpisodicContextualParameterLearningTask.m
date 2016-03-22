classdef EpisodicContextualParameterLearningTask < Environments.EpisodicContextualLearningTask
    
    properties
        minRangeParameters;
        maxRangeParameters;
        
        dimParameters;
    end
    
    methods
        function obj = EpisodicContextualParameterLearningTask(episodeSampler, dimContext, dimParameters)
           obj = obj@Environments.EpisodicContextualLearningTask(episodeSampler, dimContext);
           
           obj.dataManager.addDataEntry('parameters', dimParameters);           
           obj.dimParameters = dimParameters;
           obj.addDataManipulationFunction('sampleReturn', {'contexts', 'parameters'}, {'returns'});
        end
        
        function [] = initObject(obj)
           obj.initObject@Environments.EpisodicContextualLearningTask();
           
           [obj.minRangeParameters, obj.maxRangeParameters] = obj.dataManager.getRange('parameters');
           obj.dimParameters = obj.dataManager.getNumDimensions('parameters');
        end

                       
        function [] = setInputParametersReturn(obj, vargin)
            obj.setInputArguments('sampleReturn', vargin);
        end
         
    end
    
    methods (Abstract)
        returns = sampleReturn(obj, vargin);
    end
    
end