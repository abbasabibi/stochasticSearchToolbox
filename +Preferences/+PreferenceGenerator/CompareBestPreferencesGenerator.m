classdef CompareBestPreferencesGenerator < Preferences.PreferenceGenerator.AbstractPreferenceGenerator
    
    methods
        
        function obj =  CompareBestPreferencesGenerator(dataManager,calculateGlobal,rankVariable, featureExpectations)
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            obj = obj@Preferences.PreferenceGenerator.AbstractPreferenceGenerator(dataManager,calculateGlobal,rankVariable, featureExpectations);
        end
        
        function [newP] = createPairwisePreferences(obj,rank, iterationNumber, featureExpectations)
            newP = repmat(Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Undefined),size(rank,1),size(rank,1));
            
            validIdx = find(~isnan(rank));
            
            bestIdx = validIdx(1);
            
            for cidx=2:numel(validIdx)
                i = validIdx(cidx);
                j = bestIdx(1);
                obj.prefCount = obj.prefCount+1;
                if rank(i) < rank(j)
                    for idx1 = 1:numel(bestIdx)
                        newP(i,bestIdx(idx1)) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred);
                        newP(bestIdx(idx1),i) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Dominated);
                    end
                    bestIdx = [i];
                end
                if rank(j) < rank(i)
                    for idx1 = 1:numel(bestIdx)
                        newP(i,bestIdx(idx1)) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Dominated);
                        newP(bestIdx(idx1),i) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred);
                    end
                end
                if rank(j) == rank(i)
                    if sum(featureExpectations(i,:) ~= featureExpectations(j,:))>1
                        bestIdx = [bestIdx,i];
                    end
                end
            end
        end
    end

end

