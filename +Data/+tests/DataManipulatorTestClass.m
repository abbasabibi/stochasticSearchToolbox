%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a test class for the data manipulator. We show how we can define
% data manipulation functions for different data entries (also on different
% layers).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef DataManipulatorTestClass < Data.DataManipulator
    
    properties (Access = protected)
        
    end
    
    methods

        % Constructor of the class
        function obj =  DataManipulatorTestClass(dataManager)
            obj = obj@Data.DataManipulator(dataManager);
            
            % Define data manipulation functions. Arguments mean:
            % - 'sampleRandomParameters': name of the function, has be 
            %   exactly the same as the function you implement!
            % - no input
            % - 'parameters' as output
            obj.addDataManipulationFunction('sampleRandomParameters', {}, {'parameters'});
            
            % In this case:
            % - 'sampleStates' is the name of the function
            % - 'parameters' are the input
            % - 'states' are the output
            %   Note that 'parameters' and 'states' are on a different layer 
            %   of the hierarchy. The last argument tells us that we want to
            %   know the number of elements that we have to return.
            % - Data.DataFunctionType.PER_EPISODE specifies the call type of
            %   the function. Here, we want to call the function per episode,
            %   i.e., the function call is automatically iterated over all
            %   episodes.
            obj.addDataManipulationFunction('sampleStates', {'parameters'}, {'states'}, Data.DataFunctionType.PER_EPISODE, true);
            
            % Additional arguments are given as above.
            obj.addDataManipulationFunction('sampleActions', {'parameters', 'states'}, {'actions'}, Data.DataFunctionType.PER_EPISODE, true);
        end
        
        % This function does not get any input, hence, it automatically 
        % gets the number of elements to create as input
        function [parameters] = sampleRandomParameters(obj, numElements)
            fprintf('Called sampleRandomParameters with %d elements\n', numElements);
            parameters = ones(numElements, 10);
        end
        
        function [states] = sampleStates(obj, numElements, parameters)
            fprintf('Called sampleStates with an %d %d parameter array and %d numElements\n', size(parameters,1), size(parameters,2), numElements);
            % The sampleStates function is called per episode. This means
            % that 'numElements' tells us how many states we have to
            % create for the current episode (i.e., number of steps). The
            % argument 'parameters' contains the parameter vector for this
            % single episode (1x10 vector). Here we just create a random
            % state matrix.
            states = bsxfun(@times, randn(numElements, 2), parameters(1:2));
        end
        
        function [actions] = sampleActions(obj, numElements, parameters, states)
            fprintf('Called sampleActions with an %d %d parameter array and %d numElements\n', size(parameters,1), size(parameters,2), numElements);
            actions = bsxfun(@minus, states,  parameters(1:2));
        end
        
    end
    
end