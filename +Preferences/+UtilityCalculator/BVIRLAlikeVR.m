classdef BVIRLAlikeVR < Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator
    
    properties(SetObservable)
        prefDecay = 1.1;
    end
    
    methods
        function obj =  BVIRLAlikeVR(dataManager,featureName,varargin)
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
            
            if preferenceCount==0 || size(trajs,1)<2
                weights = [];
                disp('Preference count was zero, not calculating');
            else
                %value differences
                A = zeros(preferenceCount,featureCount);
                for id = 1:preferenceCount
                    [i,j] = ind2sub(size(prefs),prefIds(id));
                    %A(id,:) = fe(i,:)/norm(fe(i,:))-fe(j,:)/norm(fe(j,:));
                    A(id,:) = fe(i,:)-fe(j,:);
                    %timportance(id) = obj.prefDecay^-(currentIter-max(iteration(i),iteration(j)));
                    timportance(id) = min(importance(i),importance(j));
                end
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
                
                %add margin variables (Xi+,Xi-) and create eq constraint
                Aeq = [-A eye(preferenceCount) -eye(preferenceCount)];
                beq = zeros(preferenceCount,1);
                
                f = [f;timportance.*-ones(preferenceCount,1);2*timportance.*ones(preferenceCount,1)]; %Xi+;2*Xi-
                
                lb= [lb;zeros(preferenceCount*2,1)];
                ub= [ub;Inf(preferenceCount*2,1)];
                
                %add value regularizer
                feCount = size(fe,1);
                Aeq = [Aeq zeros(preferenceCount, feCount) ;fe zeros(feCount, 2*preferenceCount) eye(feCount)];
                beq = [beq; zeros(feCount,1)];

                Q = zeros(size(f,1));
                Q = [Q zeros(size(f,1),feCount);zeros(feCount,size(f,1)) 10e-4*eye(feCount)];
                
                f = [f;zeros(feCount,1)];

                lb= [lb;-Inf(feCount,1)];
                ub= [ub;Inf(feCount,1)];
                
                %add trajectory weights alpha
                Aeq = [Aeq zeros(preferenceCount+feCount,trajectoryCount);
                    -eye(featureCount)  zeros(featureCount,preferenceCount*2+feCount) trajs'];
                beq = [beq;
                    zeros(featureCount,1)];
                
                Q = [Q zeros(size(f,1),trajectoryCount);zeros(trajectoryCount,size(f,1)) zeros(trajectoryCount)];                
                f = [f;zeros(trajectoryCount,1)];
                
                lb= [lb;-ones(trajectoryCount,1)];
                ub= [ub;ones(trajectoryCount,1)];
                
                
                A=[];
                b=[];
                
                x0=[];
                
                %options = optimset('Algorithm','active-set');
                %values = linprog(f,A,b,Aeq,beq,lb,ub,x0,options);
                %weights = transpose(values(1:featureCount));
                
                model.obj = f;
                model.Q = sparse(Q);
                model.A = sparse([A; Aeq]);
                model.rhs = [b; beq];
                model.sense = [repmat('<', size(A,1), 1); repmat('=', size(Aeq,1), 1)];
                model.lb = lb;
                model.ub = ub;
                
                params.outputflag = 0;
                result = Optimizer.Gurobi.gurobi(model, params);
                if strcmp(result.status, 'INF_OR_UNBD')
                    params.dualreductions = 0;
                    result = Optimizer.Gurobi.gurobi(model, params);
                end
                if isfield(result, 'x')
                    weights = transpose(result.x(1:featureCount));
                else
                    weights = [];
                    disp(strcat('Optimizer did not terminate reason: ',result.status));
                end
            end
        end
        
    end
    
end

