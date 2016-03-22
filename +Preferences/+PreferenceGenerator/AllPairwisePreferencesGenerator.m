classdef AllPairwisePreferencesGenerator < Preferences.PreferenceGenerator.AbstractPreferenceGenerator
    
    methods
        
        function obj =  AllPairwisePreferencesGenerator(dataManager,calculateGlobal,rankVariable)
            if (~exist('calculateGlobal', 'var'))
                calculateGlobal=false;
            end
            obj = obj@Preferences.PreferenceGenerator.AbstractPreferenceGenerator(dataManager,calculateGlobal,rankVariable);
        end
        
        function [newP] = createPairwisePreferences(obj,rank, iterationNumber)
            newP = repmat(Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Undefined),size(rank,1),size(rank,1));
            for i = 1:size(rank)
                for j = i+1:size(rank)
                    if isnan(rank(i)) || isnan(rank(j))
                        continue;
                    end
                    obj.prefCount = obj.prefCount+1;
                    if rank(i) < rank(j)
                        newP(i,j) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred);
                        newP(j,i) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Dominated);
                    end
                    if rank(j) < rank(i)
                        newP(i,j) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Dominated);
                        newP(j,i) = Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred);
                    end
                end
            end
        end
    end
    
end

