classdef EvaluationCriterion < handle;
    
    properties
        hooks = struct();
        
        saveDataEntries = {};
        saveNumDataPoints = 50;
        saveIterationModulo = 10;
        
        plotResults = false;
        
    end
    
    methods
        function addCriterion(obj,hook,fields,outputNames,storingType,parseFun,doStoreInDataHACK)
            
            if(~isfield(obj.hooks,hook))
                obj.hooks.(hook) = struct('fields',{},'outputNames',{},'parseFun',[],'storingType',Experiments.StoringType.STORE);
            end
            
            if(~iscell(fields))
                fields = {fields};
            end
            
            %check if output Name is already there
            
            
            if(~exist('outputNames','var') || isempty(outputNames))
                outputNames = fields;
            elseif(~iscell(outputNames))
                outputNames = {outputNames};
            end
            
            foundCriterion = false;
            for i = 1:length(obj.hooks.(hook))
                if (isequal(outputNames, obj.hooks.(hook)(i).outputNames))
                    foundCriterion = true;
                end
            end
            
            if (~foundCriterion)
                obj.hooks.(hook)(end+1).fields = fields;
                
                obj.hooks.(hook)(end).outputNames = outputNames;
                
                if(~exist('storingType','var') || isempty(storingType))
                    storingType = Experiments.StoringType.STORE;
                end
                obj.hooks.(hook)(end).storingType = storingType;
                
                if(~exist('parseFun','var') || isempty(parseFun))
                    parseFun = [];
                end
                obj.hooks.(hook)(end).parseFun = parseFun;
                
                if(~exist('doStoreInDataHACK','var') || isempty(doStoreInDataHACK))
                    doStoreInDataHACK = true;
                end
                obj.hooks.(hook)(end).doStoreInDataHACK = doStoreInDataHACK;
            end
        end
        
        
        function [] = registerEvaluator(obj, evaluator)
            if (iscell(evaluator.hook))
                for i = 1:length(evaluator.hook)
                    obj.addCriterion(evaluator.hook{i}, {'data', 'obj.getNewDataObject(1)','trial'}, evaluator.name, evaluator.storingType, @evaluator.getEvaluation);
                end
            else
                obj.addCriterion(evaluator.hook, {'data', 'obj.getNewDataObject(1)', 'trial'}, evaluator.name, evaluator.storingType, @evaluator.getEvaluation);
            end
        end
        
        
        function nextIteration(obj, trial, data)
            trial.storeTrial();
            if trial.iterIdx < trial.numIterations
                trial.iterIdx = trial.iterIdx+1;
            else
                trial.isFinished = true;
            end
        end
        
        
        function [] = addSaveDataEntry(obj, dataEntry)
            obj.saveDataEntries{end + 1} = dataEntry;
        end
        
        function [] = setSaveNumDataPoints(obj, numDataPoints)
            obj.saveNumDataPoints = numDataPoints;
        end
        
        function [] = setSaveIterationModulo(obj, modulo)
            obj.saveIterationModulo = modulo;
        end
        
        function evaluate(obj,trial,hook)
            if(isfield(obj.hooks,hook))
                for criterion = obj.hooks.(hook)
                    params = sprintf(',%s',criterion.fields{:});
                    params = evalin('caller',sprintf('{%s};',params(2:end)));
                    if(~isempty(criterion.parseFun))
                        tmp = cell(1,numel(criterion.outputNames));
                        tmp{:} = criterion.parseFun(params{:});
                        params = tmp;
                    end
                    
                    NOutputs = numel(criterion.outputNames);
                    for paramIdx = 1:numel(params)
                        if(~isequal(params{paramIdx},Experiments.StoringType.NONE))
                            if(paramIdx <= NOutputs)
                                outputName = criterion.outputNames{paramIdx};
                            else
                                outputName = criterion.fields{paramIdx};
                            end
                            outputName = strrep(outputName, '.', '_');
                            trial.store(outputName,params{paramIdx},criterion.storingType);
                        end
                    end
                end
                
                if (strcmp(hook, 'endLoop') && mod(trial.iterIdx, obj.saveIterationModulo) == 0)
                    data = evalin('caller', 'data');
                    dataIndices = false(data.getNumElements(), 1);
                    numDataPoints = min(data.getNumElements(), obj.saveNumDataPoints);
                    dataIndices(end - numDataPoints + 1:end) = true;
                    for entry = obj.saveDataEntries
                        if(data.isDataEntry(entry))
                            data.getDataEntry(entry{:}); % force all features to be generated
                        end
                    end
                    dataStruct = trial.dataManager.getPartialDataStructure(data.getDataStructure(), obj.saveDataEntries, dataIndices);
                    %dataObject = Data.Data(trial.dataManager, dataStruct);
                    trial.store('data', dataStruct, Experiments.StoringType.STORE_PER_ITERATION);
                end
            end
        end
        
    end
    
end

