classdef LearningScenario < Common.IASObject
    
    properties (SetAccess=protected)
        dataManager;
        
        evalCriterion;
        
        samplers;
        
        learners;
        
        deletionStrategies;
        
        newDataObjects;
        
        initObjects;
        
        printLearnerMessages = true;
        
        dataPreprocessorFunctions;
        
        initialDataPreprocessors;
        initialSamplers
        initialLearners
    end
    
    methods
        %%
        function obj = LearningScenario(dataManager, evalCriterion, sampler)
            obj = obj@Common.IASObject();
            
            obj.evalCriterion = evalCriterion;
            obj.samplers{1} = sampler;
            obj.dataManager = dataManager;
            
            obj.addDeletionStrategy(LearningScenario.MaxSamplesDeletionStrategy());
        end
        
        function [] = addInitObject(obj, initObject)
            if (~isempty(initObject))
                if (isempty(obj.initObjects))
                    obj.initObjects = {initObject};
                else
                    obj.initObjects{end + 1} = initObject;
                end
            end
        end
        
        function [] = addDataPreprocessor(obj, dataPreprocessor, addBeginning)            
            if (~exist('addBeginning', 'var'))
                addBeginning = false;
            end
            
            if (isempty(obj.dataPreprocessorFunctions))
                obj.dataPreprocessorFunctions = {dataPreprocessor};
            else
                if (addBeginning)
                   obj.dataPreprocessorFunctions = [{dataPreprocessor}, obj.dataPreprocessorFunctions];
                else                
                   obj.dataPreprocessorFunctions{end + 1} = dataPreprocessor;
                end
            end
        end
        
        function [] = addDataPreprocessorBeforePreprocessor(obj, dataPreprocessor, preProcessorBefore)            
            
            index = 1; 
            while (index <= length(obj.dataPreprocessorFunctions) && obj.dataPreprocessorFunctions{index} ~= preProcessorBefore)
               index = index + 1;
            end
            if (index > length(obj.dataPreprocessorFunctions))
                error('pst::DataPreProcessor for adding new DataPreprocessor not found\n')
            end
            obj.dataPreprocessorFunctions = {obj.dataPreprocessorFunctions{1:index-1}, dataPreprocessor, obj.dataPreprocessorFunctions{index:end}};            
        end
        
        function [] = addInitialDataPreprocessor(obj, dataPreprocessor)            
            if (isempty(obj.initialDataPreprocessors))
                obj.initialDataPreprocessors = {dataPreprocessor};
            else
                obj.initialDataPreprocessors{end + 1} = dataPreprocessor;
            end
        end
        
        function [] = initAllObjects(obj)
            obj.dataManager.finalizeDataManager();
            obj.newDataObjects = obj.dataManager.getDataObject(0);
            for i = 2:length(obj.samplers)
                obj.newDataObjects(i) = obj.dataManager.getDataObject(0);
            end
            
            for i = 1:length(obj.initObjects)
                obj.initObjects{i}.initObject();
            end
        end
        
        function [newData] = getNewDataObject(obj, index)
            newData = obj.newDataObjects(index);
        end
        
        function [newSampleIndices] = createSamples(obj, data, iteration)
            if (iteration > 0)                
                for i = 1:length(obj.samplers)
                    obj.samplers{i}.setSamplerIteration(iteration);
                    %obj.newDataObjects(i).resetFeatureTags();
                    obj.samplers{i}.createSamples(obj.newDataObjects(i));

                    if (obj.samplers{i}.appendNewSamples())
                        data.mergeData(obj.newDataObjects(i));
                        newSampleIndices = [false(data.getNumElementsForDepth(1),1); true(obj.newDataObjects(i).getNumElementsForDepth(1), 1)];
                    else
                        data.mergeData(obj.newDataObjects(i), false);
                        newSampleIndices = [true(obj.newDataObjects(i).getNumElementsForDepth(1), 1); false(data.getNumElementsForDepth(1),1)];
                    end

                    for j = 1:length(obj.learners)
                        obj.learners{j}.addedData(data, newSampleIndices);
                    end
                end
            else
                 for i = 1:length(obj.initialSamplers)
                    obj.initialSamplers{i}.setSamplerIteration(iteration);
                    
                    newData = obj.dataManager.getDataObject(0);
                    obj.initialSamplers{i}.createSamples(newData);

                    if (obj.samplers{i}.appendNewSamples())
                        data.mergeData(newData);
                        newSampleIndices = [false(data.getNumElementsForDepth(1),1); true(obj.newDataObjects(i).getNumElementsForDepth(1), 1)];
                    else
                        data.mergeData(newData, false);
                        newSampleIndices = [true(obj.newDataObjects(i).getNumElementsForDepth(1), 1); false(data.getNumElementsForDepth(1),1)];
                    end

                    for j = 1:length(obj.learners)
                        obj.learners{j}.addedData(data, newSampleIndices);
                    end
                end
            end
        end
        
        function [] = addSampler(obj, sampler)
            if (isempty(obj.samplers))
                obj.samplers{1} =  sampler;
            else
                obj.samplers{end + 1} =  sampler;
                
            end
        end
        
        function [] = addInitialSampler(obj, sampler)
            if (isempty(obj.initialSamplers))
                obj.initialSamplers{1} =  sampler;
            else
                obj.initialSamplers{end + 1} =  sampler;
                
            end
        end
        
        function [] = addLearner(obj, learner)
            if (isempty(obj.learners))
                obj.learners{1} =  learner;
            else
                obj.learners{end + 1} =  learner;
            end
%             obj.addDataPreprocessor(learner);
        end
        
        function [] = addInitialLearner(obj, learner)
            if (isempty(obj.initialLearners))
                obj.initialLearners{1} =  learner;
            else
                obj.initialLearners{end + 1} =  learner;
            end
%             obj.addInitialDataPreprocessor(learner);
        end
        
        function [] = addDeletionStrategy(obj, deletionStrategy)
            if (isempty(obj.deletionStrategies))
                obj.deletionStrategies{1} =  deletionStrategy;
            else
                obj.deletionStrategies{end + 1} =  deletionStrategy;
            end
        end
        
        function [] = deleteSamples(obj, data, beforeLearning)
            for j = 1:length(obj.deletionStrategies)
                if (strcmp(beforeLearning, 'beforeLearning'))
                    keepIndices = obj.deletionStrategies{j}.getIndicesToKeepBeforeLearning(data);
                else
                    keepIndices = obj.deletionStrategies{j}.getIndicesToKeepAfterLearning(data);
                end
                if (~isempty(keepIndices))
                    for i = 1:length(obj.learners)
                        obj.learners{i}.deletedData(data, keepIndices);
                    end

                    data.deleteData(keepIndices);
                end
            end
        end
        
        %%
        function [] = learnScenario(obj, trial)
                        
            
            if(trial.iterIdx == 1)
                rng(trial.rngState); 
                
                obj.initAllObjects();
                data = obj.dataManager.getDataObject(0);
                
               
                obj.createSamples(data, 0);
                
                for i = 1:length(obj.initialDataPreprocessors)
                    obj.initialDataPreprocessors{i}.setIteration(0);
                    if (i == 1)
                        data = obj.initialDataPreprocessors{i}.preprocessData(data);
                    else
                        data = obj.initialDataPreprocessors{i}.preprocessData(data);
                    end
                end
                
                for i = 1:length(obj.initialLearners)
                    obj.initialLearners{i}.updateModel(data);
                end
                
                if (isprop(trial , 'resetInitialData') && trial.resetInitialData)  %%LOOK HERE
                    data = obj.dataManager.getDataObject(0);
                end
            else
                data = obj.dataManager.getDataObject(0);
                data.copyValuesFromDataStructure(trial.data)
                %Common.Settings().takeParametersFromTrial(trial)
            end
            
            %I dont know why this is here, for me it should be at the
            %start.
            if(trial.iterIdx == 1)
%                 rng(trial.rngState);            
                obj.evalCriterion.evaluate(trial,'preLoop');
            end
            
            dataCollection = Data.DataCollection(data);
            trialTime = tic;
            % START ITERATING
            while(~trial.isFinished())
                obj.evalCriterion.evaluate(trial,'startLoop');
                
                timeLearnScenario = tic;
                
                timeGetRealData = tic;
                
                obj.createSamples(data, trial.iterIdx);
                
                timeGetRealData = toc(timeGetRealData);
                msg = 'Sampling real data took:';
                fprintf('%50s %.3g seconds\n',msg, timeGetRealData);
                
                obj.deleteSamples(data, 'beforeLearning');
                
                % Preprocess Data
                for i = 1:length(obj.dataPreprocessorFunctions)
                    obj.dataPreprocessorFunctions{i}.setIteration(trial.iterIdx);
                    obj.dataPreprocessorFunctions{i}.preprocessDataCollection(dataCollection);
                end
                
                obj.evalCriterion.evaluate(trial,'afterPreProc');
                
                % Update all Learners
                for i = 1:length(obj.learners)
                    obj.learners{i}.setIteration(trial.iterIdx);
                    obj.learners{i}.updateModelCollection(dataCollection);
                end
                
                timeLearnScenario = toc(timeLearnScenario);
                msg = 'Learning the Scenario took:';
                fprintf('%50s %.3g seconds\n', msg, timeLearnScenario);
                
                tmpTrialTime = toc(trialTime);
                msg = 'So far the trial took:';
                fprintf('%50s %.3g seconds\n', msg, tmpTrialTime);
                
                obj.evalCriterion.evaluate(trial,'endLoop');
                
                obj.printMessage(trial, data)
                
                trial.store('rngState',rng());
                obj.evalCriterion.nextIteration(trial, data);
                
                obj.deleteSamples(data, 'afterLearning');
                
            end %for iter
            obj.evalCriterion.evaluate(trial,'postLoop');
        end
        
        
        function printMessage(obj, trial , data)
            fprintf('%50s, Trial %d\n', trial.trialDir, trial.index);
            
            msg = 'Iteration:';
            fprintf('%50s %d\n', msg, trial.iterIdx);
            msg = 'NumSamples:';
            fprintf('%50s %d\n', msg, data.getNumElements());
%             if (data.isDataEntry('returns'))
%                 fprintf('Average Reward: %f\n', mean(data.getDataEntry('returns')));
%             end
            
            
            %             numSamplesEff = sum(data.sampleWeighting) / max(data.sampleWeighting) / (obj.numTimeSteps + 1);
            %             if(isprop(trial,'avgRewardVirt'))
            %                 rewardStr = sprintf('Reward[real|virt] >>> %f | %f <<<',trial.avgRewardReal(trial.iterIdx),trial.avgRewardVirt(trial.iterIdx));
            %             else
            %                 rewardStr = sprintf('Reward[real] >>> %f <<<',trial.avgRewardReal(trial.iterIdx));
            %             end
            %
            %             fprintf('\nIteration %d : %s, Effective Number of Samples: %f\n', trial.iterIdx, rewardStr, numSamplesEff);
            %             if (obj.printRewards)
            %                 for i = 1:totalSamples
            %                     fprintf('Reward %d : %f\n', i, data.reward(end - totalSamples +  i));
            %                 end
            %             end
            
            %         if (obj.printEvalCriterions)
            %           for i = 1:length(obj.evalCriterions)
            %             fprintf('%s : %f\n', obj.evalCriterionsNames{i}, results.(obj.evalCriterionsNames{i})(iter,1));
            %           end
            %         end
            
            if (obj.printLearnerMessages)
                for i = 1:length(obj.learners)
                    obj.learners{i}.printMessage(data);
                end
            end
            
            fprintf('__________________________________________________________________________\n\n');
            
            % toogle diary twice
            % (on,off) if it was not active
            % (off,on) is it was active, so diary flushes to the log file.
            diary; diary;
        end
        
    end
    
end % classdef
