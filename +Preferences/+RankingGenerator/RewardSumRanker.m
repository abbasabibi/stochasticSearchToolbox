classdef RewardSumRanker < Preferences.RankingGenerator.AbstractRankingGenerator
    
    properties (SetObservable)
        m = 0;
    end
    
    methods
        function obj =  RewardSumRanker(dataManager,calculateGlobal,featureVariables)
            if (~exist('featureVariables', 'var'))
                featureVariables = 'returns';
            end
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            
            obj = obj@Preferences.RankingGenerator.AbstractRankingGenerator(dataManager, calculateGlobal, featureVariables);
            
            obj.linkProperty('m','preferenceNoiseLimit');
        end
        
        function [preference] = compareReturns(obj, ret1, ret2)
            res = ret1-ret2;
            if res > obj.m
                preference = 1;
            else
                if res < -obj.m
                    preference = 0;
                else
                    prob = 0.5 + (res / (2 * obj.m)) * (1 + log(obj.m / abs(res)));
                    if isnan(prob)
                        preference = 0.5;
                    else
                        preference = rand()<prob;
                    end
                end
            end
        end
        
        function [ranks] = getRanks(obj, returns, ~)
            %TODO: Replace with more efficient version
            ranks = ones(size(returns)); 
            ranks(isnan(returns))=0;
            for i = 1:size(returns)
                if(ranks(i)==0) 
                    continue;
                end;
                for j = i+1:size(returns)
                    if(ranks(j)==0) 
                        continue;
                    end;
                    pref = obj.compareReturns(returns(i),returns(j));
                    if pref == 1
                        ranks(j)=ranks(j)+1;
                    end
                    if pref == 0
                        ranks(i)=ranks(i)+1;
                    end
                end
            end
            
            for r = 1:size(returns)
                cnt = sum(ranks==r);
                if cnt>1
                    for i = 1:size(returns)
                        v = ranks(i);
                        if v>r
                            v=v-cnt+1;
                            ranks(i)=v;
                        end
                    end
                end
            end
        end
    end
    
end

