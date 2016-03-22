classdef MonteCarloFilter < Filter.AbstractFilter
    %MONACOFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataBase = [];
        numEpisodesInDataBase = 1e5;
        dataEntry = 'thetaNoisyNoisy'
        obsNoise = 1e-2;
        preprocessors = {};
        validityDataEntry;
        
        outputFullCovariance = false;
    end
    
    methods
        function obj = MonteCarloFilter(dataManager, stateDims, obsDims)
            obj = obj@Filter.AbstractFilter(dataManager, stateDims, obsDims);
            
            
        end
        
        function [mu, var] = filterData(obj, observations, observationPoints)
            dataRaw = obj.dataBase.getDataEntry3D(obj.dataEntry);
            valid = logical(obj.dataBase.getDataEntry(obj.validityDataEntry,1));
            dataRaw = dataRaw(:,valid);
            
            % [numSamples x 1 x episodeLength x dimensions]
            dataRaw = permute(dataRaw,[1 4 2 3]);
            % [1 x numObservations x episodeLength x dimensions]
            observations = permute(observations,[4 3 1 2]);
            
            
            % compute the log-likelihood of the observations for each
            % sample trajectory
            % [numSamples x numObservations x episodeLength x 1]
            logP_O_Y = -1 * sum((bsxfun(@minus,observations,dataRaw).^2)./(2* obj.obsNoise),4);
            % for each non-observed observation, set the distribution to
            % uniform
            logP_O_Y(:,:,not(logical(observationPoints)),:) = -log(size(dataRaw,1));
            % build the cumulative sums of the log-likelihood (cumulative
            % for filtering). Substract the max to prevent numerical
            % issues. Take the exp to obtain the likelihood
            pO_t = exp(bsxfun(@minus,cumsum(logP_O_Y,3),max(logP_O_Y,[],1)));
            % normalize for each time-step
            pt_O = bsxfun(@rdivide,pO_t,sum(pO_t,1));
            
            % weigh each time-step of the sample trajectories with the
            % probability of that trajectory in that time-step
            % [numSamples x numObservations x episodeLength x dimensions]
            weightedEpisodes = bsxfun(@times,dataRaw,pt_O);
            % compute the weighted mean
            % [1 x numObservations x episodeLength x dimensions]
            mu = sum(weightedEpisodes,1);
            % compute the weighted variance
            if obj.outputFullCovariance
                % [numSamples x numObservations x episodeLength x dimensions]
                diffs = bsxfun(@minus,dataRaw,mu);
                % [numSamples x numObservations x episodeLength x dimensions x dimensions]
                outerProd = bsxfun(@times,bsxfun(@times,diffs,pt_O),permute(diffs,[1,2,3,5,4]));
                % [1 x numObservations x episodeLength x dimensions x dimensions]
                var = sum(outerProd,1);
            else
                var = sum(bsxfun(@times,bsxfun(@minus,dataRaw,mu).^2,pt_O),1);
            end

            mu = squeeze(mu);
            var = squeeze(var);
        end
        
        function sampleShitloadOfData(obj, sampler)
            obj.dataBase = obj.dataManager.getDataObject([obj.numEpisodesInDataBase,sampler.stepSampler.getNumSamples]);

            numSamplesTmp = sampler.numSamples;
            initialSamplesTmp = sampler.numInitialSamples;
            seed = rng;
            rng(1000);
            sampler.numSamples = obj.numEpisodesInDataBase;
            sampler.numInitialSamples = obj.numEpisodesInDataBase;
            sampler.createSamples(obj.dataBase);
            sampler.numSamples = numSamplesTmp;
            sampler.numInitialSamples=initialSamplesTmp;
            rng(seed);
            
            for prepro = obj.preprocessors
                prepro{1}.preprocessData(obj.dataBase);
            end
        end
    end
    
end

