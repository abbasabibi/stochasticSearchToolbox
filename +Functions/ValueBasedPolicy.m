classdef ValueBasedPolicy < Functions.Mapping & Functions.Function
    
    properties
        nextVfunction
        rewardfunction
        
        safeatureExtractor
        minact
        maxact
    end
    
    properties (SetObservable, AbortSet)
        initSigma = 0.1;    
        invTemperature =3; % higher is more greedy
        resetProbTimeSteps
        nactions = 25;
    end
    
    methods
        function obj = ValueBasedPolicy(dataManager, rewardfunction, safeatureExtractor, inputVar)

            obj@Functions.Function();
            if(~exist('inputVar', 'var'))
                inputVar = 'states';
            end
            
            rewardinputlabels = rewardfunction.getInputArguments('rewardFunction');
            if(~iscell(rewardinputlabels{1}))
                rewardinputlabels = {rewardinputlabels}; % make sure it is cell array of cell arrays
            end
            isactioninput = cellfun(@(x) strcmp(x{1},'actions') ,rewardinputlabels);
            rewardinputs_noactions = rewardinputlabels(~isactioninput);
            
            obj@Functions.Mapping(dataManager,'actions',{rewardinputs_noactions{:},{inputVar}});

            obj.nextVfunction = Functions.FunctionLinearInFeatures(dataManager, 1, {inputVar, 'actions'}, 'valueFunction', '',false);
            %obj.nextVfunction = Functions.FunctionLinearInFeatures();
            obj.rewardfunction = rewardfunction;
            obj.safeatureExtractor = safeatureExtractor;
            
            obj.registerMappingInterfaceFunction();
            obj.addDataFunctionAlias('sampleAction', 'getExpectation');
            obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);           
            obj.linkProperty('invTemperature');           
            obj.linkProperty('nactions');     
            obj.maxact = dataManager.getMaxRange('actions');
            obj.minact = dataManager.getMinRange('actions');
            
            obj.linkProperty('resetProbTimeSteps');
        end
        
        function setInputVariables(obj,varargin)
            %if(~strcmp(inputVars , 'states'))
            %    assert(false, 'only works on dynamical systems')
            %end
            setInputVariables@Functions.Mapping(obj,varargin{:})
        end
        
        function actions = getPossibleActions(obj)
            %actions = linspace(obj.minact, obj.maxact, obj.nactions);
            
            args = [obj.nactions; obj.maxact; obj.minact ]; 
            cellargs = mat2cell(args, 3, ones(numel(obj.nactions),1) );
            possiblevalues = cellfun(@(x) linspace(x(2), x(3), x(1)), cellargs,'UniformOutput',false);
            [grids{1:numel(cellargs)}]=ndgrid(possiblevalues{:});
            if(numel(cellargs)>1)
                actions = cell2mat(cellfun(@(x) reshape(x,[numel(x), ones(1,numel(cellargs)-1) ] ) ,grids,'UniformOutput',false)); 
            else
                actions = grids{1};
            end
            
        end
        
        function [actions] =  getExpectation(obj, numElements, rewardfcinput, states)

            actions = obj.getPossibleActions;
            if(~isempty(obj.nextVfunction.featureGenerator))

                %data = trial.dataManager.getDataObject();
                %data.reserveStorage([1 numel(ax)]);
                %data.setDataEntry('states', states(sidx(:),:));
                %data.setDataEntry('actions', a(:));
                %vprime = trial.actionPolicy.callDataFunctionOutput('getExpectation', data);
                
                %all at once - faster but takes more memory
                [aidx, sidx] = meshgrid(1:size(actions,1), 1:size(states,1));
                safeatures = obj.safeatureExtractor.getFeatures(:,[states(sidx(:),:), actions(aidx(:),:)] );
                vprime = obj.nextVfunction.getExpectationGenerateFeatures(size(safeatures,1),safeatures);              
                r = obj.rewardfunction.rewardFunction(rewardfcinput(sidx(:),:), actions(aidx(:),:));
                q = reshape(r + vprime, size(states,1), size(actions,1));
                qnorm = bsxfun(@rdivide, q, std(q,1,2));
                qnorm = bsxfun(@minus, qnorm, max(qnorm,[],2)); % just for numerics
                inverse_temp =obj.invTemperature;% IMPORTANT PARAMETER!
                desirability = exp(inverse_temp*qnorm) ;
                probs = bsxfun(@rdivide, desirability, sum(desirability,2));
                [rows,cols] = find(mnrnd(1,probs));
                [rowssort, rowsidx] = sort(rows);
                a_idx = cols(rowsidx);
                actions = actions(a_idx,:);
                
                %one by one

%                 actions = zeros(size(states,1),1);
%                 for si = 1:size(states,1)
%                     repstates= repmat(states(si,:), numel(obj.actions),1);
%                     reprawstates= repmat(rawstates(si,:), numel(obj.actions),1);
%                     safeatures = obj.safeatureExtractor.getFeatures(:,[repstates, obj.actions(:)] );
%                     vprime = obj.nextVfunction.getExpectationGenerateFeatures(size(safeatures,1),safeatures);              
%                     r = obj.rewardfunction.rewardFunction(reprawstates, obj.actions(:));
%                     q = r + vprime;
%                     %q = r;
%                     qnorm = q/std(q);
%                     qnorm = qnorm - max(qnorm); % just for numerics
%                     inverse_temp =obj.invTemperature;% IMPORTANT PARAMETER!
%                     desirability = exp(inverse_temp*qnorm) ;
%                     probs = desirability / sum(desirability);
%                     actions(si) = obj.actions(logical(mnrnd(1,probs)))';  

%                     
% 
% %                     
%                  end
%                range = obj.dataManager.getRange('actions');
            
%                sigma = diag(range .* obj.initSigma);
%                actions = randn(size(states,1),1) * sigma;
            else
                
                range = obj.dataManager.getRange('actions');
                dimActions = size(range,2);
                sigma = diag(range .* obj.initSigma);
                actions = randn(size(states,1),dimActions) * sigma;
                
            end

            
        end
        

    end
    
end