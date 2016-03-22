classdef AddDataAliasConfigurator < Experiments.Configurator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = AddDataAliasConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop([obj.name 'AliasNames'], {});
            trial.setprop([obj.name 'AliasIndices'], {});
            trial.setprop([obj.name 'AliasTargets'], {});
        end
        
        function postConfigureTrial(obj, trial)
            aliasNames = trial.([obj.name 'AliasNames']);
            aliasIndices = trial.([obj.name 'AliasIndices']);
            aliasTargets = trial.([obj.name 'AliasTargets']);
            
            for i = 1:length(aliasNames)
                if isempty(aliasIndices)
                    trial.dataManager.addDataAlias(aliasNames{i},aliasTargets{i});
                else
                    trial.dataManager.addDataAlias(aliasNames{i},aliasTargets{i},aliasIndices{i});
                end
            end
        end
    end
    
end

