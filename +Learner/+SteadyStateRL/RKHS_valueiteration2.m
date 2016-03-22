classdef RKHS_valueiteration2 < Learner.Learner
    %RKHS_VALUEITERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        embeddingstrengthlearner
        rewardfunction
        policy
        inputVar = 'nextStates'
        inputFeatures = 'ProdKernel'
        sampler
        nextVfunction
    end
    
    properties (SetObservable, AbortSet)
        resetProb
    end
    
    methods
        function obj = RKHS_valueiteration2(dataManager, embeddingstrengthlearner, rewardfunction, policy, inputVar, inputFeatures, sampler)
            obj = obj@Learner.Learner();
            obj.embeddingstrengthlearner = embeddingstrengthlearner;
            obj.rewardfunction = rewardfunction;
            obj.policy = policy;
            obj.nextVfunction = policy.nextVfunction;
            obj.linkProperty('resetProb');
            if(exist('inputVar','var'))
                obj.inputVar = inputVar;
            end
            if(exist('inputFeatures','var'))
                obj.inputFeatures = inputFeatures;
            end
            if(exist('sampler','var'))
                obj.sampler = sampler;
            end
        end
       
        
        function updateModel(obj, data)
            actions = obj.policy.getPossibleActions;
            
            if obj.sampler ~= []
                nsamples = 1000;
                dm = obj.sampler.getDataManagerForSampler();
                dm.finalizeDataManager();
                data = dm.getDataObject(nsamples);
                obj.sampler.numSamples = nsamples;
                obj.sampler.setParallelSampling(true);
                obj.sampler.createSamples(data); %use generated data instead of true data
            end
            statefeatures = data.getDataEntry([obj.inputVar, obj.inputFeatures]);
            states = data.getDataEntry([obj.inputVar]);
            
            rewardinputlabels = obj.rewardfunction.getInputArguments('rewardFunction');
            if(~iscell(rewardinputlabels{1}))
                rewardinputlabels = {rewardinputlabels}; % make sure it is cell array of cell arrays
            end
            isactioninput = cellfun(@(x) strcmp(x{1},'actions') ,rewardinputlabels);
            rewardinputs_noactions = data.getDataEntryCellArray(rewardinputlabels(~isactioninput));
            rewardinputs = cell(size(isactioninput));
            rewardinputs(~isactioninput) = rewardinputs_noactions;
            
           % rawstates = data.getDataEntry('nextStates'); %original states for reward fc
            m = size(statefeatures,1);
            
            
            %TODO only works for 1d actions!
            embeddingstr = zeros(m, m, size(actions,1)); 
            rewards = zeros(m, size(actions,1));
            
            for i = 1:size(actions,1)    
                % TODO should use next states too?
                safeatures = obj.embeddingstrengthlearner.safeatureExtractor.getFeatures(:,[states, repmat(actions(i,:), m, 1) ] );
                embed = obj.embeddingstrengthlearner.getFeatures(:,safeatures);
                embeddingstr(:,:,i) = embed(:,1:m);
                rewardinputs(isactioninput) = {repmat(actions(i,:), m, 1)};
                rewards(:,i) = obj.rewardfunction.rewardFunction(rewardinputs{:} );
            end
       
            q = rewards;
            v = max(q,[],2);                 
            
            n = 1;
            error = norm(v);
            maxn = 100;
            'valueiteration2'
            while n < maxn && error/norm(v) > 1e-2
                % expectedfeatures * embeddingstrengths
                expnextv = sum(bsxfun(@times, embeddingstr, v'),2);
                q = rewards + (1-obj.resetProb) * permute(expnextv,[1,3,2]);
                newv = max(q,[],2);
                %newv = newv / norm(newv);
                error = norm(v - newv);
                oldv = v;
                v = newv;
                n=n+1;
                if(usejava('jvm') && usejava('desktop') )
                    plot(v)
                end
            end
            if(n == maxn)
                warning('RKHS_valueiteration2: no solution found in nmax iterations')
            end

            if(isempty(obj.nextVfunction.featureGenerator))
                obj.nextVfunction.setFeatureGenerator(obj.embeddingstrengthlearner);
            end
            
            weights = [v; zeros(obj.embeddingstrengthlearner.safeatureExtractor.getNumFeatures - m, 1)];
            obj.nextVfunction.setWeightsAndBias(weights', 0);
            
            if(false)
                sdata = (data.getDataEntry('states'));
                statesft = data.getDataEntry('statesProdKernel');
                v = obj.nextVfunction.getExpectationGenerateFeatures(1,statesft(1:(13*17),:));
                ac = obj.policy.getExpectation(1, statesft(1:(17*13), :), sdata(1:(17*13),:));
                figure(4), surf(reshape(sdata(1:17*13,1),17,13), reshape(sdata(1:17*13,2),17,13), reshape(ac(1:17*13),17,13));
                figure(1); surf(reshape(sdata(1:17*13,1),17,13), reshape(sdata(1:17*13,2),17,13), reshape(v(1:(17*13)), 17,13));
                
                states1 = linspace(-0.5*pi, 1.5*pi, 32);
                
                states2 = linspace(-15, 15, 60);
                [s1,s2] = meshgrid(states1, states2);
                states = [s1(:), s2(:)];
                statesft = obj.embeddingstrengthlearner.sfeatureExtractor.getFeatures(1, states);
                ac = obj.policy.getExpectation(1, statesft, states);
                figure(2)
                imagesc(s1(1,:), s2(:,1), reshape(ac, 60, 32))
                
            end
        end
        
    end
    
end

