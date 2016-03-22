classdef PhaseGeneratorSpeedProfile < TrajectoryGenerators.PhaseGenerators.PhaseGenerator
    
    properties
        speedprofile;
    end
    
    methods
        
        function obj = PhaseGeneratorSpeedProfile(dataManager, speedprofile)
            obj = obj@TrajectoryGenerators.PhaseGenerators.PhaseGenerator(dataManager);
                      
            obj.speedprofile = speedprofile;
        end
                       
        function [phase] = generatePhase(obj, numElements)
            phase = cumsum(obj.speedprofile(1:numElements) * obj.dt) / obj.phaseEndTime;
        end       
        
    end        
end
