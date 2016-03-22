classdef PlotterFunctions
    %PLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        
       function [standardInput, outputValue] = plotOutputFunctionSlice1D(functionObj, dim1, minValue, maxValue, standardInput, numBins, varargin)
            
            stateValues1 = linspace(minValue, maxValue, numBins);
            standardInput = repmat(standardInput, numBins, 1);
            standardInput(:,dim1) = stateValues1;
            if (ismethod(functionObj, 'getExpectationGenerateFeatures'))
                outputValue = functionObj.getExpectationGenerateFeatures(numBins, standardInput);
            else
                outputValue = functionObj.getExpectation(numBins, standardInput);
            end
               
            plot(standardInput(:, dim1), outputValue);
        end
        
        function [] = plotOutputFunctionSlice2D(functionObj, dim1, dim2, minValue, maxValue, standardInput, numBins)
            stateValues1 = linspace(minValue(1), maxValue(1), numBins);
            stateValues2 = linspace(minValue(2), maxValue(2), numBins);
            
            [stateValuesGrid1, stateValuesGrid2] = meshgrid(stateValues1, stateValues2);
            
            stateValuesGrid1 = stateValuesGrid1(:);
            stateValuesGrid2 = stateValuesGrid2(:);
            
            standardInput = repmat(standardInput, size(stateValuesGrid1,1), 1);
            standardInput(:,dim1) = stateValuesGrid1;
            standardInput(:,dim2) = stateValuesGrid2;            
            
            if (ismethod(functionObj, 'getExpectationGenerateFeatures'))
                outputValue = functionObj.getExpectationGenerateFeatures(size(standardInput,1), standardInput);
            else
                outputValue = functionObj.getExpectation(size(standardInput,1), standardInput);
            end
            outputValue = reshape(outputValue, numBins, numBins);
            surf(stateValues1, stateValues2, outputValue);
            xlabel('dim1');
            ylabel('dim2');
            zlabel(functionObj.outputVariable);
            
        end
        
        function [] = plotOutputFunctionMaxSlice2D(functionObj, dim1, dim2, dimMax, minValue, maxValue, standardInput, numBins)
            stateValues1 = linspace(minValue(1), maxValue(1), numBins);
            stateValues2 = linspace(minValue(2), maxValue(2), numBins);
            stateValuesMax = linspace(minValue(3), maxValue(3), numBins);
            
            [stateValuesGrid1, stateValuesGrid2] = meshgrid(stateValues1, stateValues2);
            
            stateValuesGrid1 = stateValuesGrid1(:);
            stateValuesGrid2 = stateValuesGrid2(:);
            
            standardInput = repmat(standardInput, size(stateValuesGrid1,1), 1);
            standardInput(:,dim1) = stateValuesGrid1;
            standardInput(:,dim2) = stateValuesGrid2;            
            
            outputValueMax = zeros(size(standardInput, 1), 1);
            for i = 1:length(standardInput)
                standardInputTmp = repmat(standardInput(i,:), numBins, 1);
                standardInputTmp(:, dimMax) = stateValuesMax;
                
                if (ismethod(functionObj, 'getExpectationGenerateFeatures'))
                    outputValue = functionObj.getExpectationGenerateFeatures(size(standardInputTmp,1), standardInputTmp);
                else
                    outputValue = functionObj.getExpectation(size(standardInputTmp,1), standardInputTmp);
                end
                [~, maxInd] = max(outputValue);
                outputValueMax(i) = stateValuesMax(maxInd);
            end
            outputValueMax = reshape(outputValueMax, numBins, numBins);
            surf(stateValues1, stateValues2, outputValueMax);
            xlabel('dim1');
            ylabel('dim2');
            zlabel('dimMax');
            
        end
        
    end
    
end

