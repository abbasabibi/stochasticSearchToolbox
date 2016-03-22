clear variables;

folders = {'C:/Users/cwirth/git/policysearchtoolbox/+Experiments/data/bestRIAD5/','C:/Users/cwirth/git/policysearchtoolbox/+Experiments/data/best2015/'};

Plotter.PlotterEvaluations.plotMode(3);

plotRewardEval = true;

measure = {'settings.numInitialSamplesEpisodes','settings.numSamplesEpisodes'};
scale =  '%1.0f inital %1.0f/iteration';
labelGen = @(x1_,x2_) sprintf(scale, x1_, x2_);


if plotRewardEval
    returnName = 'rewardEval';
else
    returnName = 'avgReturn';
end

completedataPlot = [];

for n=1:length(folders)
    tldDir = dir(folders{n});
    isDir = [tldDir(:).isdir];
    names = {tldDir(isDir).name}';
    names(ismember(names,{'.','..'})) = [];
    for k=1:length(names)
        dirNameParent = names{k};
        
        exDir = dir(strcat(folders{n},dirNameParent));
        isDir = [exDir(:).isdir];
        exNames = {exDir(isDir).name}';
        exNames(ismember(exNames,{'.','..'})) = [];
        
        for l=1:length(exNames)
            dirNameExperiment = exNames{l};
            
            exFile = dir(strcat(folders{n},dirNameParent,'/',dirNameExperiment));
            fNames = {exFile.name}';
            if sum(ismember(fNames,{'experiment.mat'}))==1
                load(strcat(folders{n},dirNameParent,'/',dirNameExperiment,'/experiment.mat'));
                
                data = obj.getTrialData({'reqPrefs',returnName});
                
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
                idx = 2;
                if(n==1)
                    idx = 1;
                end
                [dataPlot] = Plotter.PlotterEvaluations.preparePlotData(data, 'reqPrefs', returnName, measure, labelGen, avgStr, false, [idx], []); %last two p: trial,evals
                
                A = dataPlot.stdsYData;
                szA = size(A);
                dataPlot.stdsYData = permute(reshape(repmat(A,1,3,1),szA(2),3*szA(3)),[3,1,2]);
                dataPlot.stdsYData = cat(3,dataPlot.stdsYData(1,:,1), dataPlot.stdsYData);
                
                if(isempty(completedataPlot))
                    completedataPlot = dataPlot;
                else
                    completedataPlot.meansYData = [completedataPlot.meansYData; dataPlot.meansYData];
                    completedataPlot.stdsYData = [completedataPlot.stdsYData; dataPlot.stdsYData];
                    completedataPlot.evalProps = [completedataPlot.evalProps; dataPlot.evalProps];
                    completedataPlot.xAxis = [completedataPlot.xAxis; dataPlot.xAxis];
                end
            end
        end
    end
end

completedataPlot.evaluationLabels = {'original';'Base Pb-IRL'; 'SoftMax'; 'PF'};

riadData = [0.0659177429,0.0321110377,0.25307299;
0.127172426,0.0637981976,0.127172426;
0.127172426,0.127172426,0.127172426;
0.127172426,0.127172426,0.25307299;
0.25307299,0.127172426,0.25307299;
0.25307299,0.127172426,0.25307299;
0.25307299,0.25307299,0.25307299;
0.25307299,0.25307299,0.25307299;
0.25307299,0.25307299,0.503179711;
0.25307299,0.25307299,0.503179711;
0.503179711,0.25307299,0.503179711;
0.503179711,0.25307299,0.503179711;
0.503179711,0.503179711,0.503179711;
0.503179711,0.503179711,0.503179711;
0.503179711,0.503179711,1;
0.503179711,0.503179711,1;
1,0.503179711,1;
1,0.503179711,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;
1,1,1;];

riadMedian = riadData(:,1)';
riadQ25 = riadData(:,2)';
riadQ75 = riadData(:,3)';

A = completedataPlot.meansYData;
szA = size(A);
n = 3;
A = reshape(repmat(A,n,1),szA(1),n*szA(2));

completedataPlot.meansYData = [A(:,1),A; [riadMedian,ones(1,36)]];



completedataPlot.stdsYData = [completedataPlot.stdsYData; permute([riadQ75-riadMedian,zeros(1,36);riadMedian-riadQ25,zeros(1,36)],[3,1,2])];
completedataPlot.evalProps = [completedataPlot.evalProps; completedataPlot.evalProps(1)];
completedataPlot.xAxis = [1:76;1:76;1:76;1:76];

maxData = 50;
completedataPlot.meansYData = completedataPlot.meansYData(:,1:maxData);
completedataPlot.stdsYData = completedataPlot.stdsYData(:,:,1:maxData);
completedataPlot.xAxis = completedataPlot.xAxis(:,1:maxData);

cmap = colormap('lines');
lineStyles = {'-', '-.', '--'};
for i = 1:4
    completedataPlot.evalProps(i).color = cmap(i,:);
    completedataPlot.evalProps(i).lineWidth = 2;
    completedataPlot.evalProps(i).lineStyle = lineStyles{mod(i, length(lineStyles)) + 1};
end
completedataPlot.xLabel = '#preferences';
completedataPlot.yLabel = '%optimal';
completedataPlot.title = avgStr;
Plotter.PlotterEvaluations.plotData(completedataPlot,true);


