classdef SpectralFilterConfiguratorNoOpt < Experiments.Configurator
    %SPECTRALFILTERCONFIGURATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = SpectralFilterConfiguratorNoOpt(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('windowSize',4);
            trial.setprop('outputDims',1);
            trial.setprop('numEigenvectors',20);
            trial.setprop('kernelType','ExponentialQuadraticKernel');
            
            trial.setprop('filter', @(trial) Filter.SpectralFilter(trial.dataManager, trial.windowSize, trial.windowSize, trial.state1KernelReferenceSet, trial.state2KernelReferenceSet, trial.state3KernelReferenceSet));
        end
        
        function postConfigureTrial(obj, trial)
            
            trial.setprop('kernel', Kernels.(trial.kernelType)(trial.dataManager, trial.windowSize, 'kernel'));

            trial.setprop('state1KernelReferenceSet', Kernels.KernelReferenceSet(trial.kernel, 'state1KRS'));
            trial.setprop('state2KernelReferenceSet', Kernels.KernelReferenceSet(trial.kernel, 'state2KRS'));
            trial.setprop('state3KernelReferenceSet', Kernels.KernelReferenceSet(trial.kernel, 'state3KRS'));

            trial.setprop('state1KRSL', Kernels.Learner.GreedyKernelReferenceSetLearner(trial.dataManager, trial.state1KernelReferenceSet));
            trial.setprop('state2KRSL', Kernels.Learner.CloneKernelReferenceSetLearner(trial.dataManager, trial.state2KernelReferenceSet, trial.state1KernelReferenceSet));
            trial.setprop('state3KRSL', Kernels.Learner.CloneKernelReferenceSetLearner(trial.dataManager, trial.state3KernelReferenceSet, trial.state1KernelReferenceSet));

            trial.setprop('bandwidthSelector', Kernels.Learner.RandomMedianBandwidthSelector(trial.dataManager, trial.state1KernelReferenceSet));
            trial.bandwidthSelector.kernelMedianBandwidthFactor = .1;

            % #########################################

            trial.filter = trial.filter(trial);
            
            trial.setprop('filterLearner', Filter.Learner.SpectralFilterLearner(trial.dataManager, trial.filter, trial.numEigenvectors, 'x1', {'x1', 'obsPoints'}, {'filteredMu'}, trial.outputDims));
            
            for i = 1:length(trial.preprocessors)
                trial.filterLearner.addDataPreprocessor(trial.preprocessors{i});
            end
        end
        
        function setupScenarioForLearners(obj, trial)
            trial.filterLearner.state1KRSL = trial.state1KRSL;
            trial.filterLearner.state2KRSL = trial.state2KRSL;
            trial.filterLearner.state3KRSL = trial.state3KRSL;
            
            trial.filterLearner.bandwidthSelector = trial.bandwidthSelector;
            
            trial.scenario.addLearner(trial.filterLearner);
        end
    end
    
end

