classdef PlotterEvaluations
    %PLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        
        function [plotMedianQuantile] = plotMedianQuantile(argin)
            persistent plotMQ;
            if exist('argin','var')
                plotMQ = argin;
            end
            if isempty(plotMQ)
                plotMedianQuantile = false;
            else
                plotMedianQuantile = plotMQ;
            end
        end
        
        function [qPercentage] = quantilePercentage(argin)
            persistent quantilePercentage;
            if exist('argin','var')
                quantilePercentage = argin;
            end
            if isempty(quantilePercentage)
                qPercentage = [.25 .75];
            else
                qPercentage = quantilePercentage;
            end
        end
        
        function [fieldData] = extractFieldData(data,field,evalIdx,trialIdx,iterIdx,valueIdx)
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            if(~exist('iterIdx','var'))
                iterIdx = [];
            end
            
            if(~exist('valueIdx','var'))
                valueIdx = [1];
            end
            
            if (~iscell(data))
                data = {data};
            end
            
            fieldCell = {};
            
            maxMatrixSize = [0 0];

            for k = 1:length(evalIdx)
                anEval = data{evalIdx(k)};

                if(isempty(trialIdx))
                    trialIdx = 1:numel(anEval.trials);
                end
                fieldMatrix = NaN(numel(anEval.trials(trialIdx)),1);

                if (isfield(anEval.trials, field))
                   
                    fieldMatrix = NaN(numel(anEval.trials(trialIdx)),max(arrayfun(@(d)numel(d.(field)),anEval.trials(trialIdx))));
                    idx = 1;
                    for aTrial = anEval.trials(trialIdx)
                        %if isempty(iterIdx)
                        iterIdx = 1:size(aTrial.(field),1);
                        %end
                        fieldContent = aTrial.(field)(iterIdx,:);
                        N = numel(fieldContent);
                        fieldMatrix(idx,1:N) = fieldContent(:);
                        idx = idx +1;
                    end
                end
                fieldCell{end+1} = fieldMatrix;
                    
                maxMatrixSize = max([maxMatrixSize ; size(fieldMatrix)],[],1);
            end
            
            fieldData = NaN([numel(fieldCell) maxMatrixSize]);
            
            for eidx = 1:numel(fieldCell)
                fieldData(eidx,1:size(fieldCell{eidx},1),1:size(fieldCell{eidx},2)) = fieldCell{eidx};
            end
            
        end
        
        function [mu, sigma, se, conf] = analyzeData(fieldData)
            mu = permute(Plotter.nanmean(fieldData,2),[1 3 2]);
            sigma = permute(Plotter.nanstd(fieldData,[],2),[1 3 2]);
            n = permute(sum(~isnan(fieldData),2),[1 3 2]);
            se = sigma ./sqrt(n);
            conf = se.*1.96;
        end
        
        function [evaluationData] = filterEvalData(evaluationData, fieldName, threshold)
            for i = 1:length(evaluationData)
                j = 1;
                numFiltered = 0;
                while j <= length(evaluationData(i).trials)
                    if (mean(evaluationData(i).trials(j).(fieldName)(end - 20:end)) < threshold)
                        evaluationData(i).trials(j) = [];
                        numFiltered = numFiltered + 1;
                    else
                        j = j + 1;
                    end
                end
                fprintf('Filtered Trials: %d\n', numFiltered);
            end
        end
        
        
        function [plotDataStruct ] = preparePlotData(evaluationData, xAxis, yDataString, labelProperty, labelGenerator, plotName, useLogTransform, evalIdx, trialIdx, iterIdx, valueIdx)
            if Plotter.PlotterEvaluations.plotMedianQuantile
                [meansYData,stdsYData, allData] = Plotter.PlotterEvaluations.extractMedianQuantileFromData(evaluationData, yDataString,evalIdx,trialIdx,useLogTransform);
            else
                [meansYData,stdsYData, allData] = Plotter.PlotterEvaluations.extractMeanStdFromData(evaluationData, yDataString,evalIdx,trialIdx,useLogTransform);
            end
            
            plotDataStruct = struct();
            
            if(isempty(evalIdx))
                evalIdx = 1:size(meansYData, 1);
            end
            
            if ~exist('iterIdx','var')
                iterIdx = [];
            end
            
            if ~exist('valueIdx','var')
                valueIdx = [];
            end
            
            if (~iscell(evaluationData))
                evaluationData = {evaluationData};
            end
            
            nIter = size(meansYData,2);
            plotDataStruct.allYData = permute(allData, [3, 2 ,1]);
            
            plotDataStruct.meansYData = meansYData;
            plotDataStruct.stdsYData = stdsYData;
            
            plotDataStruct.xLabel = '';
            plotDataStruct.yLabel = yDataString;
            plotDataStruct.plotInterval = 1;
            
            
            if (isempty(evalIdx))
                evalIdx = 1:size(meansYData, 1);
            end
            
            if (nIter == 1 || strcmp(xAxis, 'evaluations'))
                xAxis = 'evaluations';
                evaluationLabelValues = Experiments.Experiment.getSettingFromEvaluationData(evaluationData, labelProperty);
                plotDataStruct.xAxis = [evaluationLabelValues{evalIdx}];
                plotDataStruct.xLabel = labelProperty;
                plotDataStruct.title = labelProperty;
                
            elseif (isempty(xAxis) || strcmp(xAxis, 'iterations'))
                plotDataStruct.xAxis = repmat(1:size(meansYData, 2), size(meansYData, 1), 1);
                plotDataStruct.xLabel = 'Iterations';
            else
                if (ischar(xAxis))
                    if (strcmp(xAxis, 'episodes'))
                        plotDataStruct.xAxis = repmat(1:size(meansYData, 2), size(meansYData, 1), 1);
                        plotDataStruct.xLabel = 'Episodes';
                        for i = 1:size(meansYData, 1)
                            tempValue = Experiments.Experiment.getSettingFromEvaluationData(evaluationData(i), 'settings.numSamplesEpisodes');
                            if (~isempty(tempValue{1}))
                                plotDataStruct.xAxis(i,:) = plotDataStruct.xAxis(i,:) * tempValue{1};
                            else
                                
                                if (isfield(evaluationData(i), 'defaultParameters') && isfield(evaluationData(i).defaultParameters, 'numSamplesEpisode'))
                                    plotDataStruct.xAxis(i,:) = plotDataStruct.xAxis(i,:) * evaluationData(i).defaultParameters.numSamplesEpisodes.value;
                                end
                            end
                        end
                    else
                        plotDataStruct.xAxis = NaN(size(meansYData));
                        for i = 1:size(evalIdx,2)
                            data = evaluationData(evalIdx(i)).trials(1).(xAxis)';
                            plotDataStruct.xAxis(i,1:size(data,2)) = data;
                        end
                        plotDataStruct.xLabel = xAxis;
                    end
                else
                    plotDataStruct.xAxis = xAxis;
                end
            end
            [plotDataStruct.evaluationLabels{1:size(meansYData, 1)}] = deal('unknown');
            
            
            if (~isempty(labelProperty))
                %evaluationLabelValues = Experiments.Experiment.getSettingFromEvaluationData(evaluationData, labelProperty);
                for i = 1:size(meansYData, 1)
                    for j = 1:length(labelProperty)
                        evaluationLabelValues{j} = evaluationData{i}.settings.(labelProperty{j});
                        if isa(evaluationLabelValues{j},'function_handle')
                            evaluationLabelValues{j} = func2str(evaluationLabelValues{j});
                        end
                    end
                    
                    if (~isempty(labelGenerator))
                        plotDataStruct.evaluationLabels{i} = labelGenerator(evaluationLabelValues{:});
                    else
                        if (~iscell(labelProperty))
                            labelProperty = {labelProperty};
                        end
                        plotDataStruct.evaluationLabels{i} =  sprintf('%s = %1.2f', labelProperty{1},evaluationLabelValues{1});
                        for j = 2:size(evaluationLabelValues,2)
                            plotDataStruct.evaluationLabels{i} = [plotDataStruct.evaluationLabels{i}, sprintf(', %s = %1.2f', labelProperty{j},evaluationLabelValues{j})];
                        end
                    end
                end
            end
            
            cmap = colormap('lines');
            lineStyles = {'-', '-.', '--'};
            
            for i = 1:size(meansYData, 1)
                plotDataStruct.evalProps(i).color = cmap(i,:);
                plotDataStruct.evalProps(i).lineWidth = 2;
                plotDataStruct.evalProps(i).lineStyle = lineStyles{mod(i, length(lineStyles)) + 1};
            end
            plotDataStruct.legendPos = 'Best';
            plotDataStruct.title = plotName;
            plotDataStruct.fontSize = 20;
            plotDataStruct.isLog = useLogTransform;
            
            plotDataStruct.useGrid = true;
            plotDataStruct.yLim = [];
            
            plotDataStruct.fileName = plotName;
            plotDataStruct.plotDir = '';
        end
        
        function [newPlotStruct] = mergePlots(plotStruct1, evalIdx1, plotStruct2, evalIdx2, plotName, newColors)
            
            if (~exist('newColors', 'var'))
                newColors = true;
            end
            
            newPlotStruct = plotStruct1;
            newPlotStruct.evalProps = [plotStruct1.evalProps(evalIdx1), plotStruct2.evalProps(evalIdx2)];
            
            
            newPlotStruct.evaluationLabels = {plotStruct1.evaluationLabels{evalIdx1}, plotStruct2.evaluationLabels{evalIdx2}};
            
            sizeMin = min(size(plotStruct1.meansYData,2), size(plotStruct2.meansYData, 2));
            newPlotStruct.meansYData = [plotStruct1.meansYData(evalIdx1,1:sizeMin); plotStruct2.meansYData(evalIdx2,1:sizeMin)];
            newPlotStruct.xAxis = [plotStruct1.xAxis(evalIdx1,1:sizeMin); plotStruct2.xAxis(evalIdx2,1:sizeMin)];
            newPlotStruct.stdsYData = cat(1, plotStruct1.stdsYData(evalIdx1, :,1:sizeMin), plotStruct2.stdsYData(evalIdx2,:, 1:sizeMin));
            
            newPlotStruct.fileName = plotName;
            
            if (newColors)
                cmap = colormap('lines');
                lineStyles = {'-', '-.', '--'};
                
                for i = 1:size(newPlotStruct.meansYData, 1)
                    newPlotStruct.evalProps(i).color = cmap(i,:);
                    newPlotStruct.evalProps(i).lineWidth = 2;
                    newPlotStruct.evalProps(i).lineStyle = lineStyles{mod(i, length(lineStyles)) + 1};
                end
            end
        end
        
        function plotData = smoothPlotData(plotData, nsmooth)
            for i = 1:size(plotData.meansYData,1)
                plotData.meansYData(i,:) = smooth(plotData.meansYData(i,:), nsmooth);
                plotData.stdsYData(i,1,:) = smooth(plotData.stdsYData(i,1,:), nsmooth);
                plotData.stdsYData(i,2,:) = smooth(plotData.stdsYData(i,2,:), nsmooth);
            end
        end
        
        function hnd = plotDataBoxPlot(plotDataStruct)
            
            hnd = figure(); hold all;
            %             fontSize = plotDataStruct.fontSize;
            set(gca,'FontSize',plotDataStruct.fontSize)
            
            %             noLegend = strcmp(plotDataStruct.legendPos, 'NoLegend');
            
            %             xData = plotDataStruct.xAxis;
            yData = plotDataStruct.meansYData;
            %             errData = plotDataStruct.stdsYData;
            %             boxData = [ yData'; bsxfun(@plus,yData', errData') ];
            
            errData = plotDataStruct.stdsYData(:,1);
            boxData = [ yData'; yData' +  errData'; yData' -  errData' ];
            boxplot(boxData);
            
        end
        
        function hnd = plotData(plotDataStruct,paperMode)
            
            if nargin<2
                paperMode=false;
            end
            
            hnd = figure(); hold all;
            fontSize = plotDataStruct.fontSize;
            set(gca,'FontSize',plotDataStruct.fontSize)
            set(hnd, 'Position', [10 10 1024 768]);
            noLegend = strcmp(plotDataStruct.legendPos, 'NoLegend');
            
            xData = plotDataStruct.xAxis;
            yData = plotDataStruct.meansYData;
            errData = plotDataStruct.stdsYData;
            nIter = size(plotDataStruct.meansYData,2);
            
            
            if nIter == 1
                if(paperMode)
                    anEvalProps = { plotDataStruct.evalProps(evalIdx).lineStyle, ...
                        'Color',  plotDataStruct.evalProps(evalIdx).color, ...
                        'LineWidth',  plotDataStruct.evalProps(evalIdx).lineWidth*0.5};
                else
                    anEvalProps = { plotDataStruct.evalProps(1).lineStyle, ...
                        'Color',  plotDataStruct.evalProps(1).color, ...
                        'LineWidth',  plotDataStruct.evalProps(1).lineWidth};
                end
                graphHnd = Plotter.shadedErrorBar(xData,squeeze(yData(1:plotDataStruct.plotInterval:end)),squeeze(errData(1:plotDataStruct.plotInterval:end,:,:)),anEvalProps',0.5,false,false);
            else
                OUTH = [];
                OUTM = {};
                for evalIdx = 1:size(plotDataStruct.meansYData,1)
                    anEvalProps = { plotDataStruct.evalProps(evalIdx).lineStyle, ...
                        'Color',  plotDataStruct.evalProps(evalIdx).color, ...
                        'LineWidth',  plotDataStruct.evalProps(evalIdx).lineWidth};
                    if(paperMode)
                        anEvalProps = { plotDataStruct.evalProps(evalIdx).lineStyle, ...
                            'Color',  plotDataStruct.evalProps(evalIdx).color, ...
                            'LineWidth',  plotDataStruct.evalProps(evalIdx).lineWidth*0.5};
                        anEvalPropsEdge = { plotDataStruct.evalProps(evalIdx).lineStyle, ...
                            'Color',  plotDataStruct.evalProps(evalIdx).color, ...
                            'LineWidth',  plotDataStruct.evalProps(evalIdx).lineWidth*0.25};
                        % TODO: this is from a conflict, but variable does
                        % not exist?? (anEvalPropsEdge)
                        graphHnd = Plotter.shadedErrorBar(xData(evalIdx,1:plotDataStruct.plotInterval:end),yData(evalIdx,1:plotDataStruct.plotInterval:end),squeeze(errData(evalIdx,:,1:plotDataStruct.plotInterval:end)),anEvalProps',0.9,false,true,anEvalPropsEdge');
                        
                        %graphHnd = Plotter.shadedErrorBar(xData(evalIdx,1:plotDataStruct.plotInterval:end),yData(evalIdx,1:plotDataStruct.plotInterval:end),squeeze(errData(evalIdx,:,1:plotDataStruct.plotInterval:end)),anEvalProps',0.9,false,true,anEvalProps');
                    else
                        graphHnd = Plotter.shadedErrorBar(xData(evalIdx,1:plotDataStruct.plotInterval:end),yData(evalIdx,1:plotDataStruct.plotInterval:end),squeeze(errData(evalIdx,:,1:plotDataStruct.plotInterval:end)),anEvalProps',0.5,false,false);
                        
                    end
                    
                    if(~noLegend)
                        OUTH(evalIdx) = graphHnd.mainLine;
                        OUTM{evalIdx} = plotDataStruct.evaluationLabels{evalIdx};
                        %                     OUTH = [OUTH; graphHnd.mainLine];
                        %                     OUTM = [OUTM, plotDataStruct.evaluationLabels{evalIdx}];
                        legHnd = legend(OUTH,OUTM);
                    end
                    
                    
                end
            end
            
            
            
            if(~isempty(plotDataStruct.xLabel))
                text(0.5,-0.1,plotDataStruct.xLabel,'fontsize',fontSize,'units','normalized','HorizontalAlignment','center','VerticalAlignment','bottom');
            end
            
            if(~isempty(plotDataStruct.yLabel))
                text(-0.05,0.5,plotDataStruct.yLabel,'fontsize',fontSize,'units','normalized', 'HorizontalAlignment','left','VerticalAlignment','bottom','rotation',90);
            end
            
            if(~isempty(plotDataStruct.title))
                %text(0.5,1,plotDataStruct.title,'fontsize',fontSize,'units','normalized', 'HorizontalAlignment','center','VerticalAlignment','bottom');
                title(plotDataStruct.title);
            end
            
            if(plotDataStruct.isLog)
                ticks = get(gca,'YTick');
                ticks = -ticks;
                %set(gca,'YTickLabel',sprintf('%.2f|',ticks));
                text(0,1,'-10^y','fontsize',fontSize,'units','normalized', 'HorizontalAlignment','left','VerticalAlignment','bottom');
            end
            
            if(~noLegend && exist('legHnd','var'))
                set(legHnd,'Interpreter','latex');
                set(legHnd,'location',plotDataStruct.legendPos);
            end
            
            if (~isempty(plotDataStruct.yLim))
                ylim([-7 -3.25]);
            end
            if (plotDataStruct.useGrid)
                grid on;
            end
            
            system('mkdir +Experiments/data/plots');
            if (~isempty(plotDataStruct.fileName))
                [folder, ~, ~] = fileparts(fullfile(plotDataStruct.plotDir,sprintf('plots/%s.tikz', plotDataStruct.fileName)));
                mkdir(folder);
                Plotter.Matlab2Tikz.matlab2tikz('filename',fullfile(plotDataStruct.plotDir,sprintf('plots/%s.tikz', plotDataStruct.fileName)), ...
                    'figurehandle',hnd, ...
                    'width','\figwidth','height','\figheight');
                %                 Plotter.plot2svg(fullfile(plotDataStruct.plotDir,sprintf('plots/%s.svg', plotDataStruct.fileName)),hnd);
                %Plotter.plot2svg(fullfile(plotDataStruct.plotDir,sprintf('plots/%s.svg',plotDataStruct.fileName)),hnd);% Has problems with the legends
                %print(fullfile(plotDataStruct.plotDir,sprintf('plots/%s.svg', plotDataStruct.fileName)), '-dsvg')
                saveas(hnd,fullfile(plotDataStruct.plotDir,sprintf('+Experiments/data/plots/%s.fig', plotDataStruct.fileName)),'fig');
                hgexport(hnd,fullfile(plotDataStruct.plotDir,sprintf('+Experiments/data/plots/%s.eps', plotDataStruct.fileName))); %this works better than saveas and print
            end
        end
        
        function [fieldMean, fieldStd, fieldData] = extractMeanStdFromData(data,field,evalIdx,trialIdx,inLog)
            
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            
            
            [fieldData] = Plotter.PlotterEvaluations.extractFieldData(data,field,evalIdx,trialIdx);
            
            if Plotter.PlotterEvaluations.plotMedianQuantile
                fieldMean = permute(Plotter.nanmedian(fieldData,2),[1 3 2]);
            else
                fieldMean = permute(Plotter.nanmean(fieldData,2),[1 3 2]);
            end
            fieldStd = permute(Plotter.nanstd(fieldData,2),[1 3 2]);
            
            if(exist('inLog','var')&&inLog)
                [fieldMean, fieldStd] = Plotter.PlotterEvaluations.logTransform(fieldMean,fieldStd);
            else
                fieldStd = permute(repmat(fieldStd,[1 1 2]),[1 3 2]);
            end
            
        end
        
        function [fieldMedian, fieldQuantiles, fieldData] = extractMedianQuantileFromData(data,field,evalIdx,trialIdx,iterIdx,inLog)
            
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            
            
            [fieldData] = Plotter.PlotterEvaluations.extractFieldData(data,field,evalIdx,trialIdx,iterIdx);

            if size(fieldData,2)>1
                fieldMedian = permute(Plotter.nanmedian(fieldData,2),[1 3 2]);
                fieldQuantiles = permute(Plotter.quantile(fieldData,Plotter.PlotterEvaluations.quantilePercentage,2),[1 3 2]);
            else
                fieldMedian = permute(fieldData,[1 3 2]);
                fieldQuantiles = permute(fieldData,[1 3 2]); 
                fieldQuantiles = cat(3,fieldQuantiles,fieldQuantiles);
            end
            
            fieldQuantiles = fieldQuantiles(:,:,[2,1]);
            
            if(exist('inLog','var')&&inLog)
                [fieldMedian, fieldQuantiles] = Plotter.PlotterEvaluations.logTransform(fieldMedian,fieldQuantiles);
            end
            
            fieldQuantiles = bsxfun(@minus,fieldQuantiles,fieldMedian);
            fieldQuantiles = abs(fieldQuantiles);
        end
        
        
        function hnd = plotDataX(xdata, ydata, errData, evalName, lineProps)
            addpath('Helpers/shadedErrorBar');
            
            if(nargin == 4)
                lineProps = evalName;
                evalName = errData;
                errData = ydata;
                ydata = xdata;
                xdata = repmat(1:size(ydata,2),size(ydata,1),1);
            elseif(size(xdata,1) < size(ydata,1))
                xdata = repmat(xdata,size(ydata,1),1);
            end
            
            %if(isempty(evalName))
            evalName(end+(1:size(xdata,1)-end)) = repmat({[]},1,size(xdata,1)-numel(evalName));
            lineProps(end+(1:size(xdata,1)-end)) = repmat({{}},1,size(xdata,1)-numel(lineProps));
            
            
            hnd = figure; hold all;
            for idx = 1:size(ydata,1)
                legend('show');
                [~,~,OUTH,OUTM] = legend;
                
                graphHnd = shadedErrorBar(xdata(idx,:),ydata(idx,:),squeeze(errData(idx,:,:)),lineProps{idx},0.5,false,false);
                set(gca,'XTick',xdata(idx,:));
                if(~isempty(evalName{idx}))
                    OUTH = [OUTH; graphHnd.mainLine];
                    OUTM = [OUTM, evalName{idx}];
                    legend(OUTH,OUTM);
                end
            end
        end
        
        function hnd = addDescription(hnd, fontSize, xLabel, yLabel, title, isLog)
            figure(hnd);
            
            set(gca,'fontsize',fontSize);
            if(exist('xLabel','var')&&~isempty(xLabel))
                text(0.5,-0.1,xLabel,'fontsize',fontSize,'units','normalized','HorizontalAlignment','center','VerticalAlignment','top');
            end
            if(exist('yLabel','var')&&~isempty(yLabel))
                text(-0.15,0.5,yLabel,'fontsize',fontSize,'units','normalized', 'HorizontalAlignment','center','VerticalAlignment','bottom','rotation',90);
            end
            if(exist('title','var')&&~isempty(title))
                text(0.5,1,title,'fontsize',fontSize,'units','normalized', 'HorizontalAlignment','center','VerticalAlignment','bottom');
            end
            if(exist('isLog','var')&&isLog)
                ticks = get(gca,'YTick');
                ticks = -ticks;
                set(gca,'YTickLabel',sprintf('%.2f|',ticks));
                text(0,1,'-10^y','fontsize',fontSize,'units','normalized', 'HorizontalAlignment','left','VerticalAlignment','bottom');
            end
            
        end
        
        function hnd = plotDataXXX(data, field, xaxis, evalIdx, trialIdx);
            addpath('Helpers/shadedErrorBar');
            
            
            if(~exist('xaxis','var')||isempty(xaxis))
                xaxis = [];
            end
            
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            hnd = figure; hold all;
            
            for anEval = data(evalIdx)
                legend('show');
                [~,~,OUTH,OUTM] = legend;
                
                if(isempty(trialIdx))
                    trialIdx = 1:numel(anEval.trials);
                end
                fieldMatrix = NaN(numel(anEval.trials(trialIdx)),max(arrayfun(@(d)numel(d.(field)),anEval.trials(trialIdx))));
                idx = 1;
                for aTrial = anEval.trials(trialIdx)
                    N = numel(aTrial.(field));
                    fieldMatrix(idx,1:N) = aTrial.(field);
                    idx = idx +1;
                end
                fieldMean = Plotter.nanmean(fieldMatrix,1);
                fieldStd = Plotter.nanstd(fieldMatrix,[],1);
                if(isempty(xaxis))
                    tmpXAxis = 1:numel(fieldMean);
                else
                    tmpXAxis = xaxis(1:numel(fieldMean));
                end
                newHnd = shadedErrorBar(tmpXAxis,fieldMean,fieldStd,[],0.5);
                
                
                OUTH = [OUTH; newHnd.mainLine];
                OUTM = [OUTM, anEval.evalName];
                legend(OUTH,OUTM);
            end
            
            axis tight;
            drawnow;
        end
        function hnd = logPlotData2(data, field, xaxis, evalIdx, trialIdx)
            addpath('Helpers/shadedErrorBar');
            
            if(~exist('xaxis','var')||isempty(xaxis))
                xaxis = [];
            end
            
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            hnd = figure; hold all;
            
            for anEval = data(evalIdx)
                legend('show');
                [~,~,OUTH,OUTM] = legend;
                

                if(isempty(trialIdx))
                    trialIdx = 1:numel(anEval.trials);
                end
                fieldMatrix = NaN(numel(anEval.trials(trialIdx)),max(arrayfun(@(d)numel(d.(field)),anEval.trials(trialIdx))));
                idx = 1;
                for aTrial = anEval.trials(trialIdx)
                    N = numel(aTrial.(field));
                    fieldMatrix(idx,1:N) = aTrial.(field);
                    idx = idx +1;
                end
                fieldMean = Plotter.nanmean(fieldMatrix,1);
                fieldStd = Plotter.nanstd(fieldMatrix,[],1);
                if(isempty(xaxis))
                    tmpXAxis = 1:numel(fieldMean);
                else
                    tmpXAxis = xaxis(1:numel(fieldMean));
                end
                newHnd = shadedErrorBar(tmpXAxis,fieldMean,fieldStd,[],0.5);
                
                
                OUTH = [OUTH; newHnd.mainLine];
                OUTM = [OUTM, anEval.evalName];
                legend(OUTH,OUTM);
            end
            set(get(hnd,'CurrentAxes'),'YScale','log')
            axis tight;
            drawnow;
        end
        
        function hnd = logPlotData(data, field, xaxis, evalIdx, trialIdx)
            addpath('Helpers/shadedErrorBar');
            
            if(~exist('xaxis','var')||isempty(xaxis))
                xaxis = [];
            end
            
            if(~exist('evalIdx','var')||isempty(evalIdx))
                evalIdx = 1:numel(data);
            end
            if(~exist('trialIdx','var'))
                trialIdx = [];
            end
            
            
            
            hnd = figure; hold all;
            
            for anEval = data(evalIdx)
                

                if(isempty(trialIdx))
                    trialIdx = 1:numel(anEval.trials);
                end
                fieldMatrix = NaN(numel(anEval.trials(trialIdx)),max(arrayfun(@(d)numel(d.(field)),anEval.trials(trialIdx))));
                idx = 1;
                for aTrial = anEval.trials(trialIdx)
                    N = numel(aTrial.(field));
                    fieldMatrix(idx,1:N) = aTrial.(field);
                    idx = idx +1;
                end
                fieldMean = Plotter.nanmean(fieldMatrix,1);
                fieldStd = Plotter.nanstd(fieldMatrix,[],1);
                
                legend('show');
                [~,~,OUTH,OUTM] = legend;
                if(isempty(xaxis))
                    tmpXAxis = 1:numel(fieldMean);
                else
                    tmpXAxis = xaxis(1:numel(fieldMean));
                end
                [logFieldMean, logFieldStd] = Plotter.PlotterEvaluations.logTransform(fieldMean,fieldStd);
                newHnd = shadedErrorBar(tmpXAxis,logFieldMean,logFieldStd,[],0.5);
                
                OUTH = [OUTH; newHnd.mainLine];
                OUTM = [OUTM, anEval.evalName];
                legend(OUTH,OUTM);
            end
            axis tight;
            drawnow;
        end
        
        function [mu, sig] = logTransform(mu, sig)
            indices = isnan(mu);
            sigL = sign(mu-sig).*log10(abs(mu-sig));
            sigL(isnan(sigL)) = 0;
            
            tmp = mu+sig;
            tmp = min(tmp,0);
            sigU = sign(tmp).*log10(abs(tmp));
            sigU(isnan(tmp)) = 0;
            
            mu = sign(mu).*log10(abs(mu));
            mu(isnan(mu)) = 0;
            
            
            sigU = mu+sigL;
            sigL = mu-sigL;
            %sigU = sigU-mu;
            sig = permute(cat(3,sigL,sigL),[1 3 2]);
            mu(indices) = NaN;
            %sig = [sigL(:) sigL(:)]';
        end
        
    end
    
end

