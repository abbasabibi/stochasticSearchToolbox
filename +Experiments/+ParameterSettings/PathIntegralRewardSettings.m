classdef PathIntegralRewardSettings < Experiments.ParameterSettings.ParameterSettings
    
    methods (Static)
        
        function [] = setParametersForTrial(trial)
            tmpState = zeros(1, trial.transitionFunction.dimState);
            tmpAction = zeros(1, trial.transitionFunction.dimAction);
            
            %Set action cost term according to the path integral equation
            stdNoise = trial.transitionFunction.getControlNoiseStd(tmpState, tmpAction);
            
            if (any(stdNoise == 0))
                warning('Noise is zero, path integrals do not work without noise\n');
            end
            
            if (~Common.Settings().hasProperty('PathIntegralCostActionMultiplier'))
                Common.Settings().setProperty('PathIntegralCostActionMultiplier', 1.0)
            end
            uFactor = 0.5 * stdNoise.^-2 * Common.Settings().getProperty('PathIntegralCostActionMultiplier');            
            Common.Settings().setProperty('uFactor', uFactor);
        end

    end
    
end