classdef GPHyperParameterLearner < Learner.ParameterOptimization.AbstractHyperParameterOptimizer & Learner.AbstractInputOutputLearnerInterface
    %sets the bandwidth to a certain constant * the median of the distances
    properties
        initializerParams
        gp
        gpReferenceSetLearner
        gpLearner
        
        weighting
        inputData
        outputData
        
        dataManager
    end
    
    properties(SetObservable,AbortSet)
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.GPHyperParameterLearner(trial.dataManager, trial.(gpName));
        end
        
        function [gpLearner] = createGPLearner(dataManager, gp)
            settings = Common.Settings();
            
            gpLearnerString = 'GPStandard';
            
            if (settings.hasProperty(['GPLearner', upper(gp.outputVariable(1)), gp.outputVariable(2:end)]))
                gpLearnerString = settings.getProperty(['GPLearner', upper(gp.outputVariable(1)), gp.outputVariable(2:end)]);
            else
                settings.registerProperty(['GPLearner', upper(gp.outputVariable(1)), gp.outputVariable(2:end)], gpLearnerString);
            end
            
            switch (gpLearnerString)
                case 'GPStandard'
                    gpLearner = Learner.SupervisedLearner.GPLearner(dataManager, gp);
                    
                case 'GPSparse'
                    gpLearner = Learner.SupervisedLearner.SparseGPLearner(dataManager, gp);
                    
                otherwise
                    error('GPLearner String %s not known\n', gpLearnerString);
            end
        end
    end
    
    
    methods
        function obj = GPHyperParameterLearner(dataManager, gp, gpReferenceSetLearner)
            
            gpLearner = Kernels.Learner.GPHyperParameterLearner.createGPLearner(dataManager, gp);
            optimizationName = ['GPOptimization', upper(gp.outputVariable(1)), gp.outputVariable(2:end)];
            settings = Common.Settings();
            settings.setProperty([optimizationName, 'OptiAbsfTol'], 0.1);
            settings.setProperty([optimizationName, 'numIterations'], 100);
            
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, gpLearner, optimizationName, true);
            obj = obj@Learner.AbstractInputOutputLearnerInterface(dataManager, gp);
            obj.initializerParams = Kernels.Learner.MedianBandwidthSelectorAndGPVariance(dataManager, gp, gpReferenceSetLearner, gpLearner);
            obj.initializerParams.updateReferenceSet = false;
            
            obj.gpReferenceSetLearner = gpReferenceSetLearner;
            obj.gp = gp;
            obj.gpLearner = gpLearner;
            obj.dataManager = dataManager;
        end
               
        function [] = learnFinalModel(obj, data)
            obj.gpLearner.learnFunction(obj.inputData, obj.outputData, obj.weighting);
        end
        
        function [] = setInputVariablesForLearner(obj, varargin)
            obj.setInputVariablesForLearner@Learner.AbstractInputOutputLearnerInterface(varargin{:});
            
            obj.initializerParams.setInputVariablesForLearner(varargin{:});
            obj.gpLearner.setInputVariablesForLearner(varargin{:});
        end
        
        function [] = setOutputVariableForLearner(obj, outputVariable)
            obj.setOutputVariableForLearner@Learner.AbstractInputOutputLearnerInterface(outputVariable);
            
            obj.initializerParams.setOutputVariableForLearner(outputVariable);
            obj.gpLearner.setOutputVariableForLearner(outputVariable);
            
            obj.gp.restrictToRangeLogLik = obj.dataManager.isRestrictToRange(obj.outputVariable);
        end
        
        function [] = setWeightName(obj, weightName)
            obj.gpLearner.setWeightName(weightName);
            obj.initializerParams.setWeightName(weightName);
            
            obj.setWeightName@Learner.AbstractInputOutputLearnerInterface(weightName);
        end
        
        
        
        %         function [numParams] = getNumHyperParameters(obj)
        %             numParams = obj.gp.getNumHyperParameters();
        %         end
        %
        %         function [params] = getMinParameterRange(obj)
        %             params = obj.getHyperParameters() * 0.95;
        %         end
        %
        %         function [params] = getMaxParameterRange(obj)
        %             params = obj.getHyperParameters() * 1.05;
        %         end
        
        function [] = processTrainingData(obj, data)
            if (~isempty(obj.gpReferenceSetLearner))
                obj.gpReferenceSetLearner.updateModel(data);
            end
            
            obj.inputData = data.getDataEntry(obj.inputVariables{1});
            obj.outputData = data.getDataEntry(obj.outputVariable);
            
            indexValid = not(any(isnan(obj.inputData), 2));                                    
            
            if (~isempty(obj.gpLearner.weightName))
                obj.weighting = data.getDataEntry(obj.weightName{:});
                obj.weighting = obj.weighting;
            else
                obj.weighting = ones(size(obj.inputData,1),1);
            end
            obj.inputData = obj.inputData(indexValid, :);
            obj.outputData = obj.outputData(indexValid, :);
            obj.weighting = obj.weighting(indexValid, :);
            
            obj.weighting = obj.weighting / max(obj.weighting);            
        end
        
        function [] = initializeParameters(obj, data)
            obj.initializerParams.updateModel(data);
        end
        
        function [] = afterOptimizationHook(obj)
            fprintf('HyperParameters after Optimization:');
            obj.getParametersToOptimize()
        end
        
        
    end
    
    methods (Abstract)
        %         [funcVal, gradient] = objectiveFunction(obj, params);
    end
    
end

