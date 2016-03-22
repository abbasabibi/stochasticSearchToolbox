classdef StepSamplerWithOptions < Sampler.StepSampler
    properties (Access = protected)       
    end
        
    methods
        function [obj] = StepSamplerWithOptions(varargin)
            
            obj = obj@Sampler.StepSampler(varargin{:});
            
            obj.addSamplerPool('Termination', 10);
            obj.addSamplerPool('Gating', 15);            
                  
            obj.addElementsForTransition('options', 'optionsOld');
            obj.dataManager.addDataEntry('options', 1,0,1);
            obj.dataManager.addDataEntry('optionsOld', 1,0,1);            
            obj.dataManager.addDataEntry('terminations', 1,1,2);            
        end
        
        function [] = setTerminationPolicy(obj, terminationPolicy)           
            obj.addSamplerToPoolInternal('Termination', 'sampleTermination', terminationPolicy, 1);            
        end
        
        function [] = setGatingPolicy(obj, gatingPolicy)           
            obj.addSamplerToPoolInternal('Gating', 'sampleOption', gatingPolicy, 1);            
        end
         
    end
    
    
end