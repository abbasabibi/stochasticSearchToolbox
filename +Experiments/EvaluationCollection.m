classdef EvaluationCollection < Common.IASObject
    
    properties
        
        parameterNames
        parameterValues
        
        experiment
        evaluations
    end
    
    methods
        function obj = EvaluationCollection(experiment, evaluations, parameterNames, parameterValues)                                   
                       
            obj.parameterNames = parameterNames;
            obj.parameterValues = parameterValues;
            
            obj.experiment = experiment;
            obj.evaluations = evaluations;
        end        
        
        function [trial] = loadTrial(obj, trialIdx)
            trial = obj.experiment.loadTrialFromID(obj.trialIDs(trialIdx));
        end
        
        function [dataEval, plotData] = plotResultsTrials(obj, isLog, selectedField, evaluations, trials)
            
            if (~exist('isLog', 'var'))
                isLog = false;
            end
            
            parameterLabel = obj.parameterNames;
            [dataEval, fieldNames] = obj.getTrialData();
            parameterString = '';
            for i = 1:length(parameterLabel)
                if (strcmp(parameterLabel{i}(1:9), 'settings.'))
                    parameterString =[parameterString, parameterLabel{i}(10:end), '= %e'];
                else
                    parameterString =[parameterString, parameterLabel{i}, '= %e'];
                end
                
                if (i < length(parameterLabel))
                    parameterString =[parameterString, ', '];
                end
            end
            
            for i = 1:length(fieldNames)
                if (exist('selectedField', 'var'))
                    if ~strcmp(fieldNames{i},selectedField)
                        continue;
                    end
                end
                plotName = [obj.experiment.experimentId, obj.parameterNames{1}, fieldNames{i}];
                [plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEval, 'iterations',  fieldNames{i}, parameterLabel, @(varargin) sprintf(parameterString, varargin{:}),'', isLog, evaluations, trials);
                %[plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEval, 'iterations',  fieldNames{i}, parameterLabel, @(varargin) sprintf(parameterString, varargin{:}), plotName, isLog, [], [])

                Plotter.PlotterEvaluations.plotData(plotData);
            end            
        end                                                                               
        
        function [data, fieldNames] = getTrialData(obj)
                        
            fieldNames = {};
            for i = 1:length(obj.evaluations)
                [data{i}, fieldNamesLocal] = obj.evaluations{i}.getTrialData();
                fieldNames = union(fieldNames, fieldNamesLocal);
            end
        end        
        
        function [keys] = getTrialIDs(obj)
            keys = [];
            for i = 1:length(obj.evaluations)
                keys = [keys, obj.evaluations{i}.getTrialIDs()];
            end
        end
        
        function startBatch(obj, varargin)
            obj.experiment.startBatchTrials(obj.getTrialIDs(), varargin{:});
        end
        
        function startLocal(obj, varargin)
            obj.experiment.startLocal(obj.getTrialIDs());
        end
        
    end
end

