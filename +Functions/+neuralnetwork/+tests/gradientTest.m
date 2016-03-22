clear;
inputSize = randi(5);

maxUnits = randi(25);
maxLayers = randi(maxUnits);
unitsPerLayer = randsample(maxUnits, maxLayers)';

for layer = 1 : maxLayers
    tmp = randi(3);
    switch tmp
        case 1
            activationFunctions{layer} = 'id';
        case 2
            activationFunctions{layer} = 'tansig';
        case 3
            activationFunctions{layer} = 'logsig';
        otherwise
            activationFunctions{layer} = 'id';
    end
end

ann = ANN(inputSize, unitsPerLayer, activationFunctions);
alpha = rand / 5;
bp = BP(alpha, ann);

for i = 1 : inputSize
    input(i) = -10 + (20)*rand;
end
input = input';

outputSize = unitsPerLayer(end);
for i = 1 : outputSize
    output(i) = -10 + (20)*rand;
end
output = output';

gradient = bp.gradient(input, output);
ngradient = bp.numericalGradient(input, output);

equal = true;
eps = 10^-2;
for i = 1 : size(gradient, 2);
    for j = 1 : size(gradient{i},1) * size(gradient{i}, 2)
        anaG = gradient{i}(j);
        numG = ngradient{i}(j);
        if(~(numG + eps > anaG && numG - eps < anaG))
            equal = false;
            break;
        end
    end
    if(~equal)
        break;
    end
end