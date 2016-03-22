classdef RKHSEmbeddingStrengthLearner < Learner.ModelLearner.RKHSModelLearner
    %RKHSFEATURELEARNER Updates conditional RKHS model and calculates
    %features
    

    
    methods
        function obj = RKHSEmbeddingStrengthLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor)
            obj =obj@Learner.ModelLearner.RKHSModelLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor);
        end
        
        function [embedding] = getFeaturesInternal(obj, numFeatures, inputMatrix)
            K_sa_in = inputMatrix(:,1:size(obj.K_sa_sa ,1 ))'; 
            K_sa = obj.K_sa_sa;
            m1 = size(obj.K_ref_s1,2);
            n = size(inputMatrix,1);

            cond_embed = (K_sa + obj.lambda*eye(size(K_sa)))\K_sa_in; %one column for every (S,A) predict
            gamma = 1-obj.resetProbTimeSteps;

            %features = gamma * obj.K_ref_sprime * cond_embed + (1-gamma) /m1 * obj.K_ref_s1*ones(m1,n);
            embedding = gamma * cond_embed + (1-gamma) * obj.isFirstTimestep*ones(1,n) / m1; 

            if(size(embedding,1) > obj.getNumFeatures())
                warning('RKHSModelLearner_unc:numFeatures','amount of features not supported')
                embedding = embedding(1:obj.getNumFeatures(),:)';
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(embedding,1));
                embedding = [embedding', zerofeatures];
            end
        end
        

     
        function objective = optimizationObjective(obj, data, params)
            
            n_episodes = data.getDataStructure.numElements;
            n_samples = data.getDataStructure.steps.numElements;
            objective = 0;
            nStateParam = numel(obj.sfeatureExtractor.getHyperParameters());
            stateParams = exp(params(1:nStateParam));
            obj.sfeatureExtractor.setHyperParameters(stateParams);
            obj.nsfeatureExtractor.setHyperParameters(stateParams);
            obj.safeatureExtractor.setHyperParameters(exp(params));            
            for i = 1:2
                train_start = i;
                val_start = mod(i,2)+1;
                if(n_episodes ==1)
                    train_idx = {1, train_start:2:n_samples};
                    val_idx = {1, val_start:2:n_samples};
                else
                    train_idx = {train_start:2:n_episodes};
                    val_idx = {val_start:2:n_episodes};                        
                end
                % |
                % v TODO - data is constant, can be pre-computed            
                trains = data.getDataEntry(obj.currentInputFeature, train_idx{:}); %states train
                vals = data.getDataEntry(obj.currentInputFeature, val_idx{:}); %states validate
                traina = data.getDataEntry('actions', train_idx{:}); %actions train
                vala = data.getDataEntry('actions', val_idx{:}); %actions validate
                valsprime =data.getDataEntry(obj.nextInputFeature, val_idx{:}); % next States validate
                trainsprime = data.getDataEntry(obj.nextInputFeature, train_idx{:}); %next states train
                % ^ constant up to here
                % |
                %locallambda_sa = exp(params(1));

                
                skf = @(s1,s2) obj.sfeatureExtractor.getGramMatrix(s1,s2);
                locallambda = exp(params(1));
                sakf = @(sa1,sa2) obj.safeatureExtractor.getGramMatrix(sa1,sa2);

                Kt_in = sakf([trains, traina], [trains, traina]);
                Kt_out = skf(trainsprime,trainsprime);
                Ktv_in = sakf([trains, traina], [vals, vala]);
                Ktv_out = skf(trainsprime, valsprime);

                wts = (Kt_in + locallambda * eye(size(Kt_in))) \ Ktv_in;

                sumK_out = 0;
                for j = 1:size(vals,1)
                    sumK_out = sumK_out + skf(valsprime(j,:), valsprime(j,:));
                end
                pred_ft = Kt_out * wts;
                true_ft = Ktv_out;
                prediction_error = pred_ft - true_ft;
                foldobjective = sum(sum(prediction_error.^2));
                
                %foldobjective = 0;
                %foldobjective = foldobjective - 2 * sum(sum(Ktv_out' .* wts'));
                %foldobjective = foldobjective + sum(sum(wts.*(Kt_out*wts)));
                
         
                
                %foldobjective = sumK_out - 2*sum(sum(Ktv_out.*wts)) + sum(sum(wts.*(Kt_out*wts) ));
                objective = objective + foldobjective;
            end
        end

    
    end
    
end

