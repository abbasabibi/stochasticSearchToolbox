classdef MixtureModelLearner < Learner.SupervisedLearner.SupervisedLearner
    
    properties (SetObservable,AbortSet)
        debugPlotting = false;
        debugStateIndices = ':';
        debugActionIndices = ':';
    end
    
    properties (SetAccess=protected)
        mixtureComponentLearner
        gatingLearner
        respName              % Had to add this needed by EM
        colors
        
        additionalInputVariables = {};
    end
    

    
    % Class methods
    methods
        function obj = MixtureModelLearner(dataManager, mixtureModel, mixtureComponentLearner, gatingLearner, respName, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, mixtureModel, varargin{:});
            obj.mixtureComponentLearner = mixtureComponentLearner;
            obj.gatingLearner = gatingLearner;
            
            if(~exist('respName','var'))
                obj.respName = 'outputResponsibilities';
            else
                obj.respName = respName;
            end
            obj.linkProperty('debugPlotting','debugPlottingMM');
            

            depth       = dataManager.getDataEntryDepth(obj.outputVariable);
            subManager  = dataManager.getDataManagerForDepth(depth);
            subManager.addDataEntry(obj.respName, obj.functionApproximator.numOptions);
            
            obj.setAdditionalInputArguments(obj.respName);

            obj.setInputVariablesForLearner(mixtureModel.inputVariables{:}, mixtureModel.gating.inputVariables{:});

        end
        
        
        %%
        function initObject(obj)
            obj.colors = rand(obj.functionApproximator.numOptions,3);
        end
        
        %Had to add options, is that the right way to do it?
        function [] = learnFunction(obj, inputData, inputDataGating, outputData, options, responsibilities, weighting) %resp is not getting passed correctly
            
            if (~exist('weighting', 'var') || isempty(weighting) )
                weighting = ones(size(outputData,1),1);
            end
            
            if(isempty(obj.colors))
                error('initObject for mixtureModelLearner was not called');
            end
            
            %we can't call the update function here because we dont have
            %data anymore
            %             prior = sum(responsibilities,1);
            %             obj.gatingLearner.functionApproximator.setItemProb(log(prior));
            
            obj.gatingLearner.learnFunction(inputDataGating, responsibilities, weighting);
            
            weightedResponsibilities = bsxfun(@times, responsibilities, weighting);
            
            
            %%
            
            %             obj.gatingLearner.learnFunction(inputData, responsibilities, weighting);
            for o = 1 : obj.functionApproximator.numOptions
                if(sum(weightedResponsibilities(:,o)) > 0)
                    obj.mixtureComponentLearner.setFunctionApproximator(obj.functionApproximator.getOption(o)); %this gets an option from the MM and sets it as active for the learner
                    obj.mixtureComponentLearner.learnFunction(inputData, outputData, weightedResponsibilities(:,o) );
                end
            end
            
            obj.plotFunction(inputData, inputDataGating, outputData, options, responsibilities, weighting);
            
        end
        
        function [] = plotFunction(obj, inputData, inputDataGating, outputData, options, responsibilities, weighting)
            debugStates     = inputData(:,obj.debugStateIndices);
            debugActions    = outputData(:,obj.debugActionIndices);
            debugActions    = debugActions(:, 1 : 2 - size(debugStates,2));
            
            %% PLOTTING
            if(obj.debugPlotting &&  (size(debugStates,2) + size(debugActions,2) == 2) && usejava('jvm') && usejava('desktop') )

                data = [debugStates , debugActions];                                
                figure(11);

                clf
                title('Model on Training Data');
                hold on;
                numSamples      = size(data,1);
                mixtureModel    = obj.functionApproximator;
                numOptions      = mixtureModel.numOptions;
                %                 colors          = {'r';'m';'g'};
                
                
                [~, maxResp]    = max(responsibilities,[],2);
                for i = 1 : numSamples
                    %                     plot(data(i,1), data(i,2),[colors{min(maxResp(i),length(colors))},'*']);
                    plot(data(i,1), data(i,2),'o', 'Color',obj.colors(maxResp(i),:),'markerSize',5,'LineWidth',2);
                end
                
                [uniqueList uniqueIdx] = unique(maxResp);
                for i = 1 : length(uniqueIdx)
                    hTemp(i) = plot(data(uniqueIdx(i),1), data(uniqueIdx(i),2),'o', 'Color',obj.colors(maxResp(uniqueIdx(i)),:),'markerSize',5,'LineWidth',5);
                end
                legend(hTemp);
                
                
                for o = 1 : numOptions
                    means(o,:)      = mixtureModel.getOption(o).bias;
                    sigmas{o}       = sqrt(mixtureModel.getOption(o).getCovariance());
                    F{o}            = mixtureModel.getOption(o).weights;
                    %                 plot(mixtureModel.getOption(o).bias(1),mixtureModel.getOption(o).bias(2),'r*')
                    if(size(debugActions,2) ==2)
                        Plotter.Gaussianplot.plotgauss2d(means(o,:)',sigmas{o},obj.colors{o});
                    end
                end
                
                %
                if(size(debugStates,2) == 1 )
                    if(size(debugStates,2) == size(inputData,2) && false)
                        minData = min(debugStates);
                        maxData = max(debugStates);
                        numSamplesState = 1e3;
                        x = linspace(minData, maxData, numSamplesState);
                        xIn = x;
                        
                        newData = obj.dataManager.getDataObject(numSamplesState);
                        newData.setDataEntry(obj.functionApproximator.inputVariables{1}, x');
                        
                    else
                        numSamplesState = size(debugStates,1);
                        x               = debugStates;
                        xIn             = inputData;
                        xInGating       = inputDataGating;
                        newData         = obj.dataManager.getDataObject(numSamplesState);
                        try %ugly, but newData.isDataEntry('statesTag') pretends it exists
                            newData.setDataEntry([obj.functionApproximator.inputVariables{1},'Tag'],1);
                        catch
                        end
                        try
                            newData.setDataEntry([obj.gatingLearner.functionApproximator.inputVariables{1},'Tag'],1)
                        catch
                        end
                        newData.setDataEntry(obj.functionApproximator.inputVariables{1}, xIn);
                        newData.setDataEntry(obj.gatingLearner.functionApproximator.inputVariables{1}, xInGating);
                    end
                    
                    
                    
                    for o = 1 : numOptions
                        %                        plot(x, F{o} * x + means(o,:), [colors{min(o,length(colors))},'--'] );
                        plot(x, (xIn * F{o}')' + means(o,:),'*','Color', obj.colors(o,:) );
                    end
                    
                    
                    figure(2);
                    clf;
                    hold on;
                    title('Gating on Test Data');
                    
                    %                     if(size(debugStates,2) == size(inputDataGating,2) )
                    %
                    %                     else
                    %                     end
                    colorsHat = zeros(numSamplesState, 3);
                    labelHat  = mixtureModel.gating.callDataFunctionOutput('getItemProbabilities', newData);
                    %                     [~, labelMax] = max(labelHat');
                    %
                    %                     for s = 1 : numSamplesState
                    %                         colorsHat(s,labelMax(s)) = 1;
                    %                     end
                    %
                    for o = 1 : numOptions
                        %                         plot(x, labelHat(:,o),[colors{min(o,length(colors))},'*']);
                        plot(x, labelHat(:,o),'*','Color', obj.colors(o,:));
                    end
                    %                     scatter(statesTest(:,1),statesTest(:,2), ones(numSamplesState,1) * 100, colorsHat)
                    
                    
                    figure(3);
                    clf;
                    %                    pos3 = [pos(1)-pos(3)-50, pos(2), pos(3), pos(4)];
                    %                    set(gcf,'Position', pos3);
                    hold on
                    title('Prediction on Test Data');
                    
                    mixtureModel.callDataFunction('sampleFromDistribution', newData);
                    plot(x, newData.getDataEntry(obj.functionApproximator.outputVariable),'*')
                    
                end
                
                
                
                pause(0.05)
            end
        end
    end
    
end
