classdef GeneralizedKernelKalmanSmootherConfigurator < Experiments.Configurator
    %GENERALIZEDKERNELKALMANFILTERCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = GeneralizedKernelKalmanSmootherConfigurator(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name '_optimizationName'],'GKKF_CMAES_optimization');
        end
        
        function postConfigureTrial(obj, trial)
            
            trial.setprop('filterLearner',Smoother.Learner.GeneralizedKernelKalmanSmootherLearner(trial.dataManager,'filterLearner'));
            
            for i = 1:length(trial.preprocessors)
                trial.filterLearner.addDataPreprocessor(trial.preprocessors{i});
            end
            
            if iscell(trial.([obj.name '_optimizationName']))
                filterOptimizer = cell(length(trial.([obj.name '_optimizationName'])),1);
                for i = 1:length(trial.([obj.name '_optimizationName']))
                    optimizationName  = trial.([obj.name '_optimizationName']){i};
                    filterOptimizer{i} = Smoother.Learner.GeneralizedKernelKalmanSmootherOptimizer(trial.dataManager, trial.filterLearner, optimizationName);
                end
                trial.setprop('filterOptimizer', filterOptimizer);
            else
                trial.setprop('filterOptimizer', Smoother.Learner.GeneralizedKernelKalmanSmootherOptimizer(trial.dataManager, trial.filterLearner, trial.([obj.name '_optimizationName'])));
            end
        end
        
        function setupScenarioForLearners(obj, trial)
            if iscell(trial.filterOptimizer)
                for i = 1:length(trial.filterOptimizer)
                    filterOptimizer = trial.filterOptimizer{i};
                    trial.scenario.addLearner(filterOptimizer);
                end
            else
                trial.scenario.addLearner(trial.filterOptimizer);
            end
        end
    end
    
end

