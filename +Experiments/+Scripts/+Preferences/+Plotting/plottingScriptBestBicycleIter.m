clear variables;

baseFolder = 'C:/Users/cwirth/git/policysearchtoolbox/+Experiments/data/bestBicycle/';
%baseFolder = '~/policysearchtoolbox/+Experiments/data/bestBicycle/';

Plotter.PlotterEvaluations.plotMode(3);

plotRewardEval = true;

%measure = {'settings.numInitialSamplesEpisodes','settings.numSamplesEpisodes'};
%scale =  '%1.0f initial %1.0f/iteration';
%labelGen = @(x1_,x2_) sprintf(scale, x1_, x2_);

%measure = {'settings.trajPrefsPerIteration','settings.initPrefs','settings.numSamplesEpisodes','settings.numInitialSamplesEpisodes','settings.epsilonAction'};
%scale =  'p=%1.0f iP=%1.0f s=%1.0f iS=%1.0f e=%1.3f';
%labelGen = @(x1_,x2_,x3_,x4_,x5_) sprintf(scale, x1_, x2_, x3_, x4_, x5_);

%measure = {'settings.softMaxTemperature','settings.softMaxDecay','settings.numInitialSamplesEpisodes'};
%scale =  's = %1.3f i = %1.3f e = %1.3f';
%labelGen = @(x1_,x2_,x3_) sprintf(scale, x1_, x2_,x3_);

measure = {'settings.trajPrefsPerIteration'};
scale =  'prefs/iter = %1.0f';
labelGen = @(x1_) sprintf(scale, x1_);

%measure = {'settings.softMaxTemperature','settings.softMaxDecay'};
%scale =  't = %1.3f tD = %1.2f';
%labelGen = @(x1_,x2_) sprintf(scale, x1_, x2_);

%measure = {'settings.epsilonAction','settings.trajPrefsPerIteration'};
%scale =  'eps = %1.3f smp = %1.0f';
%labelGen = @(x1_,x2_) sprintf(scale, x1_, x2_);

%measure = {'settings.epsilonAction'};
%scale =  'eps = %1.2f';
%labelGen = @(x1_) sprintf(scale, x1_);

tldDir = dir(baseFolder);
isDir = [tldDir(:).isdir];
names = {tldDir(isDir).name}';
names(ismember(names,{'.','..'})) = [];

if plotRewardEval
    returnName = 'rewardEval';
else
    returnName = 'avgReturn';
end

completedataPlot = [];

for k=1:length(names)
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
            if(k==2)
                idx = [];
            else
                idx = [1,3,6];
            end
            [dataPlot] = Plotter.PlotterEvaluations.preparePlotData(data, 'iterations', 'avgLengthEval', measure, labelGen, avgStr, false, idx, []); %last two p: trial,evals
            
            %A = dataPlot.stdsYData;
            %szA = size(A);
            %dataPlot.stdsYData = permute(reshape(repmat(A,1,3,1),szA(2),3*szA(3)),[3,1,2]);
            %dataPlot.stdsYData = cat(3,dataPlot.stdsYData(1,:,1), dataPlot.stdsYData);
            
            if(isempty(completedataPlot))
                completedataPlot = dataPlot;
            else
                completedataPlot.meansYData = [completedataPlot.meansYData; dataPlot.meansYData];
                completedataPlot.stdsYData = [completedataPlot.stdsYData; dataPlot.stdsYData];
                completedataPlot.evalProps(3) = dataPlot.evalProps;
                completedataPlot.xAxis = [completedataPlot.xAxis; dataPlot.xAxis];
            end
        end
    end
end

completedataPlot.evaluationLabels = {'3 pref/iter';'2 pref/iter'; '1 pref/iter'; 'reward'};
completedataPlot.title = avgStr;
completedataPlot.xLabel = 'iteration';
completedataPlot.yLabel = 'steps';
completedataPlot.fontSize = 30;

cmap = colormap('lines');
lineStyles = {'-', '-.', '--'};
for i = 1:4
    completedataPlot.evalProps(i).color = cmap(i,:);
    completedataPlot.evalProps(i).lineWidth = 3;
    completedataPlot.evalProps(i).lineStyle = lineStyles{mod(i, length(lineStyles)) + 1};
end

Plotter.PlotterEvaluations.plotData(completedataPlot,true);


