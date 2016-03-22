classdef Mu_Lambda_ES < Optimizer.BoxConstrained;
    
    %   INPUT DATA:
    %
    %   - mu:      Parent population size (positive integer number)
    %   - lambda:  Offspring population size (positive integer number)
    %   - gen:     Number of generations (positive integer number)
    %   - sel:     Selection scheme (Pag. 78 in (BACK)):
    %                  * ',' = (mu, lambda)-selection scheme
    %                  * '+' = (mu + lambda)-selection scheme
    %   - rec_obj: Type of recombination to use on objective variables
    %              (Pag. 74 in (BACK)):
    %                  * 1   = No recombination
    %                  * 2   = Discrete recombination
    %                  * 3   = Panmictic discrete recombination
    %                  * 4   = Intermediate recombination
    %                  * 5   = Panmictic intermediate recombination
    %                  * 6   = Generalized intermediate recombination
    %                  * 7   = Panmictic generalized intermediate recombination
    %   - rec_str: Type of recombination to use on strategy parameters
    %              (Pag. 74 in (BACK)).
    %   - u:       External excitation (if it does not exist, type 0 (zero))
    %   - obj:     Vector with the desired results
    %   - nf:      Length of the output vector
    %   - xDimension:       Length of the vector x_0 (positive integer number)
    
    properties (SetObservable, AbortSet)
        ESmu = 1;
        ESlambda = 10;
        ESgen = 10;
        ESsel = '+';
        ESrec_obj = 1;
        ESrec_str = 1;
        ESu = 0;
        ESnf = 1;
    end
    
    methods
        function obj = Mu_Lambda_ES(numParams, lowerBound, upperBound, varargin)
            obj = obj@Optimizer.BoxConstrained(numParams, lowerBound, upperBound, varargin{:});
            obj.linkProperty('ESmu');
            obj.linkProperty('ESlambda');
            obj.linkProperty('ESgen');
            obj.linkProperty('ESsel');
            obj.linkProperty('ESrec_obj');
            obj.linkProperty('ESrec_str');
            obj.linkProperty('ESu');
            obj.linkProperty('ESnf');
        end
        
        function setOptions(obj)
        end
        
        function [params, val, numIterations] = optimizeInternal(obj, func, params)
            limits = transpose([obj.lowerBound;obj.upperBound]);
            %   OUTPUT DATA:
            %
            %   - min_x:   Cell with the parent population, and whose last component
            %              minimizes the objective function 'f'
            %              vector)
            %   - min_f:   Cell with the values of the Objective Function 'f'
            %              (length(f) x 1 vector)
            %   - off:     Cell with the offspring population in each generation
            %   - EPS:     Vector with the minimum error of each generation (gen x 1
            %              vector)
            %   - numIterations:       Number of iterations the algorithm ran (Final number of
            %              generations)
            objective = @(params_, u_) obj.objectiveFunction(func, params_, u_);
            if size(params,1)==obj.ESmu
                [min_x, min_f, off, EPS,numIterations] = Optimizer.EvolutionaryStrategies.evolution_strategy(objective, obj.ESmu, obj.ESlambda, obj.ESgen, obj.ESsel, obj.ESrec_obj, obj.ESrec_str, obj.ESu, zeros(obj.ESnf,1), obj.ESnf, obj.numParams, limits, transpose(params));
            else
                [min_x, min_f, off, EPS,numIterations] = Optimizer.EvolutionaryStrategies.evolution_strategy(objective, obj.ESmu, obj.ESlambda, obj.ESgen, obj.ESsel, obj.ESrec_obj, obj.ESrec_str, obj.ESu, zeros(obj.ESnf,1), obj.ESnf, obj.numParams, limits);
            end
            val = min_f{numIterations}(1);
            params = transpose(min_x{numIterations}(:,1));
        end
        
    end
    
    
end

