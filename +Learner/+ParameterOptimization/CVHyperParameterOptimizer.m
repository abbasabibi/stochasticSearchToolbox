classdef CVHyperParameterOptimizer < Learner.ParameterOptimization.AbstractHyperParameterOptimizer
     % Tunes hyperparameters using a cross-validation objective
     % (either at sample or trajectory level)
     

    properties
        
        supervisedLearner
        
        numFolds
        initialParameters
        
        inputTrain %cellarray
        inputTest %cellarray
        outputTrain %...
        outputTest
        weightsTrain
        weightsTest
        
        inputAll
        outputAll
        weightsAll
        
        errorFc
    end
        
    
    methods
        function obj = CVHyperParameterOptimizer(dataManager, supervisedlearner,errorFc, numFolds, initialParameters, name,varargin)
            % objective: class with "objective" function or function handle
            % supervisedlearner: implements supervisedlearner interface
            % paramtericobject: object with get/set hyperparameter functionality
            % errorFc: takes functionapproximator, testset
            obj = obj@Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, supervisedlearner, name, varargin{:});
            

            
%             if isa(objective,'function_handle')
%                 obj.objective = @(params,data) objective(params,data);
%             elseif ismethod(objective, 'objective') %class with objective method
%                 obj.objective = @(params,data) objective.objective(params,data);
%             else
%                 error('CVHyperParameterOptimizer: not a valid objective!')
%             end
            obj.supervisedLearner = supervisedlearner;
            obj.numFolds = numFolds;
            obj.initialParameters = initialParameters;
            obj.errorFc = errorFc;
        end
        
        %function obj = updateModel(obj, data)             
        %    obj.processTrainingData(data);
        %    if (~ obj.initializedHyperParameters || obj.ReinitializeHyperParameters)
        %        obj.initializeParameters(data);
        %        obj.initializedHyperParameters  = true;
        %    end
        %    obj.optimizeHyperParameters();
        %end
        function [] = processTrainingData(obj, data)
            n_layers = data.getMaxDepth;
            
            %find the first non-singleton layer
            for layerIndex = 1:n_layers
                if data.getDataStructureForLayer(layerIndex).numElements > 1
                    break
                end
            end
            n_samples = data.getDataStructureForLayer(layerIndex).numElements;   

            obj.inputTrain   = cell(obj.numFolds,1);
            obj.inputTest    = cell(obj.numFolds,1);
            obj.outputTrain  = cell(obj.numFolds,1);
            obj.outputTest   = cell(obj.numFolds,1);
            obj.weightsTrain = cell(obj.numFolds,1);
            obj.weightsTest  = cell(obj.numFolds,1);
            for i = 1:obj.numFolds
                val_start = i;
                
                onesCell = num2cell(ones(layerIndex-1,1)); %index 1 for all singleton dimensions
                val_idx = [onesCell, val_start:obj.numFolds:n_samples ];
                train_idx = [onesCell, setdiff(1:n_samples, val_idx{layerIndex} ) ];

                obj.inputTrain{i}   = cell2mat(data.getDataEntryCellArray(obj.supervisedLearner.inputVariables, train_idx{:} ));
                obj.inputTest{i}    = cell2mat(data.getDataEntryCellArray(obj.supervisedLearner.inputVariables, val_idx{:} ));
                obj.outputTrain{i}  = data.getDataEntry(obj.supervisedLearner.outputVariable, train_idx{:} ); 
                obj.outputTest{i}   = data.getDataEntry(obj.supervisedLearner.outputVariable, val_idx{:} );
                obj.weightsTrain{i} = data.getDataEntry(obj.supervisedLearner.weightName, train_idx{:} );
                obj.weightsTest{i}  = data.getDataEntry(obj.supervisedLearner.weightName, val_idx{:} );
            end
            
            obj.inputAll = data.getDataEntryCellArray(obj.supervisedLearner.inputVariables);
            obj.inputAll = obj.inputAll{1};
            obj.outputAll = data.getDataEntry(obj.supervisedLearner.outputVariable);
            obj.weightsAll = data.getDataEntry(obj.supervisedLearner.weightName);
            

        end
        
        function [] = initializeParameters(obj, ~)
            obj.supervisedLearner.setHyperParameters(obj.initialParameters )
        end
              
      
        function [funcVal] = objectiveFunction(obj, params)     
            funcVal = 0;
            obj.setParametersToOptimize(params);
            for i = 1:obj.numFolds
                
                if(numel(obj.weightsTest{i})>0)
                    obj.supervisedLearner.learnFunction(obj.inputTrain{i}, obj.outputTrain{i}, obj.weightsTrain{i});
                    funcVal = funcVal + obj.errorFc(obj.supervisedLearner.functionApproximator, obj.inputTest{i}, obj.outputTest{i}, obj.weightsTest{i});
                else
                    obj.supervisedLearner.learnFunction(obj.inputTrain{i}, obj.outputTrain{i});
                    funcVal = funcVal + obj.errorFc(obj.supervisedLearner.functionApproximator, obj.inputTest{i}, obj.outputTest{i}, ones(size(obj.outputTest{i})));
                end
            end
        end
                
        function [] = learnFinalModel(obj)
            obj.supervisedLearner.learnFunction(obj.inputAll, obj.outputAll, obj.weightsAll);
        end

            
    end
    
    methods(Static)
        function error = squaredError(functionApproximator, inputTest, outputTest, weighting)
            estimated = functionApproximator.getExpectation(size(inputTest,1), inputTest );
            if(exist('weighting','var'))
                error = sum(sum(bsxfun(@times,(estimated - outputTest).^2, weighting)));
            else
                error = sum(sum((estimated - outputTest).^2));
            end
            
        end
        
        function objective = negLogLikelihood(functionApproximator, inputTest, outputTest, weighting)
            if(exist('weighting','var'))
                objective = -sum(weighting .* functionApproximator.getDataProbabilities(inputTest, outputTest ));
            else
                objective = -sum(functionApproximator.getDataProbabilities(inputTest, outputTest ));
            end
            
        end
    end
    

    
end

