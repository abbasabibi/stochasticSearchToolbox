classdef GeneralizedKernelKalmanSmootherConfiguratorNoOpt < Experiments.Configurator
    %GENERALIZEDKERNELKALMANFILTERCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = GeneralizedKernelKalmanSmootherConfiguratorNoOpt(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name '_optimizationName'],'GKKF_CMAES_optimization');
            trial.setprop('GKKS_lambdaI',1e-6);
        end
        
        function postConfigureTrial(obj, trial)
            
            trial.setprop('filterLearner',Smoother.Learner.GeneralizedKernelKalmanSmootherLearner(trial.dataManager,'filterLearner'));
            trial.filterLearner.filter.lambdaI = trial.GKKS_lambdaI;
            
            for i = 1:length(trial.preprocessors)
                trial.filterLearner.addDataPreprocessor(trial.preprocessors{i});
            end
        end
        
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.filterLearner);
        end
    end
    
end

