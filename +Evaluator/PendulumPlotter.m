classdef PendulumPlotter < Evaluator.Evaluator
   
    properties
        featureNameValue 
        featureNameGating
        repsLearner
        dataManager
        sampler
        plotData        = [];
        VResolution     = 50;
    end
    
  
    methods
        function [obj] = PendulumPlotter (repsLearner, dataManager, featureNameValue, featureNameGating, sampler)
            obj = obj@Evaluator.Evaluator('plot', {'endLoop'}, Experiments.StoringType.ACCUMULATE);    
            obj.featureNameValue  = featureNameValue;
            obj.featureNameGating = featureNameGating;
            obj.repsLearner     = repsLearner;
            obj.dataManager     = dataManager;
            obj.sampler         = sampler;
            %             obj.plotData        = obj.dataManager.getDataObject(obj.VResolution^2);
            %             obj.plotData        = [];
            if( isprop(obj.repsLearner.policyLearner, 'gatingLearner') )
                obj.featureNameGating = obj.repsLearner.policyLearner.functionApproximator.gating.inputVariables{1};
            else
                obj.featureNameGating = obj.repsLearner.policyLearner.mixtureModel.gating.inputVariables{1};
            end
        end                        
        
        %%
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if(usejava('jvm') && usejava('desktop') )
                numRollouts =  newData.dataStructure.numElements;
                numRows     = ceil(sqrt(numRollouts));
                numCols     = ceil(numRollouts / numRows);
                
                

                %                 figure(19)
%                 clf
%                subplot(numRows,numCols,1)

%                 
%                 for i =1 :  newData.dataStructure.numElements
%                     subplot(numRows,numCols,i);
%                     hold on
%                     tmp = newData.getDataEntry('states', i);
%                     angle = tmp(:,1);
%                     colorArray = bsxfun(@times, linspace(0.95, 0.1, size(angle,1))', [1 1 1]);
%                     scatter(-sin(angle),cos(angle),100, colorArray, 'filled'); %traj
%                     axis([-1 1 -1 1])
%                     
%                 end
                
                
%                 figure(20)
%                 clf
%                 for i =1 :  newData.dataStructure.numElements
%                     subplot(numRows,numCols,i);
%                     hold on
%                     torques = newData.getDataEntry('actions', i);
%                     plot(torques);
%                 end
                
                
%                 figure(21)
%                 clf
%                 for i =1 :  newData.dataStructure.numElements
%                     subplot(numRows,numCols,i);
%                     hold on
%                     states = newData.getDataEntry('states', i);
%                     desStates = newData.getDataEntry('parameters', i);
%                     
%                     
%                     plot(states(:,1), states(:,2), 'bo');
%                     plot(desStates(:,1), desStates(:,2), 'ro');
%                 end
%                 
                           
                if( isprop(trial, 'policyLearner') )
                    learner     = trial.policyLearner;
                    inputVar    = trial.policyLearner.inputVariables{1};
                else if( isprop(trial, 'PolicyLearner') )
                        learner     = trial.PolicyLearner;
                        inputVar = trial.PolicyLearner.inputVariables{1};
                        if(iscell(inputVar))
                            inputVar = inputVar{1};
                        end
                    end
                end
                

                angleRange = pi;
                [x, y] = meshgrid( linspace(-angleRange, angleRange, obj.VResolution), linspace(-30, 30, obj.VResolution));
                x = x';
                y = y';
%                 contexts        = newData.getDataEntry('contexts');
                contextVec      = [x(:), y(:)];
                if(isempty(obj.plotData) ||  obj.plotData.getNumElements ~= size(contextVec,1) )
                    obj.plotData    = obj.dataManager.getDataObject(size(contextVec,1));
                end
                obj.plotData.setDataEntry(inputVar, contextVec);
                
%                 figure(22)
%                 clf
%                 contextFeatures = obj.plotData.getDataEntry(obj.featureNameValue); %('contextFeatures');
%                 V               = contextFeatures * obj.repsLearner.theta;
% %                 V               = V(size(contexts,1)+1 : end);
%                 VMat            = reshape(V, obj.VResolution, obj.VResolution);
%                 VMat            = VMat';
%                 imagesc([-angleRange, angleRange],[-30, 30],VMat);
%                 set(gca,'YDir','normal');
%                 title('Value Function');
%                 colorbar
%                 pause(0.1)
                
                figure(23)
                clf
                V = newData.getDataEntry(obj.featureNameValue) *  obj.repsLearner.theta ;
                contexts = newData.getDataEntry(inputVar);
                scatter(contexts(:,1), contexts(:,2), 100, V, 'filled');
                colorbar
                
                figure(24)
                clf
                Plotter.PlotterData.plotTrajectories(newData,'jointPositions',1,24);
                
%                 figure(25)
%                 clf
%                 Plotter.PlotterData.plotTrajectories(newData,'actions',1,25);

%                 figure(26)
%                 clf
%                 Plotter.PlotterData.plotTrajectories(newData,'parameters',1,26);
                
                figure(28)
                clf
                resps = learner.functionApproximator.gating.getItemProbabilities([],obj.plotData.getDataEntry(obj.featureNameGating));
                [~, optionIdx] = max(resps,[],2);
                optionList = unique(optionIdx);
                policyExpectation = zeros(size(optionIdx,1),1);
                for i = 1 : length(optionList)
                    option              = optionList(i);
                    sampleSelection     = optionIdx == option;
                    contextsForOption   = contextVec(sampleSelection,:);
                    numSamples          = size(contextsForOption,1);
                    
                    policyExpectation(sampleSelection) =  learner.functionApproximator.options{option}.getExpectation(numSamples, contextsForOption);
                end
                
                policyExpectationMat            = reshape(policyExpectation, obj.VResolution, obj.VResolution);
                policyExpectationMat            = policyExpectationMat';
                imagesc([-angleRange, angleRange],[-30, 30],policyExpectationMat);
                set(gca,'YDir','normal');
                colorbar
                title('Policy');
                pause(0.1)
%                 Plotter.plot2svg(['plots/PolicyIter',num2str(trial.iterIdx),'.svg']);
                
%                 print(['plots/PolicyMatlabIter',num2str(trial.iterIdx)],'-dsvg')


                figure(27)
                clf
                plot(trial.avgReturn);
                %                 plot(trial.rewardEval);
                
                if( isprop(learner.functionApproximator,'terminationMM'))
                    figure(24)
                    clf
                    hold on
                    totalTerminations = 0;
                    for i = 1 : numRollouts
                        terminationsNew     = newData.getDataEntry('terminations',i);
                        contextsNew         = newData.getDataEntry('states',i);
                        terminationsNewIdx  = terminationsNew == 1;
                        totalTerminations   = totalTerminations + sum(terminationsNewIdx);
                        steps               = 1 : length(terminationsNew);
                        plot(contextsNew(:,1));
                        plot(steps(terminationsNewIdx), contextsNew(terminationsNewIdx,1),'r*');
                    end
                    title('OutputData with Terminations');
                    fprintf('terminationRatio = %.3g \n', totalTerminations / size(newData.getDataEntry('terminations'),1));
                    
                    
                    figure(37)
                    title('TerminationPolicies');
                    numOptions = learner.functionApproximator.numOptions;
                    for o = 1 : numOptions
                        subplot(1,numOptions,o);
                        terminationProb = exp(learner.functionApproximator.terminationMM.terminations{o}.getDataProbabilities(...
                            obj.plotData.getDataEntry(learner.functionApproximator.terminationMM.inputVariables{1}), ones(obj.VResolution^2,1)));
                        terminationProb            = reshape(terminationProb, obj.VResolution, obj.VResolution);
                        terminationProb            = terminationProb';
                        imagesc([-angleRange, angleRange],[-30, 30],terminationProb)
                        colorbar
                        set(gca,'YDir','normal');
                    end
                    
                end
                
                
                if( isprop(obj.repsLearner.policyLearner, 'colors') )
                    colors = obj.repsLearner.policyLearner.colors;
                else
                    colors = learner.mixtureModelLearner.colors;
                end
                
                states = newData.getDataEntry('states');
                actions = newData.getDataEntry('actions');
                oIdx = newData.getDataEntry('options');
                figure(11)
                clf
                scatter3(states(:,1), states(:,2), actions, 100, colors(oIdx,:)); 
%                 colorbar
                pause(0.7);
                
            end
            evaluation = 0;
        end
                
    end   
    
end