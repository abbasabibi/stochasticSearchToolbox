classdef CancerTrajectoryRanker < Preferences.RankingGenerator.AbstractRankingGenerator
    
    properties
        eps = 0.1;
    end
    
    methods
        function obj =  CancerTrajectoryRanker(dataManager,calculateGlobal,featureVariables)
            if (~exist('featureVariables', 'var'))
                featureVariables = 'cancerEval';
            end
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            obj = obj@Preferences.RankingGenerator.AbstractRankingGenerator(dataManager, calculateGlobal, featureVariables);
        end
        
        function [ranks] = getRanks(obj, cancerEval, ~)
            %TODO: Replace with more efficient version
            ranks = ones(size(cancerEval,1),1);
            
            for i = 1:size(cancerEval,1)
                for j = i+1:size(cancerEval,1)
                    if cancerEval(i,3) < cancerEval(j,3)
                        ranks(j)=ranks(j)+1;
                    end
                    if cancerEval(i,3) > cancerEval(j,3)
                        ranks(i)=ranks(i)+1;
                    end
                    if cancerEval(i,3) == 0 && cancerEval(j,3) == 0
                        if cancerEval(i,2) < cancerEval(j,2)
                            ranks(j)=ranks(j)+1;
                        end
                        if cancerEval(i,2) > cancerEval(j,2)
                            ranks(i)=ranks(i)+1;
                        end
                        if abs(cancerEval(i,2)-cancerEval(j,2)) < obj.eps
                            if cancerEval(i,1) < cancerEval(j,1)
                                ranks(j)=ranks(j)+1;
                            end
                            if cancerEval(i,1) > cancerEval(j,1)
                                ranks(i)=ranks(i)+1;
                            end
                        end
                    end
                end
            end
            
            for r = 1:size(cancerEval,1)
                cnt = sum(ranks==r);
                if cnt>1
                    for i = 1:size(cancerEval,1)
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

