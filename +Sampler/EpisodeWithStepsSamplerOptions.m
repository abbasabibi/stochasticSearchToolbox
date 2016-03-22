classdef EpisodeWithStepsSamplerOptions < Sampler.EpisodeWithStepsSampler
    properties (SetAccess = protected, GetAccess = public)
    end
    
    properties

    end
    
    methods
        function [obj] = EpisodeWithStepsSamplerOptions(varargin)
            obj = obj@Sampler.EpisodeWithStepsSampler(varargin{:});
        end
        
        function [] = createStepSampler(obj, varargin)
            obj.stepSampler = Sampler.StepSamplerWithOptions(varargin{:});            
        end
                
        function [] = setTerminationPolicy(obj, terminationPolicy)
            obj.stepSampler.setTerminationPolicy(terminationPolicy);
        end
        
        function [] = setGatingPolicy(obj, gatingPolicy)
            obj.stepSampler.setGatingPolicy(gatingPolicy);
        end                       
        
    end
end