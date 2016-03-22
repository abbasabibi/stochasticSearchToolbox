classdef Experiment < handle;
    
    properties(Constant)
        root = '+Experiments/data';
        
    end
    
    properties(SetAccess=protected)
        category;
          
        evaluations = {};
        evaluationCollections = {};
        nodes = {};
        
        defaultTrial;
        defaultSettings

        user;
        
        expId = [];
        experimentId = -1;
        
        evaluationIndexMap = false(100,1);
        
        trialToEvaluationMap
        trialIndexToDirectoryMap
        
        clusterJobs = {};
        
        taskName
    end
    
    properties
        path;
        experimentPath
    end
    
    methods (Static)       
        
        function [experiment] = getByPath(path)
            fileName = fullfile(path, 'experiment.mat');
            load(fileName);
        end
        
        function [experiment] = loadFromDataBase(category, experimentID)
            path = fullfile(Experiments.Experiment.root, category, obj.taskName);
           
            expFileName = fullfile(path, sprintf('settings%03d', experimentID), 'experiment.mat');
                    
            load(expFileName);
        end
        
        
        function [experiment] = addToDataBase(newExperiment)
            obj = newExperiment;
            experiment = obj;
            [st, msg, msgId] = mkdir(obj.path);
            d = dir(obj.path);
            isub = [d(:).isdir];
            nameFolds = {d(isub).name}';
            
            experimentId = -1;
            experimentIdVec = true(100,1);
            for i = 1:length(nameFolds)
                if (length(nameFolds{i}) > 7 && strcmp(nameFolds{i}(1:8), 'settings'))
                    lId = sscanf(nameFolds{i}, 'settings%03d');
                    expFileName = fullfile(obj.path, sprintf('settings%03d', lId), 'experiment.mat');
                    try
                        load(expFileName);
                        
                        [sameDefaultSettings, differentParameters] = obj.defaultSettings.isSameSettings(experiment.defaultSettings);
                        fprintf('Checking Experiment ID %d: ', lId);
                        if (sameDefaultSettings)
                            experimentId = lId;
                            fprintf('Found same experiment\n');
                            break;
                        else
                            experimentIdVec(lId) = false;
                            fprintf('Different Settings, differences are in');
                            differentParameters
                        end
                    catch e
                        experimentId = lId;
                        fprintf('Found same experiment\n');
                        break;
                    end
                            
                end
            end
            if (experimentId == -1)
                experimentId = find(experimentIdVec, 1);
                fprintf('Create New Experiment with ID %d\n', experimentId);
            end            
            obj.experimentId = experimentId;
            obj.experimentPath = fullfile(obj.path, sprintf('settings%03d', obj.experimentId));
            [st, msg, msgId] = mkdir(obj.experimentPath);
           
           
            %Recreate default trial with new default settings
            obj.defaultTrial = obj.createTrial(obj.defaultSettings, obj.experimentPath, 0);            
            %obj.defaultSettings = obj.defaultTrial.settings;
            obj.defaultTrial.storeTrial();

            
            obj.storeExperiment();
        end
    end
    
    methods
        
             
        function obj = Experiment(category, taskName)
            
            obj = obj@handle();
            obj.taskName = taskName;
            obj.path = fullfile(Experiments.Experiment.root, category, taskName);
            obj.category = category;            
                        
            obj.trialToEvaluationMap = containers.Map('KeyType', 'int64', 'ValueType', 'any');
            obj.trialIndexToDirectoryMap = containers.Map('KeyType', 'int64', 'ValueType', 'any');
            
            [~ ,obj.user] = system('id -un');
            obj.user = strtrim(obj.user);                        
        end
        
         
          
        function [] = startDefaultTrial(obj)
            obj.defaultTrial.start();
        end        
                        
        function [trialId] = registerTrial(obj, evaluation, trialDir)
            if (obj.trialToEvaluationMap.isempty())
                index = 1;
            else            
                index = max(cell2mat(obj.trialToEvaluationMap.keys)) + 1;
            end
            
            obj.trialToEvaluationMap(index) = evaluation;
            trialId = length(obj.trialToEvaluationMap);
            obj.trialIndexToDirectoryMap(index) = trialDir;
        end
        
        function [evaluation] = getEvaluation(obj, evalNumber)
            evaluation = obj.evaluation(evalNumber);
        end
               
        function [index] = getEvaluationIndex(obj, evaluation)
            index = -1;
            for i = 1:length(obj.evaluation)
                if (strcmp(obj.evaluation(i).evaluationName, evaluation.evaluationName) == 1)
                    index = i;
                end
            end
        end
        
        
        function resetTrials(obj)
            for i = 1:length(obj.evaluations)
                obj.evaluations{i}.resetTrials();
            end
        end
        
        function prepareDirectories(obj)
            for i = 1:length(obj.evaluations)
                obj.createDirectories(obj.evaluations{i});
            end
        end
        
        
        function [] = changePath(obj, path)
            obj.path = path;
        end
        
        function data = getTrialData(obj, evaluationNumber)
            
            if (~exist('evaluationNumber', 'var'))
                evaluationNumber = 1;
            end
            
            data = obj.evaluation(evaluationNumber).getTrialData(obj.path);

        end
        
        function [] = deleteExperiment(obj)
            system(sprintf('rm -rf %s', obj.path));
        end
        
        function [] = storeExperiment(obj)
            experiment = obj;
            save(fullfile(obj.experimentPath,'experiment'),'experiment','-v7.3');
        end         
        
        
        
        function [evaluation] = addEvaluation(obj, parameterNames, parameterValues, numTrials)
            % This is onle for a single evaluation. Please use evaluation
            % collections for multiple ones
            assert(size(parameterValues,1) == 1);
            
            evaluationSettings = obj.defaultSettings.clone();
            evaluationSettings.setProperties(parameterNames, parameterValues);
            evaluationIndex = -1;
            for i = 1:length(obj.evaluations)
                if (obj.evaluations{i}.settings.isSameSettings(evaluationSettings))
                    evaluationIndex = i;
                    evaluation = obj.evaluations{i};
                    fprintf('Evaluation found with same settings: %d\n', evaluationIndex);
                    return;
                end
            end
            
            if (evaluationIndex < 0)
                evaluationIndex = find(~obj.evaluationIndexMap, 1);
                obj.evaluationIndexMap(evaluationIndex) = evaluationIndex;
            end
            evaluation = Experiments.Evaluation(obj, evaluationIndex, evaluationSettings, parameterNames, parameterValues, numTrials);
            obj.evaluations{evaluationIndex} = evaluation;
            obj.evaluations{evaluationIndex}.createDirectories(true);
            obj.storeExperiment();
        end
        
        function [evaluationCollection] = addEvaluationCollection(obj, parameterNames, parameterValues, numTrials)
            for i = 1:size(parameterValues,1)
                evaluations{i} = obj.addEvaluation(parameterNames, {parameterValues{i,:}}, numTrials);
            end
            evaluationCollection = Experiments.EvaluationCollection(obj, evaluations, parameterNames, parameterValues);
            obj.evaluationCollections{end + 1} = evaluationCollection;
            obj.storeExperiment();
        end
        
        function [trial] = loadTrialFromID(obj, trialID)
            trialName =  fullfile(obj.trialIndexToDirectoryMap(trialID), 'trial.mat');
            
            load(trialName);
        end
        
        function [numTrials] = getNumTrials(obj)
            numTrials = obj.trialIndexToDirectoryMap.size();
        end
                
        function [] = startLocal(obj, trialIndices)
            if (~exist('trialIndices', 'var'))
                trialIndices = obj.trialIndexToDirectoryMap.keys;
                trialIndices = cell2mat(trialIndices );
            end
            
            for i = 1:length(trialIndices)
                fprintf('Starting Trial %d locally\n', trialIndices(i));
                trial = loadTrialFromID(obj, trialIndices(i));
                trial.start();
                
            end
        end
        
        function [keys] = getTrialIDs(obj)
            keys = obj.trialIndexToDirectoryMap.keys;
        end
        
        function startBatch(obj, varargin)
            obj.startBatchTrials(obj.getTrialIDs(), varargin{:});
        end
        
        function startBatchTrials(obj, trialIDs, numParallelJobs, jobsPerNode, computationTime)
            
            if (~exist('jobsPerNode', 'var'))
                jobsPerNode = 16;
            end
            if (~exist('computationTime', 'var'))
                computationTime = '24:00';
            end
            if (isa(computationTime, 'double'))
                computationTime = sprintf('%d:00', computationTime);
            end
            
            if (~exist('numParallelJobs', 'var'))
                numParallelJobs = numel(trialIDs);
            end
            
            try                
                obj.clusterJobs{end + 1} = cell2mat(trialIDs);
                clusterJobID = length(obj.clusterJobs);
                obj.storeExperiment();
                
                LSF = obj.createLSFFullNode(clusterJobID, numParallelJobs, jobsPerNode, computationTime);
                [st, msg] = system(sprintf('bsub < %s',LSF),'-echo');
                
                if(st ~= 0)
                    warning('pst:experiment: No LSF found... starting locally\n');
                    obj.startLocal(trialIDs);
                end
            catch E
                warning('pst:experiment: No LSF found... starting locally\n');
                obj.startLocal(trialIDs);
            end
        end
        
        
        function LSF = createLSFFullNode(obj, clusterJobID, numParallelJobs, jobsPerNode, computationTime)
            LSF = sprintf('%s/jobs.lsf',obj.experimentPath);
            
            experimentId = sprintf('IAS_%s_%s_%s', obj.category, obj.taskName);
            
            fidIn = fopen('+Experiments/template.lsf','r');
            fidOut = fopen(LSF,'w');
            
            tline = fgets(fidIn);
            numJobs = numel(obj.clusterJobs{clusterJobID});
            numJobsLSF = ceil(numJobs / jobsPerNode);
            numParallelJobs = ceil(numParallelJobs / jobsPerNode);
            while ischar(tline)
                tline = strrep(tline, '§§experimentName§§', experimentId);
                tline = strrep(tline, '§§computationTime§§', computationTime);
                tline = strrep(tline, '§§experimentPath§§', obj.experimentPath);
                tline = strrep(tline, '§§numJobs§§', sprintf('%d',numJobsLSF));
                tline = strrep(tline, '§§numParallelJobs§§', sprintf('%d',numParallelJobs));
                tline = strrep(tline, '§§jobsPerNode§§', sprintf('%d',jobsPerNode));
                tline = strrep(tline, '§§clusterJobID§§', sprintf('%d',clusterJobID));
                
                if (length(tline) > 6 && strcmp(tline(1:6), 'matlab'))
                    for i = 1:jobsPerNode
                        newLine = strrep(tline, '§§jobOffset§§', sprintf('%d',i));
                        fprintf(fidOut,'%s',newLine);
                    end
                else
                    fprintf(fidOut,'%s',tline);
                end
                tline = fgets(fidIn);
            end
            
            fclose(fidOut);
            fclose(fidIn);
            
        end
        
        function [] = startCluster(obj, clusterJobID, jobID)
            trialIndices = obj.clusterJobs{clusterJobID};
            fprintf('Starting Trial %d on the cluster \n', trialIndices(jobID));
            trial = obj.loadTrialFromID(trialIndices(jobID));
            trial.start();
        end
        
        
        function [] = setDefaultParameter(obj, parameterName, parameterValue)
            if (strcmp(parameterName(1:9), 'settings.') == 0)
                parameterName = parameterName(10:end);
            end
            obj.defaultSettings.(parameterName) = parameterValue;
        end
        
        
        
    end

    methods (Abstract)
        [trial] = createTrial(obj, settings, evalPath, trialIdx);                     
    end
    
end

