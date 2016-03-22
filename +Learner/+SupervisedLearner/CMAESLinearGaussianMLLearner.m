classdef CMAESLinearGaussianMLLearner < Learner.SupervisedLearner.LinearFeatureFunctionMLLearner
    
    
    properties
        
        policy;
        
        
        
        shape;
        
        weights;
        mueff;
        mu;
        sigma;
          % Strategy parameter setting: Adaptation
        cc ; % time constant for cumulation for C
        cs ;  % t-const for cumulation for sigma control
        c1 ;    % learning rate for rank-one update of C
        cmu;  % and for rank-mu update
        damps; % damping for sigma 
        pc ; 
        ps ;                                              % usually close to 1
        chiN;
        counteval = 0;
        eigeneval = 0;
        
        fit;
        rewardName;
        parameterName;
        
        
    end
    
    properties(SetObservable, AbortSet)
        learnRateNESMeans;
        learnRateNESSigmas;
        lambda;
        %mu;
        
    end

    
    % Class methods
    methods
        function obj = CMAESLinearGaussianMLLearner(dataManager, linearfunctionApproximator, varargin)
            % @param dataManager Data.DataManger to operate on
            % @param linearfunctionApproximator function object that will  be learned needs to be of gaussian type
            % @param varargin contains the following optional arguments in this order: weightName, inputVariables, outputVariable (see superclass SupervisedLearner)
            obj = obj@Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            mapName = linearfunctionApproximator.outputVariable;
            mapName(1) = upper(mapName(1));
            
            if (~exist('rewardName', 'var'))
                rewardName = 'returns';
            end
            
            if (~exist('parameterName', 'var'))
                parameterName = 'parameters';
            end
            
            dimParameters = dataManager.getNumDimensions(parameterName);
            obj.pc = zeros(dimParameters,1); 
            obj.ps = zeros(dimParameters,1);
            
            obj.sigma = 1;
            obj.counteval = 0;
            obj.eigeneval = 0;

            

            %obj.fpt
            %obj.xopt
            %Common.Settings().setProperty('newSamplesEpisode', obj.lambda);
            %Common.Settings().setProperty('initialSamplesEpisode', 0);
            %Common.Settings().setProperty('maxSamples', obj.lambda);
            
        end
        
        function obj = initObject(obj)
            % abstract init function
            
            obj.initObject@Learner.RLLearner();
            
            
            
            %obj.settings.setParameter('newSamples', lambda);
            %obj.settings.setParameter('initialSamples', 0);
            %obj.settings.setParameter('maxSamples', lambda);
        end
        
        function [] = registerLearningFunction(obj)
            obj.addDataManipulationFunction('computePolicyUpdate', {obj.rewardName, obj.parameterName}, {});
        end
        
        
        
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
            
            dimParameters = size(outputData,2);
            obj.mu = size(outputData,1);
            obj.weights = weighting/sum(weighting); 
            obj.mueff=sum(obj.weights)^2/sum(obj.weights.^2);
            obj.cc = (4 + obj.mueff/dimParameters) / (dimParameters+4 + 2*obj.mueff/dimParameters); % time constant for cumulation for C
            obj.cs = (obj.mueff+2) / (dimParameters+obj.mueff+5);  % t-const for cumulation for sigma control
            obj.c1 = 2 / ((dimParameters+1.3)^2+obj.mueff);    % learning rate for rank-one update of C
            obj.cmu = min(1-obj.c1, 2 * (obj.mueff-2+1/obj.mueff) / ((dimParameters+2)^2+obj.mueff));  % and for rank-mu update
            obj.damps = 1 + 2*max(0, sqrt((obj.mueff-1)/(dimParameters+1))-1) + obj.cs; % damping for sigma 
           % obj.pc = zeros(dimParameters,1); 
           % obj.ps = zeros(dimParameters,1);                                           % usually close to 1
            
            obj.chiN=dimParameters^0.5*(1-1/(4*dimParameters)+1/(21*dimParameters^2)); 
            
            
            
            
            
            
            obj.counteval = obj.counteval + obj.mu;
            
         %   arfitness = -rewards';
         %   arx = parameters';
            

            
            
            [B D] = eig(obj.functionApproximator.getCovariance);
                % B defines the coordinate system
              % diagonal D defines the scaling
            D = sqrt(diag(D));
            xold = obj.functionApproximator.bias;
            meanOld = obj.functionApproximator.getExpectation(size(inputData,1), inputData);
             % for k=1:obj.lambda,
                
             %   arx(:,k) = xold +  B * (D .* randn(dim,1)); % m + sig * Normal(0,C) 
             %   x = arx(:,k);
             %   arfitness(k) = 100*sum((x(1:end-1).^2 - x(2:end)).^2) + sum((x(1:end-1)-1).^2);
                
             % end
               
              
            % REWARD = mean(-arfitness)
           % [arfitness, arindex] = sort(arfitness);
            
           
            D = D./obj.sigma;
            
            %xmean = arx(:,arindex(1:obj.mu)) * obj.weights;
            %obj.policy.setBias(xmean);
            obj.learnFunction@Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(inputData, outputData, weighting);
            xmean = obj.functionApproximator.bias;
            
            C = B * diag(D.^2) * B';            % covariance matrix C
            %C = obj.policy.getCovariance;
            
            
            
            invsqrtC = B * diag(D.^-1) * B';    % C^-1/2 
            
             % Cumulation: Update evolution paths
            obj.ps = (1-obj.cs) * obj.ps ... 
          + sqrt(obj.cs*(2-obj.cs)*obj.mueff) * invsqrtC * (xmean-xold) / obj.sigma; 
          %   hsig = sum(obj.ps.^2)/(1-(1-obj.cs)^(2*obj.counteval/obj.mu))/dimParameters < 2 + 4/(dimParameters+1);
          %   obj.pc = (1-obj.cc) * obj.pc ...
          %+ hsig * sqrt(obj.cc*(2-obj.cc)*obj.mueff) * (xmean-xold) / obj.sigma;
            
      
    % Adapt covariance matrix C
            artmp = (1/obj.sigma) * (outputData' - meanOld');  % mu difference vectors
                              % regard old matrix  
       %  + obj.c1 * (obj.pc * obj.pc' ...                % plus rank one update
        %         + (1-hsig) * obj.cc*(2-obj.cc) * C) ... % minor correction if hsig==0
         C = (1-obj.cmu) * C + obj.cmu * artmp * diag(obj.weights) * artmp'; % plus rank mu update 

      % Adapt step size sigma
    %obj.sigma =obj.sigma * exp((obj.cs/obj.damps)*(norm(obj.ps)/obj.chiN - 1)); 
    obj.sigma = 1;
  %   if obj.counteval - obj.eigeneval > obj.mu/(obj.c1+obj.cmu)/dimParameters/10  % to achieve O(N^2)
  %    obj.eigeneval = obj.counteval;
  %    C = triu(C) + triu(C,1)'; % enforce symmetry
  %   end
     [B D] = eig(C);
     C = B * ((obj.sigma.^2).*D) * B';
     obj.functionApproximator.setCovariance(C);
            
        end
        
        
        % methods
    end
end