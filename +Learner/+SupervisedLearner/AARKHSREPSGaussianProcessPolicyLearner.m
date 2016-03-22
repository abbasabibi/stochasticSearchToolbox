classdef AARKHSREPSGaussianProcessPolicyLearner < Learner.Learner
    %GAUSSIANPROCESSPOLICYLEARNER Learner for the GaussianProcessPolicy


    properties(SetObservable,AbortSet)
        policy
        weightName
        dataManager
        minRelWeight = 1e-4
        repslearner
        kernel_r  % predict r
        kernel_V  % embed v
        kernel_sp % to predict sprime
        state_representation
        next_state_representation
    end
    
    methods
        function obj =  AARKHSREPSGaussianProcessPolicyLearner(dataManager, policy, repslearner, modellearner, kernel_r)
            obj = obj@Learner.Learner();
            obj.policy = policy;
            
            obj.dataManager = dataManager;

            obj.repslearner = repslearner;
            obj.state_representation = modellearner.currentInputFeature;
            obj.next_state_representation = modellearner.nextInputFeature;
            
            obj.kernel_r = kernel_r;
            obj.kernel_sp = modellearner.sakernel;
            obj.kernel_V = modellearner.sfeatureExtractor.kernel;
        end
        

        function setWeightName(obj, ~)
            %dummy function, we don't need weights but REPS supposes so...
        end
        
        
        function [] = updateModel(obj, data)
            
            it = numel(obj.policy.actions)+1;
            %currentstates = data.getDataEntry(obj.state_representation);
            
            obj.policy.actions{it} = data.getDataEntry('actionsLinear');
            obj.policy.state_representations{it} = data.getDataEntry(obj.policy.inputVariables{:});
            obj.policy.rewards{it} = data.getDataEntry('rewards');
            obj.policy.hyperparameters_r{it} = obj.kernel_r.subkernel.kernels{1}.getHyperParameters; % = get Hyperparameters;
            obj.policy.hyperparameters_sp{it} = obj.kernel_sp.subkernel.kernels{1}.getHyperParameters; % = get Hyperparameters;
            
            r_input =  data.getDataEntryCellArray(obj.kernel_r.featureVariables);
            obj.policy.inverse_sq_kernels_r{it} = inv(obj.kernel_r.getRegularizedGramMatrix(r_input{1} ));% reg inv square kernel
            
            sp_input =  data.getDataEntryCellArray(obj.kernel_sp.featureVariables);
            obj.policy.inverse_sq_kernels_sp{it} = inv(obj.kernel_sp.getRegularizedGramMatrix(sp_input{1} ));% reg inv square kernel
            
            states = data.getDataEntry(obj.state_representation);
            nextStates = data.getDataEntry(obj.next_state_representation);
            obj.policy.expValWeightEmbedding{it} = obj.repslearner.theta' * obj.kernel_V.getGramMatrix(states, nextStates); % alpha* G
            obj.policy.etas{it} = obj.repslearner.eta;
            
        end        
        
    end
    
end

