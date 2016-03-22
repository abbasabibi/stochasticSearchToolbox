classdef NPALinearProgramming < Learner.Learner
    %NPALINEARPROGRAMMING Value function learning by non-parametric
    %   approximate linear programming
    %   Implementation of methond by "non-parametric approximate linear
    %   programming" by J. Pazis and R. Parr (AAAI 2011)
    
    properties
        nextVfunction
        policy
    end
    
    properties(SetObservable,AbortSet)
        resetProb
        lipschitzConstant=1
        featureScale
        
       %for optimization
       usetomlab = false;
    end
    
    
    methods
        function obj=NPALinearProgramming(dataManager,policy)
            obj = obj@Learner.Learner();
            obj.linkProperty('resetProb');
            obj.linkProperty('lipschitzConstant');
            obj.linkProperty('featureScale');
            obj.linkProperty('usetomlab');
            obj.policy=policy;
        end
        
        function d= calc_distances(obj, a, b)
            %for now, scaled euclidean distances
            if(~isempty(obj.featureScale))
                Q = diag(obj.featureScale);
            else
                Q = eye(size(a,2)); %allows changing of the metric
            end
            
            sqdist = sum(((a-b)*Q).^2,2);
            d = sqrt(sqdist);
        end
        function updateModel(obj, data)
            % updates value function (obj.nextVfunction)
            
            %get necessary data
            states = data.getDataEntry('states');
            actions = data.getDataEntry('actions');
            %nextStates = data.getDataEntry('nextStates');
            reward = data.getDataEntry('rewards');
            
            nepisodes = data.getDataStructure.numElements;
            %nepisodes = 30;
             %get necessary data
            %states = data.getDataEntry('states', 1:nepisodes);
            %actions = data.getDataEntry('actions', 1:nepisodes);
            %nextStates = data.getDataEntry('nextStates');
            %reward = data.getDataEntry('rewards', 1:nepisodes);
            
            nsamples = size(states,1) + nepisodes;
            %nsampleswithsuccessor = size(states,1);
            samples = zeros(nsamples, size(states,2));
            lastsamples = zeros(nsamples, 1);
            n = 1;
            for i = 1:nepisodes
                samplesi = [data.getDataEntry('states',i,1); data.getDataEntry('nextStates',i)];
                lastsamplesi = [zeros(size(samplesi,1)-1,1);1];
                samples(n:n+size(samplesi)-1,:) = samplesi;
                lastsamples(n:n+size(samplesi)-1,:) = lastsamplesi;
                n = n + size(samplesi);
            end
            % set up constraint matrices Ax=b
            %nconstraints = nsampleswithsuccessor  + nsamples * (nsamples-1);
            %A = sparse(nconstraints, nsamples);
            %b = zeros(nconstraints);
            
            gamm = 1- obj.resetProb;
            Atdconstraint =sparse(1:nsamples, 1:nsamples,-1)  + gamm* [sparse(nsamples,1), sparse(1:(nsamples-1), 1:(nsamples-1),1,nsamples,nsamples-1) ];
            Atdconstraint = Atdconstraint(~logical(lastsamples),:); %leave out 'reset' transitions
            btdconstraint = -reward;
            
            allpairs = nchoosek(1:nsamples,2);
            constraintno = repmat((1:size(allpairs,1))',1,2);
            vals = [ones(size(allpairs,1),1),-ones(size(allpairs,1),1)];
            Asmoothness1 = sparse(constraintno(:),allpairs(:),vals(:));
            Asmoothness2 = sparse(constraintno(:),allpairs(:),-vals(:));
            bsmoothness = obj.lipschitzConstant * obj.calc_distances (samples(allpairs(:,1),:), samples(allpairs(:,2),:));

            A = [Atdconstraint; Asmoothness1; Asmoothness2];
            b = [btdconstraint; bsmoothness; bsmoothness];

            f = ones(nsamples,1);
            % the actual linear program execution
            %options = optimoptions('linprog','TolFun', 1e-3,'Algorithm','active-set');
            %[v, ~, exitval, ~, lambda ] = linprog(f, A,b,[],[],[],[],[],options);
            
            if(obj.usetomlab)
                if(~exist('ProbDef','file'))
                    addpath('~/tomlab');
                    startup;
                end
                Prob = ProbDef;
                Prob.SolverLP = 'cplex';
                [v, ~, exitval, ~, lambda ] = linprog(f, A,b,[],[],[],[],[],[],Prob);
            else
                [v, ~, exitval, ~, lambda ] = linprog(f, A,b);
            end
            
            if(exitval ~= 1)
                error('NPALP:notcoverged','NPALP not converged to a solution!')
            end
            isbasicvar = lambda.ineqlin ~= 0;
            isbasicvar = isbasicvar(1:sum(~lastsamples)); %indexes original states, not samples
            
            % selecting an action in state t:
            % find basic state maximizing v(s) + lipschitz - d(s,t)
            % than take action that was chosen in that state
            
            % so policy needs: 
            % - list of basic states
            % - corresponding list of actions
            % - corresponding list of values
            % - (lipschitz constant, distance measure)
            
            obj.policy.basicstates = states(isbasicvar,:);
            obj.policy.basicactions = actions(isbasicvar,:);
            obj.policy.basicv = v(isbasicvar);
            
            
            
        end
        
    end
    
end

