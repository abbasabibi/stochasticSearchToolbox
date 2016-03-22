classdef EMHiREPSContinuous < Learner.ExpectationMaximization.ExpectationMaximization 
    %ESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties (SetObservable,AbortSet)
        numOptions
        numEpisodes
        numTimeSteps
        debugPlottingEM = false;
        
        generatingModel = [];
        currentModel    = [];
        
        useKMeans       = true;
        initMMLearner   = [];
        priorTerminate  = 0.5;
        
        outRespName     = 'outputResponsibilitiesEM';
        respName        = 'responsibilitiesEM';
        
        storedEMData    = [];
    end
    
    properties
        
    end
    
    methods
        
        
        function obj = EMHiREPSContinuous (dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.ExpectationMaximization.ExpectationMaximization(dataManager, mixtureModel, mixtureModelLearner, varargin{:});
            
            
%             outputVar   = obj.mixtureModel.getOutputVariable();
%             subManager  = dataManager.getDataManagerForEntry(outputVar);
            obj.linkProperty('numOptions');
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('debugPlottingEM');
            obj.linkProperty('useKMeans');
            obj.linkProperty('priorTerminate');
            
            obj.linkProperty('respName', 'respNameEM');
            
            obj.outRespName = ['output',upper(obj.respName(1)), obj.respName(2:end)];
            
            obj.initMMLearner       = Learner.SupervisedLearner.InitMMLearner(dataManager, mixtureModelLearner);
            
            
%             obj.addDataManipulationFunction('computeResponsibilitiesEM', {mixtureModel.outputVariable, mixtureModel.inputVariables{:},  mixtureModel.gating.inputVariables{:}, mixtureModel.terminationMM.inputVariables{:} }, {mixtureModel.respName});
            
            depth = dataManager.getDataEntryDepth(mixtureModel.outputVariable);
            subManager = dataManager.getDataManagerForDepth(depth);
%             subManager.addDataEntry(obj.respName, obj.numOptions^2 * 2);
            subManager.addDataEntry(obj.respName, obj.numOptions);
            
            depth       = dataManager.getDataEntryDepth(mixtureModelLearner.outputVariable);
            subManager  = dataManager.getDataManagerForDepth(depth);
%             subManager.addDataEntry(obj.outRespName, mixtureModelLearner.functionApproximator.numOptions^2*2);
            subManager.addDataEntry(obj.outRespName, mixtureModelLearner.functionApproximator.numOptions);
            

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% INIT
        function [EMData] = init(obj, data, EMData)
            
            obj.isInit = true;
            EMData.outputDataGating = zeros(size(EMData.inputData,1),obj.numOptions);
            EMData.weightsGating    = zeros(size(EMData.inputData,1),1);
            EMData.outputDataTermination =zeros(size(EMData.inputData,1),obj.numOptions);
            EMData.weightsTermination =zeros(size(EMData.inputData,1),obj.numOptions);
            if(obj.debugPlottingEM)
                    obj.plotting(data, EMData);
                    pause(0.1);
            end
                
            if(obj.useKMeans)
%                 error('should not go here, use kMeansLearner instead');
                
                
%                 EMData = obj.kMeans(data, EMData);
%                 obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, [], EMData.outputData,  [], EMData.outputDataGating);
                
%                 data.setDataEntry('optionsOld', ones(size(EMData.inputData,1),obj.numOptions));
                obj.initMMLearner.updateModel(data);
                
                EMData.outputDataGating     = data.getDataEntry(obj.mixtureModelLearner.respName);
                EMData.outputDataTermination = abs(1-EMData.outputDataGating);
                EMData.weightsPolicy        = EMData.outputDataGating;
                EMData.weightsGating        = ones(size(EMData.outputDataGating,1),1);
                EMData.weightsTermination   = ones(size(EMData.outputDataTermination));
                
                return; %Bug here need to investigate
                
                
                if(obj.debugPlottingEM)
                    obj.plotting(data, EMData);
                    pause(0.1);
                end
                
                EMData.inputDataTermination     = [];
                EMData.outputDataTermination    = [];
                EMData.weightsTermination       = [];
                obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.inputDataTermination,...
                    EMData.outputData, [], EMData.outputDataGating, EMData.outputDataTermination, ...
                    EMData.weightsPolicy, EMData.weightsGating, EMData.weightsTermination, EMData.weighting);
                
                for e = 1 : obj.numEpisodes
                    pAso = obj.mixtureModel.getDataProbabilitiesAllOptions( ...
                        data.getDataEntry(obj.mixtureModel.inputVariables{1}, e, :), data.getDataEntry(obj.mixtureModel.outputVariable, e, :) );
                    pAso = exp(pAso);
                    
                    [~, optionsIdx] = max(pAso,[],2);
                    switches    = diff(optionsIdx);
%                     switchesIdx = find(switches~=0);
                    tmpInput    = data.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1},e,:);
                    tmpOutput   = zeros(size(pAso));
                    tmpWeights  = zeros(size(pAso));
                    
                    for o = 1 : obj.numOptions
                        idx = find([0;switches]~=0 & [0;optionsIdx(1:end-1)] == o);
                        tmpOutput(idx, o) = 1;
                        tmpWeights(idx, o) = 1;
                    end
                    
                    EMData.inputDataTermination = [EMData.inputDataTermination; tmpInput];
                    EMData.outputDataTermination = [EMData.outputDataTermination; tmpOutput];
                    EMData.weightsTermination   = [EMData.weightsTermination; tmpWeights];
                end
                
                if(obj.debugPlottingEM)
                    obj.plotting(data, EMData);
                    pause(0.1);
                end
                
                obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.inputDataTermination,...
                    EMData.outputData,[],  EMData.outputDataGating, EMData.outputDataTermination, ...
                    EMData.weightsPolicy, EMData.weightsGating, EMData.weightsTermination, EMData.weighting);
                
                
                if(obj.debugPlottingEM)
                    obj.plotting(data, EMData);
                    pause(0.1);
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Update localSettings
        function [EMData] = initEMData(obj, data)
            obj.numEpisodes = data.dataStructure.numElements;
            EMData.inputData = data.getDataEntry(obj.mixtureModel.inputVariables{1});
            EMData.outputData = data.getDataEntry(obj.mixtureModel.outputVariable);
            EMData.inputDataTermination = data.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1});
            
            
            EMData.inputDataGating = [];
            if( ~isempty(obj.mixtureModel.gating.inputVariables) )
                EMData.inputDataGating = data.getDataEntry(obj.mixtureModel.gating.inputVariables{1});
            end
            
            if (~isempty(obj.weightName))
                 %                 EMData.weighting = data.getDataEntry(obj.mixtureModel.outputVariable);
                 EMData.weighting = data.getDataEntry(obj.weightName{1});
             else
                 EMData.weighting = ones(size(EMData.inputData,1),1);
             end
             
             if(isfield(data.dataEntries,'etaXi'))
                 EMData.etaXi = data.getDataEntry('etaXi');
             else
                 EMData.etaXi = ones(size(EMData.inputData,1),1);
             end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% E-STEP
        function [ EMData] = EStep( obj, data, EMData)
            [EMData] = obj.getForwardMessages(data, EMData); %alpha_t = p(s_1:t,a_1:t,o_t)    dim alpha = numEpisodes x dimOptions x numTimeSteps
            %pSAsa =  %p(s_t,a_t|s_1:t,a_1:t)
            EMData = obj.getBackwardMessages(EMData);
            
            for b = 1 : 2
                tmp = squeeze(EMData.alpha(:,:,b,:) );
                if(obj.numEpisodes == 1)
                    EMData.gamma(1,:,b,:) = tmp .* squeeze(EMData.beta(1,:,:));
                else
                    EMData.gamma(:,:,b,:) = tmp .* EMData.beta(:,:,:);
                end
            end
            
            
            EMData.xi  = zeros(obj.numEpisodes, obj.numOptions, obj.numOptions, 2,  obj.numTimeSteps-1); %p(o,o|s_1:T,a_1:T)
            for t = 1 : obj.numTimeSteps  -1
                for o = 1 : obj.numOptions    %o_t=o
                    for k = 1 : obj.numOptions  %o_t+1=k
                        for b = 1 : 2         %b_t = b We directly marginalize out b_t since we don't need it
                            for p = 1 : 2       %b_t+1 = p
                                EMData.xi(:,o,k,p,t) = EMData.xi(:,o,k,p,t) + 1./EMData.pSAsa(:,t+1) .* EMData.alpha(:,o,b,t) .* EMData.pSAOBo(:,o,k,p,t+1)  .* EMData.beta(:,k,t+1);  % = alpha * pSAo * pOso * beta
                            end
                        end
                    end
                end
            end
            
            EMData = obj.getModelWeights(data, EMData);
            
            if(obj.debugPlottingEM)
                obj.plotting(data, EMData);
                pause(0.1);
            end
            
        end
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% FORWARD MESSAGE
        function [EMData] = getForwardMessages(obj, data, EMData)
            % global numOptions numTimeSteps numEpisodes
            %n=s
            % alpha         = [e,o,b,t]     zeros(numEpisodes, numOptions, 2, numTimeSteps);
            % pSAsa         = [e,t]         ones(numEpisodes, numTimeSteps);
            % pSOBo         = [e,o,o',b]    zeros(numEpisodes, numOptions, numOptions, 2);
            % pAso          = [e,o]         zeros(numEpisodes, numOptions);
            % pSAOBo        = [e,o,o',b,t]  zeros(numEpisodes, numOptions, numOptions, 2, numTimeSteps);
            % pSAOOB        = [e,o,o',b,t]  zeros(numEpisodes, numOptions, numOptions, 2,  numTimeSteps);
            % pSAOB         = [e,o,b]       zeros(numEpisodes, numOptions, 2);
            % pSOB          = [e,o,b]       zeros(numEpisodes, numOptions, 2);
            pBso          = zeros(obj.numEpisodes, obj.numOptions, obj.numTimeSteps);   %[e, o_t-1, t]
            pNotBso       = zeros(obj.numEpisodes, obj.numOptions, obj.numTimeSteps);   %[e, o_t-1, t]
            EMData.pSAsa = [];
            EMData.alpha = [];
            EMData.pOs   = [];
            EMData.pSAOBo = [];
            
            for t = 1 : obj.numTimeSteps
                
                %Termination Probability
                for s = 1 : obj.numEpisodes
                    if(t==1)
                        pBso(s,:,t) = 1;
                    else
                        %                         pBs(s,:,t) = sigmoid(EMData.optionTerm * [1, traj.states(s,:,t)]'); %p(b=1|s_t,o_t-1)
                        pBso(s,:,t) = obj.mixtureModel.terminationMM.getDataProbabilitiesAllOptions(data.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1}, s, t) ); %for all o
                        pBso(s,:,t) = exp(pBso(s,:,t));
                        
                        pNotBso(s,:,t)  = (1-pBso(s,:,t)) * (1-obj.priorTerminate);
                        pBso(s,:,t)     = pBso(s,:,t) * obj.priorTerminate;
                        
                        normalizerTermination = pNotBso(s,:,t) + pBso(s,:,t);
                        
                        idxNotZero              = pNotBso(s,:,t) ~=0;
                        pNotBso(s,idxNotZero,t) = bsxfun(@rdivide, pNotBso(s,idxNotZero,t), normalizerTermination(idxNotZero));
                        
                        idxNotZero              = pBso(s,:,t) ~=0;
                        pBso(s,idxNotZero,t)    = bsxfun(@rdivide, pBso(s,idxNotZero,t), normalizerTermination(idxNotZero));
                    end
                end
                
                
                %pOs =      [s,o]
                %                 EMData.pOs = multReg(obj.localSettings, EMData, traj.states(:,:,t) );
                EMData.pOs = obj.mixtureModel.gating.getItemProbabilities([],data.getDataEntry(obj.mixtureModel.gating.inputVariables{1}, :, t) );
                %                 EMData.pOs = exp(EMData.pOs);

                
                %pSOBo =    [s,o_t-1,o_t,b]
                pSOBo(:,:,:,1) = bsxfun(@times, permute(EMData.pOs, [1 3 2]), pBso(:,:,t) );
                for s = 1 : obj.numEpisodes
%                     pSOBo(s,:,:,2) = diag(1 - pBso(s,:,t));
                    pSOBo(s,:,:,2) = diag(pNotBso(s,:,t));
                end
                
                %                 for k = 1 : obj.numOptions
                %                     pAso(:,k)   = mvnpdf(traj.actions(:,:,t), ...
                %                         bsxfun(@plus, EMData.actionMean(k,:), (EMData.actionLinear(:,:,k) * traj.states(:,:,t)')'), ...
                %                         EMData.actionVar(:,:,k) );  %TODO
                %                     pAso(:,k) = obj.mixtureModel.callDataFunctionOutput('getItemProbabilities',data(:,:,t));
                %                 end
                pAso = obj.mixtureModel.getDataProbabilitiesAllOptions( ...
                    data.getDataEntry(obj.mixtureModel.inputVariables{1}, :, t), data.getDataEntry(obj.mixtureModel.outputVariable, :, t) );
                pAso = exp(pAso); %+1e-9; 
                
                %pSAOBo =   [s,o_t-1,o_t,b,t]
                tmp = bsxfun(@times, permute(pSOBo, [1, 3, 2, 4]), pAso);
                EMData.pSAOBo(:,:,:,:,t) = permute(tmp, [1, 3, 2, 4]);
                
                if(t==1)
                    pSAOOB(:,:,:,:,t) = EMData.pSAOBo(:,:,:,:,t);
                else
                    pSOBoBar = sum(EMData.alpha(:,:,:,t-1),3); %sum_b_t-1 [e,o_t-1]
                    pSAOOB(:,:,:,:,t) = bsxfun(@times, EMData.pSAOBo(:,:,:,:,t), pSOBoBar);
                end
                
                %faster than squeeze
                tmp1 = sum(pSAOOB(:,:,:,:,t),2); %sum o_t-1
                tmp2 = permute(tmp1, [1, 3, 4, 2, 5]);
                %pSAOB =    [s,o,b]
                pSAOB = tmp2(:,:,:,1,1);
                
                
                EMData.pSAsa(:,t)      = sum(sum(pSAOB,2),3); %c_t
                EMData.pSAsa(:,t)      = max(EMData.pSAsa(:,t), 1e-10 *max(EMData.pSAsa(:)));
                
                EMData.alpha(:,:,:,t)  = bsxfun(@rdivide, pSAOB, EMData.pSAsa(:,t) ); %alphaHat
                
                
                assert(~any(EMData.pSAsa(:)==0));
                
            end
            
        end %getForwardMessages
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% BACKWARD MESSAGE
        function EMData = getBackwardMessages(obj, EMData)
            % global numOptions numTimeSteps numEpisodes
            EMData.beta = zeros(obj.numEpisodes, obj.numOptions, obj.numTimeSteps);
            
            EMData.beta(:,:,obj.numTimeSteps) = 1;
            pSAOo = sum(EMData.pSAOBo,4); %sum_b
            pSAOo = permute(pSAOo, [1 2 3 5 4]);
            pSAOo = pSAOo(:,:,:,:,1); %[s o k t]
            
            for t = obj.numTimeSteps  : -1 : 2
                tmp = bsxfun(@times, pSAOo(:,:,:,t), permute(EMData.beta(:,:,t), [1 3 2]) );
                EMData.beta(:,:,t-1) = sum(tmp,3); %sum_k=o_t
                
                EMData.beta(:,:,t-1) = bsxfun(@rdivide, EMData.beta(:,:,t-1), EMData.pSAsa(:,t) ); %betaHat
            end
            
        end %getBackwardMessages
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% getModelWeights
        % Extracts and reorders information from the EStep to be used as weights
        % for updates of the termination, gating and policy models.
        function EMData = getModelWeights(obj, data, EMData)
            
            xiAll = zeros(obj.numEpisodes * (obj.numTimeSteps-1),obj.numOptions, obj.numOptions,2); % [sample, o_t, o_t+1, b_t+1]
            for s = 1 : obj.numEpisodes
                idxS = (s-1) * (obj.numTimeSteps-1);
                for t = 1 : obj.numTimeSteps -1
                    idx = idxS + t;
                    xiAll(idx, :, :,:) = EMData.xi(s, :, : ,:,t);
                end
            end
            
            %             xiAll = permute(EMData.xi(1,:,:,:,:), [5 2 3 4 1]);
            %             xiAll = xiAll(:,:,:,:,1);
            
            gammaAll = zeros(obj.numEpisodes * (obj.numTimeSteps), obj.numOptions,2); % [sample, o_t, b_t]
            for s = 1 : obj.numEpisodes
                idxS = (s-1) * obj.numTimeSteps;
                for t = 1 : obj.numTimeSteps
                    idx = idxS + t;
                    gammaAll(idx, :, :) = EMData.gamma(s, : ,:,t);
                end
            end
            
            
            termStateIdx    = [0;ones(obj.numTimeSteps-1,1)];
            termStateIdx    = logical(repmat(termStateIdx, obj.numEpisodes,1));            
            EMData.termStateIdx = termStateIdx;
            
%             gammaAllWeighted    = bsxfun(@power, gammaAll, EMData.etaXi);
%             xiAllWeighted       = bsxfun(@power, xiAll, EMData.etaXi(termStateIdx));
            
            
            %Termination. xiAll = [sample, o_t, o_t+1, b_t+1]
            xiBar = squeeze(sum(xiAll,3));                   % [sample, o_t, b_t+1], xiBar = p(o_t, b_t+1 | s_1:T)
            EMData.weightsTermination = squeeze(sum(xiBar,3));      % [sample, o_t] p(o_t | s_1:T)
            
            
            statesAll                       = data.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1});
            termStates                      = statesAll(EMData.termStateIdx,:);            
            EMData.inputDataTermination     = termStates;
            EMData.outputDataTermination    = [];
            
            for o = 1: obj.numOptions
                normalizer  = squeeze(sum(xiBar(:,o,:),3)); % [sample, o_t]
                normalizer  = max(normalizer, realmin);               % ATTENTION but weights should be zero in that case
                EMData.outputDataTermination(:,o)   = squeeze(xiBar(:,o,1)) ./normalizer;
            end
            
            
            %Gating, gammaAll = [sample, o_t, b_t]
            EMData.weightsGating = squeeze(sum(gammaAll(:,:,1),2));
            EMData.outputDataGating = bsxfun(@rdivide, gammaAll(:,:,1), EMData.weightsGating);
            idxZero = EMData.weightsGating < 1e-8;
            EMData.outputDataGating(idxZero,:) = 0;
            %             EMData.outputDataGating(EMData.weightsGating==0,:) = 0; % Not completely sure this is appropriate but it shouldnt matter with w=0.
            
            
            %Policy
            EMData.weightsPolicy = squeeze(sum(gammaAll,3));
            EMData.weightsPolicy = bsxfun(@rdivide, EMData.weightsPolicy, sum(EMData.weightsPolicy));
            
            
            EMData.gammaAll     = gammaAll;
            EMData.xiAll        = xiAll;
            
            %EMData.respAll = p(o,oBar,b|s,a) : [s, o_t, o_t+1, b_t+1]
            EMData.respAll      = zeros(obj.numEpisodes * obj.numTimeSteps, obj.numOptions, obj.numOptions, 2); 
            EMData.respAll(termStateIdx,:,:,:)  = xiAll;
            EMData.respAll(~termStateIdx,1,:,:) = gammaAll(~termStateIdx,:,:);
            
            EMData.pOBarOsa      = squeeze(sum(EMData.respAll,4));          %[s, oBar, o]
%             EMData.pOBarsa      = squeeze(sum(sum(EMData.respAll,3),4));
            
            EMData.pOsa         = squeeze(sum(sum(EMData.respAll,2),4)); %sum_{o_bar and b} = p(o|s,a)
            
            
%             EMData.respAll      = squeeze(sum(sum(EMData.respAll,2),4)); %sum_{o_bar and b} = p(o|s,a)
            
            names = fieldnames(EMData);
            for i = 1 : length(names)
                tmp = isnan(EMData.(names{i}));
                assert(~any(tmp(:)));
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% M-STEP
        function [] = MStep(obj, data, EMData, varargin)
            
            
            
%             obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.inputDataTermination,...
%                 EMData.outputData, [],  EMData.outputDataGating, EMData.outputDataTermination, ...
%                 EMData.weightsPolicy, EMData.weightsGating, EMData.weightsTermination, EMData.weighting, varargin{:});
            
%             %% TESTING
            weights = EMData.weighting;            
            respPow = bsxfun(@power, EMData.pOsa, EMData.XiEta); % = p(o|s,a)^(eta/xi)

%             outputDataTermination = bsxfun(@times, EMData.outputDataTermination, weights(EMData.termStateIdx));
            outputDataTermination   = EMData.outputDataTermination;
            
            
            weightsTermination      = EMData.pOBarOsa(EMData.termStateIdx,:,:);
            weightsTermination      = bsxfun(@times, weightsTermination, permute(respPow(EMData.termStateIdx,:), [1 3 2] ));
            weightsTermination      = sum(weightsTermination,3);
%             weightsTermination      = bsxfun(@times, weightsTermination, weights(EMData.termStateIdx,:));
%             weightsTermination      = bsxfun(@rdivide, weightsTermination, sum(weightsTermination));
            
            
%             outputDataGating    = bsxfun(@times, EMData.outputDataGating, weights);
            outputDataGating        = bsxfun(@times, EMData.outputDataGating, respPow);
            outputDataGating        = bsxfun(@rdivide, outputDataGating, sum(outputDataGating,2));
            
            weightsGating           = bsxfun(@times, EMData.weightsGating, weights);
            weightsGating           = bsxfun(@rdivide, weightsGating, sum(weightsGating));
            
            weightsPolicy           = bsxfun(@times, EMData.weightsPolicy, weights);
            weightsPolicy           = bsxfun(@rdivide, weightsPolicy, sum(weightsPolicy));
            
            %             outputDataGating    = outResps;
            
            
            obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.inputDataTermination,...
                EMData.outputData, [],  outputDataGating, outputDataTermination, ...
                weightsPolicy, weightsGating, weightsTermination, [], varargin{:});
            
%             
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %% Update Model
         function [] = updateModel(obj, data)
             
             EMData = obj.initEMData(data);
             if(~obj.isInit || obj.reinitialize)
                 EMData = obj.init(data, EMData);
                 obj.iterEM              = 1;
                 obj.logLikeDifference   = inf;
             end
             
             if(~isempty(obj.storedEMData))
                 EMData = obj.storedEMData;
                 obj.iterEM              = 1;
                 obj.logLikeDifference   = inf;
             else
                 EMData = obj.EStep(data, EMData);
             end
             
             if(~isempty(EMData))
                 if (~isempty(obj.weightName)   )
                     %                 EMData.weighting = data.getDataEntry(obj.mixtureModel.outputVariable);
                     EMData.weighting = data.getDataEntry(obj.weightName{1});
                 else
                     EMData.weighting = ones(size(EMData.inputData,1),1);
                 end
                 
                 if(isfield(data.dataEntries,'XiEta'))
                     EMData.XiEta = data.getDataEntry('XiEta',1);
                 else
                     EMData.XiEta = 0;
                 end
                 
             end
             
             
             
             
             while ( obj.iterEM <= obj.numIterations && (obj.logLikeDifference<0 || obj.logLikeDifference > obj.logLikelihoodThreshold) )
                 
                 if(obj.iterEM > 1)
                     EMData = obj.EStep(data, EMData);
                 end
                 
                 obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMData);
                 
                 if(obj.iterEM > 1)
                     obj.logLikeDifference = obj.logLikelihood(obj.iterEM) - obj.logLikelihood(obj.iterEM-1);                     
                 end
                 
                 if(obj.logLikeDifference< -1e-3)
                     warning(['llh diff is negative in EM obj.logLikeDifference=',num2str(obj.logLikeDifference)]);
                 end
                 
                 
                 obj.MStep(data, EMData);
                 
                 obj.storedEMData = [];
                 
                 msg = 'Iteration: ';
                 fprintf('%50s %.3g\n', msg, obj.iterEM);
                 msg = 'Log Likelihood: ';
                 fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                 
                 obj.iterEM = obj.iterEM + 1;
                 
                 
                 %             %% DEBUG
                 %             EMDataLLH = EMData;
                 %
                 %
                 %             obj.MStep(data, EMData, 1);
                 %             EMDataLLH = obj.EStep(data, EMDataLLH);
                 %             obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                 %             msg = 'Log Likelihood After Termination Update: ';
                 %             fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                 %
                 %             obj.MStep(data, EMData, 2);
                 %             EMDataLLH = obj.EStep(data, EMDataLLH);
                 %             obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                 %             msg = 'Log Likelihood After Gating Update: ';
                 %             fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                 %
                 %             obj.MStep(data, EMData, 3);
                 %             EMDataLLH = obj.EStep(data, EMDataLLH);
                 %             obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                 %             msg = 'Log Likelihood After Sub-Policy Update: ';
                 %             fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                 
                 
             end
         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% DATA PREPROCESSOR
        function data = preprocessData(obj, data)
            EMData = obj.initEMData(data);
            EMData = obj.EStep(data, EMData);
            
            obj.storedEMData = EMData;
            
%             responsibilities = EMData.respAll;
%             tmp = reshape(EMData.respAll, size(EMData.respAll,1), []);

            data.setDataEntry(obj.respName, EMData.pOsa);
        end
        
       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% LOG LIKELIHOOD
        function [llh] = getLogLikelihood(obj, EMData)
            llh = sum(sum(log(EMData.pSAsa)))/ obj.numEpisodes;
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOTTING
        function plotting(obj, data, EMData)
            if(~usejava('jvm') || ~usejava('desktop') )
                return
            end
            
            obj.setGeneratingModel(obj.mixtureModel, 'currentModel');
            
            
            optionMarker = {'x','o'};
            optionColor = {'r','k'};
            optionColorVec = {[1 0 0], [0 0 0]};
            numTestStates = 100;
            
            if(data.getNumDimensions('states') == 1)
                idxState2 = 2;
            else
                idxState2 = 3;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(3)
            clf
            hold on
            
            statesTest = zeros(numTestStates, data.getNumDimensions(obj.mixtureModel.inputVariables{1}));
            statesTest(:,1) = linspace(-10,10,numTestStates);
            dataTest = obj.dataManager.getDataObject(100);
            dataTest.setDataEntry('states', statesTest, :,1 );
            
            %             pos = get(gcf,'Position'); %pos is [dist left, dist bottom, width, height]
            %             pos2 = [pos(1), pos(2)-pos(4)-100, pos(3), pos(4)];
            %             figure(2);
            %             set(gcf,'Position', pos2);
            %             clf;
            
            title('Gating on Test Data');
            obj.setActiveModel(obj.generatingModel);
            pOsGenerating = obj.mixtureModel.gating.getItemProbabilities([],dataTest.getDataEntry(obj.mixtureModel.gating.inputVariables{1}, :, 1) ); %for all o
            %             pOsGenerating = exp(pOsGenerating);
            for o = 1 : obj.numOptions
                h(1) = plot(statesTest(:,1),pOsGenerating(:,o),[optionColor{o},'--'], 'LineWidth',3);
            end
            
            obj.setActiveModel(obj.currentModel);
            pOSCurrent = obj.mixtureModel.gating.getItemProbabilities([],dataTest.getDataEntry(obj.mixtureModel.gating.inputVariables{1}, :, 1) ); %for all o
            %             pOSCurrent = exp(pOSCurrent);
            for o = 1 : obj.numOptions
                h(2) = plot(statesTest(:,1),pOSCurrent(:,o),[optionColor{o}], 'LineWidth',3);
            end
            
            for o = 1 : obj.numOptions
                scatter(EMData.inputDataGating(:,2), EMData.outputDataGating(:,o),EMData.weightsGating(:)*300 + 1e-6, optionColorVec{o}, 'LineWidth',3);
            end
            %             end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            figure(4)
            clf
            hold on
            betaTest = [];
            betaHat = [];
            
            statesTest = zeros(numTestStates, data.getNumDimensions(obj.mixtureModel.inputVariables{1}));
            statesTest(:,end) = linspace(-10,10,numTestStates);
            dataTest = obj.dataManager.getDataObject(100);
            dataTest.setDataEntry('states', statesTest, :,1 );
            
            
            obj.setActiveModel(obj.generatingModel);
            betaTest = obj.mixtureModel.terminationMM.getDataProbabilitiesAllOptions(dataTest.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1}, :, 1) ); %for all o
            betaTest = exp(betaTest);
            pBs = obj.mixtureModel.terminationMM.getDataProbabilitiesAllOptions(data.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1}) ); %for all o
            pBs = exp(pBs);
            for o = 1 : obj.numOptions
                %                 betaTest(:,o) = sigmoid(genModel.optionTerm(o,:) * [ones(size(statesTest,1),1), statesTest]');
                h(1) = plot(statesTest(:,end),betaTest(:,o),[optionColor{o},'--'], 'LineWidth',3);
            end
            
            obj.setActiveModel(obj.currentModel);
            betaHat = obj.mixtureModel.terminationMM.getDataProbabilitiesAllOptions(dataTest.getDataEntry(obj.mixtureModel.terminationMM.inputVariables{1}, :, 1) ); %for all o
            betaHat = exp(betaHat);
            for o = 1 : obj.numOptions
                %                 betaHat(:,o) = sigmoid(model.optionTerm(o,:) * [ones(size(statesTest,1),1), statesTest]');
                h(2) = plot(statesTest(:,end),betaHat(:,o),[optionColor{o}], 'LineWidth',3);
            end
            
            title('Estimated Termination probability betaHat ');
            legend(h, 'Beta', 'BetaHat')
            xlabel('State(2)');
            ylabel('pHat(b|s,o)'); %plot also switching traj.states and resp at those traj.states
            
            
            
            statesAll = data.getDataEntry('states');
            optionsAll = data.getDataEntry('optionsOld');
            switchOption = diff(optionsAll);
            switchIdx   = [(switchOption ~= 0);false];
            hold all
            for o = 1 : obj.numOptions
                idx = false(size(optionsAll));
                idx(switchIdx) = (optionsAll(switchIdx) == o);
                plot(statesAll(idx,end), pBs(idx,optionsAll(idx)), [optionColor{o},'*'], 'MarkerSize',20, 'LineWidth',3);
            end
            
%             if(~isempty(EMData.inputDataTermination))
%                 for o = 1 : obj.numOptions
%                     scatter(EMData.inputDataTermination(:,idxState2), EMData.outputDataTermination(:,o),EMData.weightsTermination(:,o)*300 + 1e-6, optionColorVec{o}, 'LineWidth',3);
%                 end
%             end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SELECT BETWEEEN MODEL PARAMS
        function setActiveModel(obj, storageStruct)
            %             numOptions = storageStruct.numOptions();
            
            for o = 1 : storageStruct.numOptions
                obj.mixtureModel.options{o}.setWeightsAndBias(storageStruct.policyWeights(o,:), storageStruct.policyBias(o,:) );
                obj.mixtureModel.terminationMM.terminations{o}.setTheta(storageStruct.terminationTheta(o,:));
            end
            obj.mixtureModel.gating.setThetaAllItems(storageStruct.gatingTheta);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% SETTER FOR MODEL PARAMS
        %
        function setGeneratingModel(obj, mixtureModel, modelID)
            
            numOptionsGen = mixtureModel.numOptions();
            storageStruct.numOptions = numOptionsGen;
            
            for o = 1 : numOptionsGen
                storageStruct.policyBias(o,:) = mixtureModel.options{o}.bias;
                storageStruct.policyWeights(o,:) = mixtureModel.options{o}.weights;
                storageStruct.terminationTheta(o,:) = mixtureModel.terminationMM.terminations{o}.theta;
            end
            storageStruct.gatingTheta = mixtureModel.gating.thetaAllItems;
            
            if(strcmp(modelID, 'generatingModel'))
                obj.generatingModel = storageStruct;
            else
                if(strcmp(modelID, 'currentModel'))
                    obj.currentModel = storageStruct;
                else
                    error();
                end
            end
            
        end
        
    end
    
end
