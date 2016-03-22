classdef SLSampler < Sampler.EpisodeSampler
    
    properties
        slSampler;
    end
    
    methods
        function [obj] = SLSampler(varargin)
            obj = obj@Sampler.EpisodeSampler(varargin{:});
            
            subDataManager = Data.DataManager('steps');
            obj.dataManager.setSubDataManager(subDataManager);
            obj.addSamplerPool('InitRobot', 2);
            obj.setParallelSampling(false);
            obj.dataManager.finalizeDataManager();
        end
                
        function [dataManager] = getStepDataManager(obj)
            dataManager = obj.stepSampler.getDataManagerForSampler();
        end        
                                        
        function [] = setSLEpisodeSampler(obj, episodeSampler)
            
            obj.addSamplerFunctionToPool('Episodes', 'sampleEpisode', episodeSampler, 1);
            obj.addSamplerFunctionToPool('InitRobot', 'getRobotContext', episodeSampler, 1);            

            obj.slSampler = episodeSampler;
        end                          
        
        function [] = setRewardFunction(obj, rewardFunction)
            obj.addSamplerFunctionToPool('FinalReward', 'sampleReward', rewardFunction, 0);
            obj.addSamplerFunctionToPool('FinalReward', 'sampleFinalReward', rewardFunction, 0);                        
        end
        
        function [numSamples] = getNumSamples(obj, data, varargin)
            numSamples = obj.getNumSamples@Sampler.EpisodeSampler(data, varargin{:});   
            numSamples(2) = obj.slSampler.getNumTimeSteps();
        end
        
        function [isValid] = isValidEpisode(obj)
            isValid = obj.slSampler.isValidLastEpisode();
        end
        
    end
end