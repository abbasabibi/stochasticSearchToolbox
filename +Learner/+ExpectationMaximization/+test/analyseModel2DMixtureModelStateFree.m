function [] = analyseModel2DMixtureModelStateFree(learner, data, EMData)
samples = [EMData.inputData, EMData.outputData];
plot(samples(:,1), samples(:,2),'*')
color = {'r', 'g', 'b'};
hold all
for o = 1 : numel(learner.mixtureModel.options)
    mu = learner.mixtureModel.options{o}.getMean();
    Sigma = learner.mixtureModel.options{o}.getCovariance();
    
    Plotter.Gaussianplot.plotgauss2d(mu, Sigma, color{mod(o, 3) + 1}, 2)
end
%pause;
end
