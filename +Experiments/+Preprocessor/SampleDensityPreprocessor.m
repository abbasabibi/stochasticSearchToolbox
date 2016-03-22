classdef SampleDensityPreprocessor  < Experiments.Configurator
    % GridPreprocessorConfigurator
    properties
        dataSetNames
        featureName
        kernelName
    end
    
    methods
        function obj = SampleDensityPreprocessor(dataSetNames,featureName,kernelName)
            if(~exist('dataSetName','var'))
                dataSetNames = {};
            end
            if(~exist('featureName','var'))
                featureName = 'states';
            end
            if(~exist('kernelName','var'))
                kernelName = 'stateKernel';
            end
            obj = obj@Experiments.Configurator('SampleDensity');
            obj.featureName = featureName;
            obj.kernelName = kernelName;
            obj.dataSetNames = dataSetNames;
            if (~iscell(dataSetNames))
                obj.dataSetNames = {obj.dataSetNames};
            end
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            Common.Settings().setProperty('numLocalDataPoints', 100);
            
            trial.setprop(['sampleDensity',obj.featureName], @(trial) DataPreprocessors.UniformDensityDataSelector(trial.dataManager, trial.(obj.kernelName), obj.featureName));
            
            for i = 1:length(obj.dataSetNames)
                trial.(obj.dataSetNames{i}) = 'uniformDensity';
            end
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);
            
            trial.(['sampleDensity',obj.featureName]) = trial.(['sampleDensity',obj.featureName])(trial);
            
        end
        
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addDataPreprocessor(trial.(['sampleDensity',obj.featureName]), true);
            trial.scenario.addInitObject(trial.(['sampleDensity',obj.featureName]));
        end
    end
end
