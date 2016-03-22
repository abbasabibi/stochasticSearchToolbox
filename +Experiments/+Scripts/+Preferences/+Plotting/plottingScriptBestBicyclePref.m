clear variables;

baseFolder = 'C:/Users/cwirth/git/policysearchtoolbox/+Experiments/data/bestBicycle/';
%baseFolder = '~/policysearchtoolbox/+Experiments/data/bestPreBicycle/';

Plotter.PlotterEvaluations.plotMode(3);

plotRewardEval = true;


measure = {'settings.trajPrefsPerIteration'};
scale =  'preferences/iter = %1.0f';
labelGen = @(x1_) sprintf(scale, x1_);



tldDir = dir(baseFolder);
isDir = [tldDir(:).isdir];
names = {tldDir(isDir).name}';
names(ismember(names,{'.','..'})) = [];

if plotRewardEval
    returnName = 'rewardEval';
else
    returnName = 'avgReturn';
end

for k=1:1
    dirNameParent = names{k};
    
    exDir = dir(strcat(baseFolder,dirNameParent));
    isDir = [exDir(:).isdir];
    exNames = {exDir(isDir).name}';
    exNames(ismember(exNames,{'.','..'})) = [];
    
    for l=1:length(exNames)
        dirNameExperiment = exNames{l};
        
        exFile = dir(strcat(baseFolder,dirNameParent,'/',dirNameExperiment));
        fNames = {exFile.name}';
        if sum(ismember(fNames,{'experiment.mat'}))==1
            load(strcat(baseFolder,dirNameParent,'/',dirNameExperiment,'/experiment.mat'));
            
            data = obj.getTrialData({'reqPrefs','avgLengthEval',returnName});
            
            env = obj.configurators{1}.name;
            if strcmp(env,'GridWorld')
                env = strsplit(func2str(obj.configurators{1}.worldName),'.');
                env = env{3};
                if findstr(env,'Riads')
                    for j=1:size(data,2)
                        for i=1:size(data(j).trials,2)
                            if plotRewardEval
                                data(j).trials(i).rewardEval=data(j).trials(i).rewardEval/4.43779;
                            else
                                data(j).trials(i).avgReturn=data(j).trials(i).avgReturn/4.43779;
                            end
                        end
                    end
                end
            end
            
            dirs = strsplit(obj.path,{'\','/'},'CollapseDelimiters',true);
            elements = strsplit(dirs{end},'_');
            name = strcat(env,elements{1});
            optStr = strcat(name,'Optimal');
            avgStr = strcat(name,'Average');
            
            %[dataPlot] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'rewardEvalOptimalPolicy', measure, labelGen, optStr, false, [], []); %last two p: trial,evals
            %dataPlot.title = optStr;
            %Plotter.PlotterEvaluations.plotData(dataPlot);
            
            [dataPlot] = Plotter.PlotterEvaluations.preparePlotData(data, 'reqPrefs', 'avgLengthEval', measure, labelGen, avgStr, false, [1,3,6], []); %last two p: trial,evals
            dataPlot.title = avgStr;
            dataPlot.xLabel = '#preferences';
            dataPlot.yLabel = 'steps';
            dataPlot.fontSize = 30;
            Plotter.PlotterEvaluations.plotData(dataPlot,true);
        end
    end
end


