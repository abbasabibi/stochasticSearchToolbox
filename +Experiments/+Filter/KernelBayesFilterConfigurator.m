classdef KernelBayesFilterConfigurator < Experiments.Configurator
    %GENERALIZEDKERNELKALMANFILTERCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = KernelBayesFilterConfigurator(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name '_optimizationName'],'GKKF_CMAES_optimization');
        end
        
        function postConfigureTrial(obj, trial)
            
            trial.setprop('filterLearner',Filter.Learner.KernelBayesFilterLearner(trial.dataManager,'filterLearner'));
            
            for i = 1:length(trial.preprocessors)
                trial.filterLearner.addDataPreprocessor(trial.preprocessors{i});
            end
            
            if iscell(trial.([obj.name '_optimizationName']))
                filterOptimizer = cell(length(trial.([obj.name '_optimizationName'])),1);
                for i = 1:length(trial.([obj.name '_optimizationName']))
                    optimizationName  = trial.([obj.name '_optimizationName']){i};
                    filterOptimizer{i} = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(trial.dataManager, trial.filterLearner, optimizationName);
                end
                trial.setprop('filterOptimizer', filterOptimizer);
            else
                trial.setprop('filterOptimizer', Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(trial.dataManager, trial.filterLearner, trial.([obj.name '_optimizationName'])));
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

