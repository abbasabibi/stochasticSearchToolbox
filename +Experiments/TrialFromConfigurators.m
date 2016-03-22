classdef TrialFromConfigurators < Experiments.Trial
    
    properties
        iterIdx = 1;
        numIterations;

        scenario;
        dataManager;
        
        
        preprocessors = {};
        iterGroupSize = 10;
        saveIterationModulo = 10;
    end
      
    
    methods
        function obj = TrialFromConfigurators(settingsEval, evalDir, trialIdx, configurators, evalCriterion, numIterations)
            obj = obj@Experiments.Trial(evalDir,  trialIdx);

            obj.saveIterationModulo = evalCriterion.saveIterationModulo;
            
            obj.numIterations = numIterations;
            trial = obj;
            for i = 1:length(configurators)
                configurators{i}.preConfigureTrial(trial);
            end
            
            trial.configure(settingsEval);
            
            for i = 1:length(configurators)
                configurators{i}.setupSampler(trial);
            end
            
            for i = 1:length(configurators)
                configurators{i}.postConfigureTrial(trial);
            end
            
            for i = 1:length(configurators)
                configurators{i}.addDefaultCriteria(trial, evalCriterion);
            end
            
            for i = 1:length(configurators)
                configurators{i}.registerSamplers(trial);
            end
            
            for i = 1:length(configurators)
                configurators{i}.applyParameterSetters(trial);
            end
            
            trial.scenario = LearningScenario.LearningScenario(trial.dataManager, evalCriterion, trial.sampler);
            
            for i = 1:length(configurators)
                configurators{i}.addPreprocessorsToTrial('beginning', trial);
            end
            
            for i = 1:length(configurators)
                configurators{i}.setupScenarioForLearners(trial);
            end
            
            for i = 1:length(configurators)
                configurators{i}.addPreprocessorsToTrial('end', trial);
            end
                                
        
        end
        
      
        
        
        function [] = addPreprocessor(obj, preprocessor, isBeginning)
            if (isBeginning)
                obj.preprocessors = {preprocessor, obj.preprocessors{:}}; 
            else
                
                obj.preprocessors = {obj.preprocessors{:}, preprocessor};
            end
        end            
        
               
        
        function stored = storeTrialInFile(obj,fileName, overwrite)
            if (~exist('overwrite', 'var'))
                overwrite = true;
            end
            trial = obj;
            if (trial.iterIdx == 1 || mod(trial.iterIdx, obj.saveIterationModulo) == 0)
                iterName = sprintf('iter%05d',trial.iterIdx);
                tmp.(iterName) = struct();
                for name = trial.storePerIteration
                    tmp.(iterName).(name{1}) = trial.(name{1});
                end
                if(trial.iterGroupSize == 1)
                    filename = fullfile(trial.trialDir,iterName);
                    save(filename,'-struct','tmp');
                    if(isunix)
                        system(sprintf('chmod 775 %s.mat',filename));
                    end
                elseif(trial.iterGroupSize > 1)
                    fromIter = floor((trial.iterIdx-1)/trial.iterGroupSize)*trial.iterGroupSize+1;
                    toIter = floor((trial.iterIdx-1)/trial.iterGroupSize+1)*trial.iterGroupSize;
                    filename = fullfile(trial.trialDir,sprintf('iter_%05d_%05d',fromIter,toIter));
                    matObj = matfile(filename,'Writable',true);
                    matObj.(iterName) = tmp.(iterName);
                    if(isunix)
                        system(sprintf('chmod 755 %s.mat',filename));
                    end
                end                                                
            end
            
            stored = obj.storeTrialInFile@Experiments.Trial(fileName, overwrite);
        end
        
        function [] = startInternal(obj)
            obj.scenario.learnScenario(obj);
        end
    end
    
end

