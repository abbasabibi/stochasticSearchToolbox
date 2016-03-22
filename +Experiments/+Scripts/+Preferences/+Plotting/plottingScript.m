clear variables;

%baseFolder = 'C:/Users/cwirth/workspace/policysearchtoolbox/+Experiments/data/testRuns/';
baseFolder = '~/policysearchtoolbox/+Experiments/data/results2015/';

Plotter.PlotterEvaluations.plotMedianQuantile(true);
Plotter.PlotterEvaluations.quantilePercentage([0.25,.75]);

tldDir = dir(baseFolder);
isDir = [tldDir(:).isdir];
names = {tldDir(isDir).name}';
names(ismember(names,{'.','..'})) = [];

for k=1:length(names)
    dirNameParent = names{k};
    
    exDir = dir(strcat(baseFolder,dirNameParent));
    isDir = [exDir(:).isdir];
    exNames = {exDir(isDir).name}';
    exNames(ismember(exNames,{'.','..'})) = [];
    
    allPlotData = [];
    
    compactPlotData = [];
    normalPlotData = [];
    
    IRLPlotData = [];
    MLPlotData = [];
    MeanPlotData = [];
    
    for l=1:length(exNames)
        dirNameExperiment = exNames{l};
        
        exFile = dir(strcat(baseFolder,dirNameParent,'/',dirNameExperiment));
        fNames = {exFile.name}';
        
        if sum(ismember(fNames,{'experiment.mat'}))==1
            load(strcat(baseFolder,dirNameParent,'/',dirNameExperiment,'/experiment.mat'));
            for i=1:numel(experiment.evaluation)
                try
                    field = 'rewardEval';
                    [dataEval, plotData] = experiment.evaluation(i).plotResults(false,field,'reqPrefs');
                    name = experiment.evaluation(i).experiment.experimentId;
                    plotData.evaluationLabels = repmat({name},1,numel(plotData.evaluationLabels));
                    if isempty(allPlotData)
                        allPlotData = plotData;
                        allPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,field];
                    else
                        allPlotData = Plotter.PlotterEvaluations.mergePlots(allPlotData,[1:numel(allPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],allPlotData.title);
                    end
                    
                    if  (~isempty(strfind(name,'Compact')) || ~isempty(strfind(name,'BVIRL')))
                        if isempty(compactPlotData)
                            compactPlotData = plotData;
                            compactPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,'Compact',field];
                        else
                            compactPlotData = Plotter.PlotterEvaluations.mergePlots(compactPlotData,[1:numel(compactPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],compactPlotData.title);
                        end
                    else
                        if isempty(normalPlotData)
                            normalPlotData = plotData;
                            normalPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,'Normal',field];
                        else
                            normalPlotData = Plotter.PlotterEvaluations.mergePlots(normalPlotData,[1:numel(normalPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],normalPlotData.title);
                        end
                    end
                    
                    if(~isempty(strfind(name,'IRL')))
                        if isempty(IRLPlotData)
                            IRLPlotData = plotData;
                            IRLPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,'IRL',field];
                        else
                            IRLPlotData = Plotter.PlotterEvaluations.mergePlots(IRLPlotData,[1:numel(IRLPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],IRLPlotData.title);
                        end
                    end
                    
                    if(~isempty(strfind(name,'ML')))
                        if isempty(MLPlotData)
                            MLPlotData = plotData;
                            MLPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,'ML',field];
                        else
                            MLPlotData = Plotter.PlotterEvaluations.mergePlots(MLPlotData,[1:numel(MLPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],MLPlotData.title);
                        end
                    end
                    
                                       if(~isempty(strfind(name,'Mean')))
                        if isempty(MeanPlotData)
                            MeanPlotData = plotData;
                            MeanPlotData.title = [experiment.evaluation(i).experiment.configurators{1}.name,'Mean',field];
                        else
                            MeanPlotData = Plotter.PlotterEvaluations.mergePlots(MeanPlotData,[1:numel(MeanPlotData.evalProps)],plotData,[1:numel(plotData.evalProps)],MeanPlotData.title);
                        end
                    end
                catch ex
                end
            end
        end
    end
    try
        Plotter.PlotterEvaluations.plotData(allPlotData,true);
        
        Plotter.PlotterEvaluations.plotData(compactPlotData,true);
        Plotter.PlotterEvaluations.plotData(normalPlotData,true);
        
        Plotter.PlotterEvaluations.plotData(IRLPlotData,true);
        %Plotter.PlotterEvaluations.plotData(MLPlotData,true);
        %Plotter.PlotterEvaluations.plotData(MeanPlotData,true);
    catch ex
    end
end


