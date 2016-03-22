Common.clearClasses
clc


filterStdDevEvaluator = Evaluator.FilterStdDevEvaluator();
filteredDataEvaluator = Evaluator.FilteredDataEvaluator();

pIn = zeros(10,3);
for i = 1:10
    clear trial
    load(['/local_data/data/evalBigRefsetSize/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201503031427_01/eval001/trial0' sprintf('%02d',i) '/trial.mat'])

    pIn(i,:) = filterStdDevEvaluator.getEvaluation([],[],trial);
end

pIn
% mean(pOut,1)