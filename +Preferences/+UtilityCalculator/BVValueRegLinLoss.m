classdef BVValueRegLinLoss < Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator
    
    properties(SetObservable)
        prefDecay = 1.1;
    end
    
    methods
        function obj =  BVValueRegLinLoss(dataManager,featureName,varargin)
            obj = obj@Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator(dataManager,featureName,varargin{:});
            obj.linkProperty('prefDecay');
        end
                
        function [weights] = calculateUtilityFunction(obj,c,trajs,fe,prefs,iteration,importance)
            prefIds = find(prefs==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            
            preferenceCount = size(prefIds,1);
            trajectoryCount = size(trajs,1);
            featureCount = size(fe,2);
            
            timportance = ones(preferenceCount,1);
            
            currentIter = max(iteration);   

            %importance = zeros(size(importance));
            %dominated = find(prefs(1,:)==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            %rank=1;
            %importance(1)=rank;
            %while ~isempty(dominated)                
            %    rank = rank+1;
            %    importance(dominated)=rank;
            %    dominated = find(prefs(dominated,:)==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            %end
            %importance(importance~=0)=abs(importance(importance~=0)-max(importance))+1;
            
            if preferenceCount==0 || size(trajs,1)<2
                weights = [];
                disp('Preference count was zero, not calculating');
            else
                %value differences
                A = zeros(preferenceCount,featureCount);
                for id = 1:preferenceCount
                    [i,j] = ind2sub(size(prefs),prefIds(id));
                    %A(id,:) = fe(i,:)/norm(fe(i,:))-fe(j,:)/norm(fe(j,:));
                    A(id,:) = fe(j,:)-fe(i,:);
                    %timportance(id) = obj.prefDecay^-(currentIter-max(iteration(i),iteration(j)));
                    timportance(id) = max(importance(i),importance(j));
                    %timportance(id) = 1.1^min(importance(i),importance(j));
                    %timportance(id) = importance(i)-importance(j);
                end
                if max(timportance)==0
                    timportance = ones(size(timportance));
                end
                timportance = timportance./norm(timportance,1).*numel(timportance);
                timportance(timportance<0) = mean(timportance(timportance<0));
                %A = unique(A,'rows');
                %fprintf('Removed %d non unique preferences\n', preferenceCount-size(A,1));
                fprintf('Effective preference count: %d\n', preferenceCount);
                                                
                preferenceCount = size(A,1);
                
                %weights for features (A)
                f = zeros(featureCount,1);
                
                lb=-Inf(featureCount,1);
                ub=Inf(featureCount,1);
                %lb=-ones(featureCount,1);
                %ub=ones(featureCount,1);
                
                %add margin variable (Xi) and create eq constraint
                A = [-A eye(preferenceCount)];
                b = zeros(preferenceCount,1);
                
                f = [f;timportance.*ones(preferenceCount,1)]; %Xi

                lb= [lb;-Inf(preferenceCount,1)];
                ub= [ub;Inf(preferenceCount,1)];
                
                %add value regularizer
                feCount = size(fe,1);
                A = [A zeros(preferenceCount, feCount) ;fe zeros(feCount, preferenceCount) eye(feCount)];
                b = [b; zeros(feCount,1)];

                Q = zeros(size(f,1));
                Q = [Q zeros(size(f,1),feCount);zeros(feCount,size(f,1)) 10e-4*eye(feCount)];
                
                f = [f;zeros(feCount,1)];

                lb= [lb;-Inf(feCount,1)];
                ub= [ub;Inf(feCount,1)];
                
                %add trajectory weights alpha
                A = [A zeros(preferenceCount+feCount,trajectoryCount);
                    -eye(featureCount)  zeros(featureCount,preferenceCount+feCount) trajs'];
                b = [b;
                    zeros(featureCount,1)];
                
                Q = [Q zeros(size(f,1),trajectoryCount);zeros(trajectoryCount,size(f,1)) zeros(trajectoryCount)];                
                f = [f;zeros(trajectoryCount,1)];

                lb= [lb;-ones(trajectoryCount,1)];
                ub= [ub;ones(trajectoryCount,1)];
                               
                
                %options = optimset('Algorithm','active-set');
                %values = linprog(f,A,b,Aeq,beq,lb,ub,x0,options);
                %weights = transpose(values(1:featureCount));
                
                model.obj = f;
                model.Q = sparse(Q);
                model.A = sparse(A);
                model.rhs = b;
                model.sense = [repmat('=', size(A,1), 1)];
                model.lb = lb;
                model.ub = ub;
                
                params.outputflag = 0;
                result = Optimizer.Gurobi.gurobi(model, params);
                if strcmp(result.status, 'INF_OR_UNBD')
                    params.dualreductions = 0;
                    result = Optimizer.Gurobi.gurobi(model, params);
                end
                if strcmp(result.status, 'NUMERIC')
                    params.NumericFocus = 3;
                    params.BarQCPConvTol = 1e-5;
                    result = Optimizer.Gurobi.gurobi(model, params);                
                end
                if isfield(result, 'x')
                    weights = transpose(result.x(1:featureCount));
                else
                    weights = [];
                    model
                    params
                    disp(strcat('Optimizer did not terminate reason: ',result.status));
                end
            end
        end
        
    end
    
end

