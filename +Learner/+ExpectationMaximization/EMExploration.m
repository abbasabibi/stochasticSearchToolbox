classdef EMExploration < Learner.ExpectationMaximization.EMHiREPSContinuous
    %ESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties (SetObservable,AbortSet)
        
    end
    
    properties
        
    end
    
    methods
        
        
        function obj = EMExploration (dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.ExpectationMaximization.EMHiREPSContinuous(dataManager, mixtureModel, mixtureModelLearner, varargin{:});
            
            
        end
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% FORWARD MESSAGE
        function [EMData] = getForwardMessages(obj, data, EMData)
            % global numOptions numTimeSteps numEpisodes
            %n=s
            % alpha         = [e,o,b,t]     zeros(numEpisodes, numOptions, 2, numTimeSteps);
            % pSAsa         = [e,t]         ones(numEpisodes, numTimeSteps);
            % pSOBo         = [e,o,o',b]    zeros(numEpisodes, numOptions, numOptions, 2);
            % pAob          = [e,o,b]       zeros(numEpisodes, numOptions, 2);
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
                
                % pAob          = [s,o,b]         zeros(numEpisodes, numOptions,2);
                pAob        = zeros(obj.numEpisodes, obj.numOptions,2);
                pAob(:,:,1) = obj.mixtureModel.getDataProbabilitiesAllOptions( ...
                    data.getDataEntry(obj.mixtureModel.inputVariables{1}, :, t), data.getDataEntry(obj.mixtureModel.outputVariable, :, t) );
                pAob(:,:,1) = exp(pAob(:,:,1));
                pAob(:,:,2) = 1;
                
                
                %pSAOBo =   [s,o_t-1,o_t,b,t] %Maybe actually [s,o_t,o_t-1,b,t]??? No, is ok after second permute
                tmp = bsxfun(@times, permute(pSOBo, [1, 3, 2, 4]), permute(pAob, [1 2 4 3]));
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
        
        
        
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% getModelWeights
        % Extracts and reorders information from the EStep to be used as weights
        % for updates of the termination, gating and policy models.
        function EMData = getModelWeights(obj, data, EMData)
            EMData = obj.getModelWeights@Learner.ExpectationMaximization.EMHiREPSContinuous(data, EMData);
            
            
            EMData.weightsPolicy = squeeze(EMData.gammaAll(:,:,1));
            EMData.weightsPolicy = bsxfun(@rdivide, EMData.weightsPolicy, sum(EMData.weightsPolicy));
            
            names = fieldnames(EMData);
            for i = 1 : length(names)
                tmp = isnan(EMData.(names{i}));
                assert(~any(tmp(:)));
            end
            
        end
        
        
        
    end
    
end
