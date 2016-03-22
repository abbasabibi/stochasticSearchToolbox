classdef AIRLAlike < Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator
    
    methods
        function obj =  AIRLAlike(dataManager,featureName,varargin)
            obj = obj@Preferences.UtilityCalculator.AbstractUtilityFunctionCalculator(dataManager,featureName,varargin{:});
        end
        
        function [weights] = calculateUtilityFunction(obj,c,trajs,fe,prefs)
            prefIds = find(prefs==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            
            preferenceCount = size(prefIds,1);
            trajectoryCount = size(trajs,1);
            featureCount = size(fe,2);
            
            if preferenceCount==0 || trajs<2
                weights = [];
                disp('Preference count was zero, not calculating');
            else
                %value differences
                A = zeros(preferenceCount,featureCount);
                for id = 1:preferenceCount
                    [i,j] = ind2sub(size(prefs),prefIds(id));
                    A(id,:) = fe(i,:)-fe(j,:);
                end
                A = unique(A,'rows');
                fprintf('Removed %d non unique preferences\n', preferenceCount-size(A,1));
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
                
                f = [f;-ones(preferenceCount,1);1*ones(preferenceCount,1)]; %Xi+;1*Xi-
                
                lb= [lb;zeros(preferenceCount*2,1)];
                ub= [ub;Inf(preferenceCount*2,1)];
                
                %add trajectory weights alpha
                %Aeq = [Aeq zeros(preferenceCount,trajectoryCount); 
                %    -eye(featureCount)  zeros(featureCount,preferenceCount*2) trajs'];
                %beq = [beq;
                %    zeros(featureCount,1)];
                
                %f = [f;zeros(trajectoryCount,1)];
                
                %lb= [lb;-ones(trajectoryCount,1)];
                %ub= [ub;ones(trajectoryCount,1)];
                Qc = zeros(size(Aeq,2));
                Qc(1:featureCount,1:featureCount) = eye(featureCount);
                Qc = sparse(Qc);
                Qq = zeros(size(Aeq,2),1);
                bQ = 1;
                
                
                A=[];
                b=[];
                
                x0=[];
                
                %options = optimset('Algorithm','active-set');
                %values = linprog(f,A,b,Aeq,beq,lb,ub,x0,options);
                %weights = transpose(values(1:featureCount));

                 model.obj = f;
                 model.A = sparse([A; Aeq]);
                 model.rhs = [b; beq];
                 model.sense = [repmat('<', size(A,1), 1); repmat('=', size(Aeq,1), 1)];
                 model.lb = lb;
                 model.ub = ub;
                 
                 model.quadcon.Qc = Qc;
                 model.quadcon.q = Qq;
                 model.quadcon.rhs = bQ;
                 
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

