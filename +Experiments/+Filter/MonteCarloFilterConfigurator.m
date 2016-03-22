classdef MonteCarloFilterConfigurator < Experiments.Configurator
    %GENERALIZEDKERNELKALMANFILTERCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MonteCarloFilterConfigurator(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name '_numSamples'],1e2);
            trial.setprop([obj.name '_outputDims'],1);
            trial.setprop([obj.name '_dataEntry'],'states');
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('mcFilter',Filter.MonteCarloFilter(trial.dataManager,trial.transitionFunction.dimState,trial.mcConf_outputDims));
            trial.mcFilter.dataEntry = trial.mcConf_dataEntry;
            trial.mcFilter.numEpisodesInDataBase = trial.mcConf_numSamples;
            trial.mcFilter.obsNoise = trial.noisePreprocessor.sigma;
            trial.mcFilter.validityDataEntry = trial.evaluationValid;
            
            trial.mcFilter.preprocessors = trial.preprocessors;
        end
        
    end
    
end

