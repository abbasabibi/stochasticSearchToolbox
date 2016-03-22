
for j  = 1:14
    load data/Tactile/dataTactile_train.mat

    numElements = [data.dataStructure.steps(:).numElements];
    elementsIdx = find(numElements((1:15) + (j-1) * 15) >= 45);
    
    data = data.cloneDataSubSet(elementsIdx + (j-1) * 15);
    for i = 1:data.getNumElements()
        data.reserveStorage(45, i);
    end
    save(sprintf('data/Tactile/dataTactile_train_dropped%d.mat', j), 'data');
    
    %%%
    
    load data/Tactile/dataTactile_test.mat
    
    numElements = [data.dataStructure.steps(:).numElements];
    elementsIdx = find(numElements((1:15) + (j-1) * 15) >= 45);
    
    data = data.cloneDataSubSet(elementsIdx + (j-1) * 15);
    
    for i = 1:data.getNumElements()
        data.reserveStorage(45, i);
    end
    
    save(sprintf('data/Tactile/dataTactile_test_dropped%d.mat',j), 'data');
    
end
