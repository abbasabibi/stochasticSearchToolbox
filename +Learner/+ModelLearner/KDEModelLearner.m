classdef KDEModelLearner < Learner.Learner & FeatureGenerators.FeatureGenerator
    %RKHSFEATURELEARNER Updates conditional RKHS model and calculates
    %features
    
    properties(SetObservable,AbortSet)
        stateFeature = 'ProdKernel';
        stateActionFeature = 'ProdKernel';
       
        
        statesactionstrain

        convolution_ns 
        convolution_s1 
        
        resetProbTimeSteps = 0.1
        featureTag = 1;
        lambda = 1e-6;
        
        %featureTag = 1;
        
        sfeatureExtractor;
        nsfeatureExtractor;
        safeatureExtractor;


        %numFeatures;
        currentInputFeature;
        nextInputFeature;
        modelParamsstate
        paramsdensity %linked to property

        densityparams; %params for use as density estimate
        featureparams; % params for use as feature extractor
    end
    
    methods
        function plotDistr(obj, i, nextstates)
            nstateparams = size(obj.nsfeatureExtractor.getHyperParameters(),2);
            stateactionparams = obj.densityparams(nstateparams+1:end);
            nsparams = obj.densityparams(1:nstateparams);
            obj.safeatureExtractor.setHyperParameters(stateactionparams );
            obj.nsfeatureExtractor.setHyperParameters(nsparams );
            
            d1 =-pi:0.1:pi;
            d2 = -10:0.1:10;
            [ns1, ns2] = meshgrid(d1,d2 );
            ns = [ns1(:), ns2(:)];
            activations = obj.safeatureExtractor.getGramMatrix(obj.statesactionstrain,obj.statesactionstrain );
            weights = bsxfun(@rdivide, activations, sum(activations,1));
            probs = obj.nsfeatureExtractor.getGramMatrix(ns, nextstates);
            p = probs * weights(:,1);
            p = reshape(p, size(ns1));
            figure(123)
            set(3, 'Renderer','painters')
            contour(d1,d2,p)
            hold on;
            plot(nextstates(i,1),nextstates(i,2),'k*')
            hold off;
            obj.safeatureExtractor.setHyperParameters(obj.featureparams );
            obj.nsfeatureExtractor.setHyperParameters(obj.featureparams(1:nstateparams) );
        end
        
        function obj = KDEModelLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor)
            
            featureVariables={{sfeatureExtractor.featureVariables{1},'actions'}};
            numFeatureslocal = sfeatureExtractor.getNumFeatures();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'ExpNextFeat', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            

            obj.sfeatureExtractor = sfeatureExtractor;
            obj.safeatureExtractor = safeatureExtractor;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.linkProperty('resetProbTimeSteps');
            obj.linkProperty('modelParamsstate');
            obj.linkProperty('paramsdensity');
            obj.currentInputFeature = sfeatureExtractor.featureVariables{1};
            obj.nextInputFeature = nsfeatureExtractor.featureVariables{1};
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, saInput)

            % joint probabilities of input matrix rows 
            % (not normalized by number of samples)
            
            %switch to density params
            nstateparams = size(obj.nsfeatureExtractor.getHyperParameters(),2);
            stateactionparams = obj.densityparams(nstateparams+1:end);
            obj.safeatureExtractor.setHyperParameters(stateactionparams );

            activations = obj.safeatureExtractor.getGramMatrix(obj.statesactionstrain,saInput );

            %m = size(saInput,1);
            
            %weights of the kernels
            weights = bsxfun(@rdivide, activations, sum(activations,1));
            
            
            ExpFeat = obj.convolution_ns * weights;
            
            ExpFeatReset = repmat(mean(obj.convolution_s1,2), 1,size(ExpFeat,2)) ;
            
            
            features = ((1-obj.resetProbTimeSteps) * ExpFeat + obj.resetProbTimeSteps*ExpFeatReset)';
            
            if(size(features,2) > obj.getNumFeatures())
                warning('KDEModelLearner:numFeatures','amount of features not supported')
                features = features(:,1:obj.getNumFeatures());
            else
                zerofeatures = zeros(size(saInput,1), obj.getNumFeatures()-size(features,2));
                features = [features, zerofeatures];
            end

            %set back to featureparams
            obj.safeatureExtractor.setHyperParameters(obj.featureparams );
        end
        
        function objective = negCVloglikelihood(obj, data, lparams)
            n_episodes = data.getDataStructure.numElements;
            train_idx = 1:2:n_episodes;
            val_idx = 2:2:n_episodes;
            objective = 0;

            nstateparams = size(obj.nsfeatureExtractor.getHyperParameters(),2);
            nextstateparams = exp(lparams(1:nstateparams)); 
            stateactionparams = exp(lparams(nstateparams+1:end));
            
            obj.safeatureExtractor.setHyperParameters(stateactionparams );
            obj.nsfeatureExtractor.setHyperParameters(nextstateparams);
           
            for i = 1:2
                if(i==2)
                    temp = train_idx;
                    train_idx =val_idx;
                    val_idx = temp;
                end
                st = data.getDataEntry(obj.currentInputFeature, train_idx); %states train
                sv = data.getDataEntry(obj.currentInputFeature, val_idx); %states train
                nst = data.getDataEntry(obj.nextInputFeature, train_idx); %states train
                nsv = data.getDataEntry(obj.nextInputFeature, val_idx); %states train
                at = data.getDataEntry('actions', train_idx); %states train
                av = data.getDataEntry('actions', val_idx); %states train

                activations = obj.safeatureExtractor.getGramMatrix([st,at],[sv,av] );
                weights = bsxfun(@rdivide, activations, sum(activations,1));
                likely = obj.nsfeatureExtractor.getGramMatrix(nst, nsv);
                objective = objective - sum(log(sum(weights.*likely)));
                
            end

        end
        
        function objective = TDobjective(obj, data, params)
            % maximize for reward prediction
            % params: lambda_sa, lambda_r, stateparams, actionparams
            
            gamma = 1-obj.resetProbTimeSteps;
            n_episodes = data.getDataStructure.numElements;
            train_idx = 1:2:n_episodes;
            val_idx = 2:2:n_episodes;
            objective = 0;
            
            for i = 1:2
                if(i==2)
                    temp = train_idx;
                    train_idx =val_idx;
                    val_idx = temp;
                end
                st = data.getDataEntry(obj.currentInputFeature, train_idx);
                spt = data.getDataEntry(obj.nextInputFeature, train_idx);
                
                sv = data.getDataEntry(obj.currentInputFeature, val_idx);
                spv = data.getDataEntry(obj.nextInputFeature, val_idx);
       
                rt = data.getDataEntry('rewards', train_idx);
                rv = data.getDataEntry('rewards', val_idx);

                locallambda_r= exp(params(1));
                nStateParam = numel(obj.sfeatureExtractor.getHyperParameters());
                stateParams = exp(params(1:nStateParam));
                obj.sfeatureExtractor.setHyperParameters(stateParams);
                obj.nsfeatureExtractor.setHyperParameters(stateParams);

                skf = @(s1,s2) obj.sfeatureExtractor.getGramMatrix(s1, s2);           
                K_spt_spt = skf(spt,spt);
                K_spt_st  = skf(spt,st);


                K_spt_spv = skf(spt, spv);
                K_spt_sv = skf(spt,sv);
                
                ft_dif_train = K_spt_spt - K_spt_st;
                ft_dif_val   = K_spt_spv - K_spt_sv;
                
                rtc = rt - mean(rt);
                
                coefs = (ft_dif_train * ft_dif_train'+ locallambda_r * eye(size(ft_dif_train * ft_dif_train')))\ ft_dif_train * rtc;
                TD = ft_dif_val' * coefs - (rv - mean(rt));
                
                foldobjective = norm(TD);

                if(imag(foldobjective)~= 0)
                    %fprintf('Warning: complex predictions!')
                    foldobjective = real(foldobjective);
                end
                objective = objective + foldobjective;
            end            
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
     
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
        
        function obj = updateModel(obj, data)   
            obj.featureTag = obj.featureTag + 1; 
            
            


            %obj.safeatureExtractor.setHyperParameters([stateParams, actionParams]);
            
            %obj.K_sa_sa = data.getDataEntry([obj.currentInputFeature, 'actions', obj.stateActionFeature]);
            ns = data.getDataEntry([obj.nextInputFeature]);
            s = data.getDataEntry([obj.currentInputFeature]);
            s1 = data.getDataEntry([obj.currentInputFeature],:,1);
            
            sref = s;
            %n_sa = size(obj.K_sa_sa,1);      
            a = data.getDataEntry('actions');
            obj.statesactionstrain = [s,a];

            paramsoptstate = obj.modelParamsstate;
            if(any(paramsoptstate < 0))
                
                lparamsoptstate = log(paramsoptstate);
                tooptimize_state = find(paramsoptstate < 0);

                linitparams = log(-paramsoptstate(tooptimize_state));           
                getparams = @(params) Experiments.test.mergeVectors(lparamsoptstate, params, tooptimize_state );
                stateparamsopt = fminunc(@(params)  obj.TDobjective(data,  getparams(params) ), linitparams);
                paramsoptfeature = getparams(stateparamsopt);
            else
                paramsoptfeature = log(paramsoptstate)
            end

            paramsdens = obj.paramsdensity;
            if(any(paramsdens < 0))
                
                tooptimize_actions = find(paramsdens < 0);
                linitparams = log(-paramsdens(tooptimize_actions));           
                getparams = @(params) Experiments.test.mergeVectors(log(paramsdens), params, tooptimize_actions );
                [densopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.negCVloglikelihood(data,  getparams(params) ), linitparams);
                paramsdens = getparams(densopt);
            else
                paramsdens = log(paramsdens);
            end

            %conv(i,j) how much does kernel j contribute to feature i
            ns_dens_bandwidth = exp(paramsdens([3,5]));
            
            
            nstateParams = size(obj.nsfeatureExtractor.getHyperParameters(),2);
            stateParams = exp(paramsoptfeature(1:nstateParams));
            obj.nsfeatureExtractor.setHyperParameters(stateParams);
            obj.sfeatureExtractor.setHyperParameters(stateParams);
            obj.convolution_ns = obj.nsfeatureExtractor.convolve(sref, ns, ns_dens_bandwidth );
            obj.convolution_s1 = obj.nsfeatureExtractor.convolve(sref, s1 ,ns_dens_bandwidth );

            obj.densityparams = exp(paramsdens);
            obj.featureparams = exp(paramsoptfeature);

             

        end

    end
    
end

