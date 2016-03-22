classdef LSTDFeatureLearner < Learner.ParameterOptimization.AbstractHyperParameterOptimizer & Data.DataManipulator
    
    properties(SetObservable,AbortSet)
        discountFactor 
    end
    
    properties(SetAccess=protected)
                
        lstdLearner
        qFunction
        
        parameterObject
        currentFeatureName
        nextFeatureName
        
        %data;
        
        rewardName
        parameterInitializer;
        referenceSetLeaner;

    end     
    
    
    methods
        %%
        function obj = LSTDFeatureLearner(dataManager, lstdLearner, currentFeatureName, nextFeatureName, ...
                qFunction, referenceSetLearner, rewardName)
                        
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, lstdLearner, 'LSTDKernelOptimizer', true);
            obj = obj@Data.DataManipulator(dataManager);
            
            if (~exist('rewardName', 'var'))
                rewardName = 'rewards';
            end
            obj.rewardName = rewardName;
            obj.qFunction = qFunction;
            obj.lstdLearner = lstdLearner;
            obj.referenceSetLeaner = referenceSetLearner;
            
            obj.currentFeatureName = currentFeatureName;
            obj.nextFeatureName = nextFeatureName;
            
            obj.linkProperty('discountFactor');
            obj.addDataManipulationFunction('errorFunction', {obj.rewardName, obj.currentFeatureName, obj.nextFeatureName}, {});
            
            obj.parameterInitializer = Kernels.Learner.MedianBandwidthSelector(obj.dataManager, obj.lstdLearner.functionApproximator.featureGenerator.kernel, obj.referenceSetLeaner, obj.lstdLearner.functionApproximator.featureGenerator);
            obj.parameterInitializer.updateReferenceSet = false;
            
            obj.debugMessages = true;
        end
        
        %% Trajectory Generation
        function [] = processTrainingData(obj, data)
            %obj.data = data;
            obj.referenceSetLeaner.updateModel(data);
            obj.iteration = obj.iteration + 1;
        end
                
        function [] = initializeParameters(obj, data)
            obj.parameterInitializer.updateModel(data);
        end     
        
        function [] = learnFinalModel(obj, data)
            obj.lstdLearner.updateModel(data);                        
        end
                                
        function [funcVal, gradient] = objectiveFunction(obj, params)
            if (nargin >= 2)
                obj.setParametersToOptimize(params);                
            end
            
            %learn LSTD
            obj.lstdLearner.updateModel(obj.data);                        
             
            funcVal = obj.callDataFunctionOutput('errorFunction', obj.data);
        end
        
        function [] = beforeOptimizationHook(obj)
            
%             figure(1);
%             states = obj.data.getDataEntry('states');
%             minStates = min(states);
%             maxStates = max(states);
%                 
%             error = obj.objectiveFunction();
%             
%             Plotter.PlotterFunctions.plotOutputFunctionSlice2D(obj.qFunction, 1, 2, minStates, maxStates, [0, 0, 0], 50);            
%             title(sprintf('MSPBE %f, before %d', error, obj.iteration));
%             saveas(gcf, sprintf('mspbe%d_before', obj.iteration), 'fig');
        end
        
        function [] = afterOptimizationHook(obj)
%             figure(2);
%             states = obj.data.getDataEntry('states');
%             minStates = min(states);
%             maxStates = max(states);
%                 
%             error = obj.objectiveFunction();
%             Plotter.PlotterFunctions.plotOutputFunctionSlice2D(obj.qFunction, 1, 2, minStates, maxStates, [0, 0, 0], 50);            
%             title(sprintf('MSPBE %f, before %d', error, obj.iteration));
%             saveas(gcf, sprintf('mspbe%d_after', obj.iteration), 'fig');
        end
                        
    end
    
    methods (Abstract)
        [error]  = errorFunction(obj, rewards, features, nextFeatures)         
    end
end

