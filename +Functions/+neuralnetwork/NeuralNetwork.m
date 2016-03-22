classdef NeuralNetwork < Functions.Mapping & Functions.Function
    
    properties (SetAccess = protected)
        layers;
    end


    methods

        function obj = NeuralNetwork(dataManager, outputVariable, inputVariables, functionName, featureGenerator)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName};
            end

            obj = obj@Functions.Mapping(superargs{:});
            obj = obj@Functions.Function();


            obj.registerMappingInterfaceFunction();
        end

        function [] = initObject(obj)
            
            % init your object
        end

        function [value] = getExpectation(obj, numElements, input)
            value = obj.getnetwokOutput(input);
        end

        function [value, gradient] = getExpectationAndGradient(obj, numElements, input)
           [value, gradient] = obj.feedForward(input);
        end


        function [] = setParameters(weights)
            for i = 1 : size(obj.layers, 2)
                obj.setWeightsOfLayer(i, weights{i});
            end
        end
        
        
        function setBias(ann, layer, biasWeights)
            % TODO hat jede Unit im Layer den gleichen bias also das gleiche
            % Gewicht?
            ann.layers(layer).weights(:, end) = biasWeights;
        end
        
        % TODO right now it's inclusive the bias weights
        function setWeightsOfLayer(ann, layer, weights)
            ann.layers(layer).weights = weights;
        end
        
        
        function z = networkOutput(ann, x)
            z = [x; 1];                                         % [x; biasValue]
            for layer = 1: size(ann.layers, 2);
                z = ann.layers(layer).forwardSweep(z);
            end
            z = z(1:end-1);                                     % removing biasValue from output
        end

        
        % feedForward of one single training input
        function [allZ, allH] = feedForward(ann, x)
            z = [x; 1];                                                             % [x; biasValue]
            if nargout > 1
                for layer = 1: size(ann.layers, 2);
                    [allZ{layer}, allH{layer}] = ann.layers(layer).forwardSweep(z);
                    z = allZ{layer};
                end
            else
                for layer = 1: size(ann.layers, 2);
                    allZ{layer} = ann.layers(layer).forwardSweep(z);
                    z = allZ{layer};
                end
            end
            allZ{end} = allZ{end}(1:end-1);
            allZ = [[x; 1], allZ];
        end
    end
end