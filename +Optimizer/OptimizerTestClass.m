classdef OptimizerTestClass < Common.IASObject;
    %OPTIMIZERFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numIterationsArray
        settingsStructCell        
    end
    
    methods
        
        function obj = OptimizerTestClass(numIterationsArray)
            obj = obj@Common.IASObject();
            obj.numIterationsArray = numIterationsArray;
            
           
        end
        
        function [] = addAlgorithmToTest(obj, algorithmName, varargin)
            optiAlgorithm.OptiAlgorithm = algorithmName;
            for i = 1:(length(varargin) / 2)
                optiAlgorithm.(varargin{i * 2 - 1}) = varargin{i * 2};                
            end
            obj.settingsStructCell{end + 1} = optiAlgorithm;
        end
        
        function [evaluationTimes, functionValues] = testOptimizer(obj, f, x0)
            evaluationTimes = zeros(size(obj.settingsStructCell,1), length(obj.numIterationsArray));
            functionValues = zeros(size(obj.settingsStructCell,1), length(obj.numIterationsArray));
            settings = Common.Settings();
            for i = 1:size(obj.settingsStructCell,2)
                settings.setPropertiesStruct(obj.settingsStructCell{i});
                fprintf('Evaluating Algorithm %d\n', i);
                for j = 1:length(obj.numIterationsArray)
                    settings.setProperty('maxNumOptiIterations', obj.numIterationsArray(j));
                    optimizer = Optimizer.OptimizerFactory.createOptimizer(numel(x0), '', [], []);

                    tic;
                    [xopt, functionValues(i,j)] = optimizer.optimize(f, x0);
                    evaluationTimes(i, j) = toc;
                    fprintf('.');
                end
                 
                fprintf('FunctionValues: ');
                functionValues(i,:)
                fprintf('EvaluationTimes: ');
                evaluationTimes(i,:)
                
            end
            
        end
    end
    
end

