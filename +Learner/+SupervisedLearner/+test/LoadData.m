function [dataX , dataY] = LoadData



dir = ['/home/abdolmaleki/policytool/+Experiments/data/NaoWalking/NaoBandit_REPS/numSamples_201402211849_01/eval001/trial001/']
dataX = [];
dataY = [];

numItr2Load = 10; % Each iteration has 50 samples

startFrom = 80 ;

for i = 0:floor(130/10 + 1) % loads iteration structs
    
load([dir 'iter_' sprintf('%05d',i*10+1) '_' sprintf('%05d',(i+1)*10) '.mat']);

end

for j = startFrom:startFrom+numItr2Load % Make parameter matrix in form [s,theta] and Output matrix in form [y]
    
   idx = eval( ['iter' sprintf('%05d',j)] ) 
   dataIter = [ idx.data.getDataEntry('contexts') idx.data.getDataEntry('parameters') ];
   dataX = [ dataX ; dataIter ]; 
   dataIter = [idx.data.getDataEntry('returns') ];
   dataY = [ dataY ; dataIter]; 
   
end


