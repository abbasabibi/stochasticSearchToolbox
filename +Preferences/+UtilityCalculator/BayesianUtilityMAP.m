classdef BayesianUtilityMAP < Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator
    
    properties(SetObservable)
        solver;
        prefDecay = 1.0;
        burnInSamples = 50000;
        sampleCount = 100000;
        shapeM = 1;
        covm;
    end
    
    methods
        function obj =  BayesianUtilityMAP(dataManager,featureName,varargin)
            obj = obj@Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator(dataManager,featureName,varargin{:});
            obj.linkProperty('sampleCount','bayesSamplerSamples');
            obj.linkProperty('shapeM','sigmoidShapeFactor');
            obj.covm = eye(featureName.dimInput+1);
            obj.solver = Preferences.UtilityCalculator.Bayesian.BayesPreferenceSolver(chol(obj.covm),obj.sampleCount,obj.shapeM);
            obj.linkProperty('prefDecay');
            obj.linkProperty('burnInSamples','bayesSamplerBurnIn');
        end
        
        function [weights] = calculateUtilityFunction(obj,c,trajs,fe,prefs,iteration,importance)
            prefIds = find(prefs==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            
            preferenceCount = size(prefIds,1);
            %trajectoryCount = size(trajs,1);
            featureCount = size(fe,2);
            
            timportance = ones(preferenceCount,1);
            currentIter = max(iteration);
            
            if preferenceCount==0 || size(trajs,1)<2
                weights = [];
                disp('Preference count was zero, not calculating');
            else
                %value differences
                A = zeros(preferenceCount,featureCount);
                B = zeros(preferenceCount,featureCount);
                for id = 1:preferenceCount
                    [i,j] = ind2sub(size(prefs),prefIds(id));
                    %A(id,:) = fe(i,:)/norm(fe(i,:))-fe(j,:)/norm(fe(j,:));
                    A(id,:) = fe(i,:);
                    B(id,:) = fe(j,:);
                    %importance(id) = obj.prefDecay^-(currentIter-max(iteration(i),iteration(j)));
                    %timportance(id) = sum(abs(A(id,:)-B(id,:)))^-1;
                    %timportance(id) = min(importance(i),importance(j));
                end
                params = obj.linearFunc.getParameterVector();
                [theta, logL] = obj.solver.solve(params',A,B,timportance);
                
                logL = logL(obj.burnInSamples+1:end);
                
                prior = zeros(numel(logL),1);
                
                D = size(theta,2);
                U = chol(obj.covm);
                const = -0.5 * D * log(2*pi)-sum(log(diag(U)));
                
                for i=1:numel(logL)
                    thetaC = theta(obj.burnInSamples+i,:);
                    prior(i) = -0.5 * thetaC *obj.covm^-1 * thetaC' + const;
                end
                
                prior = prior-log(norm(exp(prior),1));
                logL = logL-log(norm(exp(logL),1));
                
                post = logL+prior;
                
                [~,idx] = max(post);
                weights = theta(obj.burnInSamples+idx,:);
                %for i=size(theta,1)
                %    t = theta(i,:);
                %    oldLL(i) = obj.solver.getLogLL(t,A,B,timportance);
                %end
                %klDiv = obj.getKLDivergence(exp(oldLL'),exp(logL))
                
                %weights = mean(theta(obj.burnInSamples:100:end,:));
                %klDiv = obj.getKLDivergence(abs(params'),abs(weights))
                %var(t2(obj.burnInSamples:end,:))
            end
        end
        
        function [divKL] = getKLDivergence(obj, qWeighting, pWeighting)
            
            p = pWeighting;
            p = p / sum(p);
            
            q = qWeighting;
            q = q / sum(q);
            
            index = p > 10^-10;
            divKL = sum(p(index)  .* log(p(index) ./ q(index)));
            
        end
        
    end
    
end

