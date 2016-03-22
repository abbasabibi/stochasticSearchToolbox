classdef CompareBestApproxRankPreferencesGenerator < Preferences.PreferenceGenerator.CompareBestPreferencesGenerator
    
    methods
        
        function obj =  CompareBestApproxRankPreferencesGenerator(dataManager,calculateGlobal,rankVariable)
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            obj = obj@Preferences.PreferenceGenerator.CompareBestPreferencesGenerator(dataManager,calculateGlobal,rankVariable);
        end
        
        function [newP] = createPairwisePreferences(obj,rank, iterationNumber)
            newP2 = obj.createPairwisePreferences@Preferences.PreferenceGenerator.CompareBestPreferencesGenerator(rank, iterationNumber);
            newP = zeros(size(newP2));
            %only for dominating atm
            while(sum(sum(newP~=newP2))>0)
                newP = newP2;
                [p,d] = find(newP==2);
                for i=1:numel(p)
                    tmpP2 = newP(p(i),:);
                    tmpD2 = newP(d(i),:);
                    tmpP2(tmpD2==2)=2;
                    newP2(p(i),:) = tmpP2;
                end
            end
        end
    end

end

