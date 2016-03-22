classdef RewardSumRankerWithGoal < Preferences.RankingGenerator.AbstractRankingGenerator
    
    methods
        function obj =  RewardSumRankerWithGoal(dataManager,calculateGlobal,featureVariables)
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
                    if (returns(i) > returns(j) && state(i)==state(j)) || (state(j)==0 && state(i)==1)
                        ranks(j)=ranks(j)+1;
                    end
                    if (returns(i) < returns(j) && state(i)==state(j)) || (state(j)==1 && state(i)==0)
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

