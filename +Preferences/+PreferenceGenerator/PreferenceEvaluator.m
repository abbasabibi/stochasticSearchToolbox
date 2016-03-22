classdef PreferenceEvaluator < Evaluator.Evaluator
        
    methods
        function [obj] = PreferenceEvaluator() 
            obj = obj@Evaluator.Evaluator('preferences',{'endLoop'}, Experiments.StoringType.STORE_PER_ITERATION);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            prefs = data.getDataEntry('returnsrankspreferences');
            prefIds = find(prefs==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            [i,j] = ind2sub(size(prefs),prefIds);
            evaluation = [i,j];
        end
    end
    
end

