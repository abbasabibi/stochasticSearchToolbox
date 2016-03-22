classdef Layer < handle
    % LAYER Describes a single Layer of the ANN. Every unit in this layer
    % has the same activation function. 
    % !!! Layer of an "feed-forward"-network only !!!
    
    properties
       activationFunction;          % activation function of the current layer
       biasValue;                   % default is 1
       biasWeights;                 % default is a vector of 0's
       weights;                     % weight matrix: rows are units; columns are edges
    end
    
    methods
        function layer = Layer(weights, activationFunction)
            layer.activationFunction = str2func(activationFunction);
            layer.biasValue = 1;
            %layer.biasWeights = 0;
            layer.weights = [weights, zeros(size(weights, 1), 1)];
        end
        
        function [z, H] = forwardSweep(layer, input)
            a = layer.weights * input; % + layer.biasWeights * layer.biasValue;
            if nargout > 1
                [z, h] = layer.activationFunction(a);
                z = [z; layer.biasValue];
                H = diag(h);
            else
                z = layer.activationFunction(a);
                z = [z; layer.biasValue];
            end
        end
        
%         function layer = Layer(units, weights, activationFunction, bias)
%             layer.units = units;
%             layer.weights = weights;
%             layer.activationFunction = str2func(activationFunction);
%         end
%         
%         function layerOutput = calcValue(layer, input)
%             for i = 1 : size(layer.weights, 2)
%                 in(i) = input*layer.weights(:,i);
%             end
%             layer.input = in;
%             layer.output = layer.activationFunction(in, 0);
%             layerOutput = layer.output;
%         end
%         
%         function output = getValue(layer)
%             output = layer.output;
%         end
% 
%         function layer = setWeights(layer, newWeights)
%             layer.weights = newWeights;
%         end
%     end
    end
    
end

