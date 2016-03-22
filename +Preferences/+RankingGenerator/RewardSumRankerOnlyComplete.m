classdef RewardSumRankerOnlyComplete < Preferences.RankingGenerator.AbstractRankingGenerator
    
    methods
        function obj =  RewardSumRankerOnlyComplete(dataManager,calculateGlobal,featureVariables)
            if (~exist('featureVariables', 'var'))
                featureVariables = 'returns';
            end
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            obj = obj@Preferences.RankingGenerator.AbstractRankingGenerator(dataManager, calculateGlobal, featureVariables);
        end
        
        function [ranks] = getRanks(obj, returns, state)
            %TODO: Replace with more efficient version
            ranks = ones(size(returns));
            for i = 1:size(returns)
                for j = i+1:size(returns)
                    if state(i)==1 && (returns(i) > returns(j) || state(j)==0)
                        ranks(j)=ranks(j)+1;
                    end
                    if state(j)==1 && (returns(i) < returns(j) || state(i)==0)
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
            
            ranks(state==0)=Inf;
        end
    end
    
end

