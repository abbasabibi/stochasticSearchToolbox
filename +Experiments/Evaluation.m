classdef Evaluation < Common.IASObject
    
    properties
        numTrials;
        
        path
        
        evaluationName;
                
        iterStoreGroupSize = 10;
        
        mapJobIdxToTrialDir = {};                
        
        experiment
        evaluationID;
        
        trialIDs
        
        parameterNames
        parameterValues
        
    end
    
    methods
        function obj = Evaluation(experiment, evaluationID, evaluationSettings, parameterNames, parameterValues, numTrials)                                                                        
                       
            if(~exist('numTrials','var'))
                numTrials = 1;
            end
            obj.numTrials = numTrials; 
            obj.evaluationID = evaluationID;
            
            obj.parameterNames = parameterNames;
            obj.parameterValues = parameterValues;
            
            obj.settings = evaluationSettings;
            obj.setExperiment(experiment, evaluationID);
                     
        end
        
        function createEvaluationFile(obj)
            % TODO
        end
        
        function createDirectories(obj, overwrite)
            if (~exist('overwrite', 'var'))
                overwrite = false;
            end
            
            evalPath = obj.path;
            [st, msg, msgId] = mkdir(evalPath);
            obj.createEvaluationFile();
            
            settingsFile = fullfile(evalPath,sprintf('settings.mat'));
            evaluationSettings = obj.settings;
            save(settingsFile, 'evaluationSettings');
            
            obj.trialIDs = zeros(obj.numTrials,1);

            for trialIdx = 1:obj.numTrials
                trialPath = fullfile(evalPath,sprintf('trial%03d',trialIdx));
                if (~exist(fullfile(trialPath, 'trial.mat'), 'file'))
                    
                    trial = obj.experiment.createTrial(obj.settings, evalPath, trialIdx);
                    trial.storeTrial(overwrite);
                    fprintf('Created trial %s\n', trial.trialDir);
                   
                    trial.storeTrialInFile('initialTrial.mat');
                    
                else
                    fprintf('Found trial %03d/%03d, not recreating\n', trialIdx);
                end
                obj.trialIDs(trialIdx) = obj.experiment.registerTrial(obj, trialPath);
            end
            if(isunix)
                system(sprintf('chmod -R 775 %s',evalPath));
            end            
        end
        
        function [isEval] = isEvaluation(obj, parameters, values)
            isEval = true;
            for i = 1:length(parameters)
                isEval = isEval && obj.evaluationSettings.hasValue(parameters{i}, values{i});
            end            
        end
        
        function [] = setExperiment(obj, experiment, evaluationId)
            obj.evaluationName = sprintf('eval%03d', evaluationId);
            obj.path = [experiment.experimentPath, '/', obj.evaluationName];
            obj.experiment = experiment;
            
        end
        
        function [trial] = loadTrial(obj, trialIdx)
            trial = obj.experiment.loadTrialFromID(obj.trialIDs(trialIdx));
        end       
        
        function [dataEval, plotData] = plotResultsTrials(obj, isLog, selectedField, xData)
            
            if (~exist('isLog', 'var'))
                isLog = false;
            end
            
            parameterLabel = obj.parameterNames;
            if (~exist('xData', 'var'))
                xData = 'iterations';
            end
            
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
                [plotData ] = Plotter.PlotterEvaluations.preparePlotData(dataEval, xData,  fieldNames{i}, parameterLabel, @(varargin) sprintf(parameterString, varargin{:}), plotName, isLog, [], []);

                Plotter.PlotterEvaluations.plotData(plotData);
            end
            
        end
            
        
        function changeNumIterations(obj, expPath, evalIndices, numIterations)
            for evalIdx = evalIndices(:)'
                evalPath = fullfile(expPath,sprintf('eval%03d',evalIdx));
                for trialIdx = 1:obj.numTrials
                    trialPath = fullfile(evalPath,sprintf('trial%03d',trialIdx));
                    if(exist(fullfile(trialPath,'trial.mat'),'file'))
                        load(fullfile(trialPath,'trial.mat'));
                        if(trial.numIterations ~= numIterations)
                            fprintf('Changing numIterations from %d to %d for:\n\t%s\n',trial.numIterations,numIterations,trialPath)
                            trial.numIterations = numIterations;
                            trial.storeTrial();
                        end
                    end
                end
            end
        end
                     
        
        function startLocal(obj)            
            obj.experiment.startLocal(obj.trialIDs);
        end
        
        function startBatch(obj, varargin)
            obj.experiment.startBatchTrials(obj.getTrialIDs(), varargin{:});
        end
        
        function [keys] = getTrialIDs(obj)
            keys = obj.trialIDs;
        end
                               
        function [] = resetTrials(obj)
            obj.experiment.createDirectories(obj, true);
        end              
        
        function [data, fieldNames] = getTrialData(obj)
            
            data = struct('evalName',{},'trials',{});
            
            trialDirs = dir(fullfile(obj.path));
            trialDirs =  {trialDirs([trialDirs.isdir]).name};
            data(end+1).evalName = obj.evaluationName;
            data.settings = obj.settings;
            
            %trials = reshape([fields;repmat({{{}}},size(fields))],1,[]);
            trials = struct();
            fields = {};
            for trialDir = trialDirs
                trialDir = trialDir{1};
                
                if(~isempty(strfind(trialDir,'trial')))
                    data(end).trials(end+1).trialName = trialDir;
                    trialFile = fullfile(obj.path,trialDir,'data.mat');
                    fprintf('%s\n',trialFile);
                    if(exist(trialFile,'file'))
                        try                            
                            trial = load(trialFile);

                            if (isempty(fields))
                                fields = fieldnames(trial.data);
                            end
                            for i = 1:length(fields)
                                if(isfield(trial.data,fields{i}))
                                    data(end).trials(end).(fields{i}) = trial.data.(fields{i});
                                else
                                    data(end).trials(end).(fields{i}) = NaN;
                                end
                            end
                        catch E
                            
                        end                        
                    end
                end
            end
            isNumericField = true(length(fields),1);
            for i = 1:length(fields)
                if (~isnumeric(data(1).trials(1).(fields{i})))
                    isNumericField(i) = false;
                end
            end
            fieldNames = fields(isNumericField);
        end        
        
        
        
        function path = getTrialPath(obj, evalIdx, evalOffset, trialIdx)
            path = sprintf('eval%03d/trial%03d',evalIdx+evalOffset,trialIdx);
        end
        
       
%         
%         function data = getData(obj, expPath, defaultTrial, outputParams, conditions)
%             if(any(reshape(Experiments.Evaluation.containsValue(obj.values,{Experiments.EvaluationParameter.ALL, Experiments.EvaluationParameter.DEFAULT}),1,[])))
%                 error('Invalid symbol found in values.');
%             else
%                 if (numel(conditions) > 0)
%                     machedEvals = false(size(obj.values,1),1);
%                 else
%                     machedEvals = true(size(obj.values,1),1);
%                 end
%                 for condIdx = 1:numel(conditions)
%                     condMatchedEvals = true(size(obj.values,1),1);
%                     for paramIdx = 1:size(conditions{condIdx},1)
%                         checkValue = conditions{condIdx}{paramIdx,2};
%                         if(~isequal(checkValue,Experiments.EvaluationParameter.ALL))
%                             isSetting = strncmpi(conditions{condIdx}{paramIdx,1},'settings.',9);
%                             name = conditions{condIdx}{paramIdx,1}((1+9*isSetting):end);
%                             evalParamIdx = find(ismember(obj.parameters,conditions{condIdx}{paramIdx,1}));
%                             if(~isempty(evalParamIdx))
%                                 givenValue = obj.values(:,evalParamIdx);
%                             elseif(isSetting && defaultTrial.settings.isParameter(name))
%                                 givenValue = repmat({defaultTrial.settings.getParameter(name)},size(obj.values,1),1);
%                             elseif(isprop(defaultTrial,name))
%                                 givenValue = repmat({defaultTrial.(name)},size(obj.values,1),1);
%                             else
%                                 givenValue = repmat({Experiments.EvaluationParameter.NONE},size(obj.values,1),1);
%                             end
%                             
%                             condMatchedEvals = condMatchedEvals & Experiments.Evaluation.containsValue(givenValue,checkValue);
%                         end
%                     end
%                     machedEvals = machedEvals | condMatchedEvals;
%                 end
%                 %keyboard;
%                 data = struct([]);
%                 for evalIdx = find(machedEvals')
%                     evalDir = fullfile(expPath,sprintf('eval%03d',evalIdx));
%                     
%                     if(exist(evalDir,'dir'))
%                         trialDirs = dir(evalDir);
%                         trialDirs = {trialDirs([trialDirs(:).isdir]).name};
%                         trialDirs(ismember(trialDirs,{'.','..'})) = [];
%                         data(end+1).evalIdx = evalIdx;
%                         data(end).evalDir = evalDir;
%                         data(end).numTrials = numel(trialDirs);
%                         data(end).trial = struct([]);
%                         for i = 1:length(trialDirs)
%                             trialDir = trialDirs{i};
%                             load(fullfile(evalDir,trialDir,'trial.mat'));
%                             tempData = trial.getData(outputParams);
%                             if (~isempty(tempData))
%                                 tempData.trialDir = trialDir;
%                                 
%                                 if (isempty(data(end).trial))
%                                     data(end).trial = tempData;
%                                 else
%                                     data(end).trial(end+1) = tempData;
%                                 end
%                             end
%                         end
%                     end
%                 end
%                 %data = machedEvals;
%                 
%             end
%         end
%            
%     end
%     
%     methods(Static)
%         function newEvaluation = getMergeOf(evaluations, numIterations, numTrials)
%             parameters = evaluations(1).parameters;
%             values = evaluations(1).values;
%             for evalIdx = 2:numel(evaluations)
%                 newParameters = union(parameters, evaluations(evalIdx).parameters,'stable');
%                 NValues = size(values,1);
%                 NNewValues = size(evaluations(evalIdx).values,1);
%                 
%                 newValues = repmat({Experiments.EvaluationParameter.DEFAULT},NValues+NNewValues,numel(newParameters));
%                 
%                 [~, idx] = ismember(parameters,newParameters);
%                 newValues(1:NValues,idx) = values;
%                 [~, idx] = ismember(evaluations(evalIdx).parameters,newParameters);
%                 newValues(NValues+1:end,idx) = evaluations(evalIdx).values;
%                 
%                 parameters = newParameters;
%                 values = newValues;
%                 
%             end
%             
%             
%             if(~exist('numIterations','var') || isempty(numIterations))
%                 numIterations = max([evaluations.numIterations]);
%             end
%             
%             if(~exist('numTrials','var') || isempty(numTrials))
%                 numTrials = max([evaluations.numTrials]);
%             end
%             
%             newEvaluation = Experiments.Evaluation(parameters, values, numIterations, numTrials);
%         end
%         
%         function newEvaluation = getUnionOf(evaluations, numIterations, numTrials)
%             parameters = evaluations(1).parameters;
%             values = evaluations(1).values;
%             for evalIdx = 2:numel(evaluations)
%                 if(isempty(intersect(parameters,evaluations(evalIdx).parameters)))
%                     parameters = [parameters, evaluations(evalIdx).parameters];
%                 else
%                     error('Redundant parameter');
%                 end
%                 
%                 if(size(values,1) == size(evaluations(evalIdx).values,1))
%                     values = [values, evaluations(evalIdx).values];
%                 else
%                     error('Inconsistent number of values');
%                 end
%             end
%             
%             if(~exist('numIterations','var') || isempty(numIterations))
%                 numIterations = max([evaluations.numIterations]);
%             end
%             
%             if(~exist('numTrials','var') || isempty(numTrials))
%                 numTrials = max([evaluations.numTrials]);
%             end
%             
%             newEvaluation = Experiments.Evaluation(parameters, values, numIterations, numTrials);
%         end
%         
%         function newEvaluation = getCartesianProductOf(evaluations, numIterations, numTrials)
%             parameters = evaluations(1).parameters;
%             values = evaluations(1).values;
%             
%             for evalIdx = 2:numel(evaluations)
%                 if(isempty(intersect(parameters,evaluations(evalIdx).parameters)))
%                     parameters = [parameters, evaluations(evalIdx).parameters];
%                 else
%                     error('Redundant parameters');
%                 end
%                 
%                 [idx1 idx2] = ndgrid(1:size(values,1),1:size(evaluations(evalIdx).values,1));
%                 values = [values(idx1(:),:), evaluations(evalIdx).values(idx2(:),:) ];
%             end
%             
%             if(~exist('numIterations','var') || isempty(numIterations))
%                 numIterations = max([evaluations.numIterations]);
%             end
%             
%             if(~exist('numTrials','var') || isempty(numTrials))
%                 numTrials = max([evaluations.numTrials]);
%             end
%             
%             newEvaluation = Experiments.Evaluation(parameters, values, numIterations, numTrials);
%         end
%         
%         
%     end
%     
%     methods(Static,Access=public)
%         function uniqueValues = getUniqueValues(values)
%             uniqueValues = cell(0,size(values,2));
%             NValues = size(values,1);
%             for idx1 = 1:NValues
%                 idx2 = idx1+1;
%                 while((idx2 <= NValues) && ~isequal(values(idx1,:),values(idx2,:)))
%                     idx2 = idx2+1;
%                 end
%                 if(idx2 > NValues)
%                     uniqueValues = [uniqueValues; values(idx1,:)];
%                 end
%             end
%         end
%         
%         function indices = containsValue(givenValues,checkValues)
%             if(~iscell(givenValues))
%                 givenValues = {givenValues};
%             end
%             if(~iscell(checkValues))
%                 checkValues = {checkValues};
%             end
%             indices = false(size(givenValues));
%             for givenIdx = 1:numel(indices)
%                 checkIdx = 1;
%                 while(~indices(givenIdx) && (checkIdx <= numel(checkValues)))
%                     indices(givenIdx) = isequal(givenValues{givenIdx},checkValues{checkIdx});
%                     checkIdx = checkIdx+1;
%                 end
%             end
%         end
%    end
    end
end

