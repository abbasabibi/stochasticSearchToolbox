classdef PathIntegralMultiplierSettings < Experiments.ParameterSettings.ParameterSettings
    
    methods (Static)
        
        function [] = setParametersForTrial(trial)
            tmpState = zeros(1, trial.transitionFunction.dimState);
            tmpAction = zeros(1, trial.transitionFunction.dimAction);
            
            %Set action cost term according to the path integral equation
            stdNoise = trial.transitionFunction.getControlNoiseStd(tmpState, tmpAction);
            
            uFactor = Common.Settings().getProperty('uFactor');
            
            %uFactor = 0.5 * stdNoise.^-2 * Common.Settings().getProperty('PathIntegralCostActionMultiplier');            
            multiplier = 2*stdNoise.^2 * uFactor;
            Common.Settings().setProperty('PathIntegralCostActionMultiplier', multiplier)
        end

    end
    
end