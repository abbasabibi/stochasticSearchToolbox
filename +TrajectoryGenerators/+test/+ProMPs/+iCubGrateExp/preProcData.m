%% Cleaning up and saving 
function imlearn = preProcData (config)

allData = {};

for k = 1 : length(config.fNamesIn)
    
    load([config.fPrefixIn,config.fNamesIn{k}]);
    
    config.demos2kill{k} = sort(config.demos2kill{k});

    for i = length(config.demos2kill{k}):-1:1
        savedData(config.demos2kill{k}(i)) = [];
    end
    savedData(end) = []; % Last one is always empty
    
    if ( config.saveIndividual )
        
        imlearn = procDataInt ( savedData, config );
        
        save([config.fPrefixOut, config.fNamesIn{k}, config.fsuffix,'.mat'], 'imlearn');
        cMap = colormap(hsv(length(config.fNamesIn)));
        plotDataProMPsFormat ( imlearn, cMap(k,:) );
    end
    
    allData = [allData,savedData]; %#ok<AGROW>
    
end

imlearn = procDataInt ( savedData, config );

save([config.fPrefixOut, config.fNamesIn{k}, config.fsuffix,'All.mat'],'imlearn');

end


function checkFiltering (dataIn, config )

field = 'dataSendArm';
alpha = 0.85;

field = 'dataForce';
alpha = 0.94;

field = 'dataEnc';
alpha = 0.85;

nDim = size(dataIn{1}.(field),2);
fh = [];
for i = 1:(2*nDim)
    fh(end+1) = figure;
    hold on;
    pause
end

fData = {};

for i = 1:length(dataIn)
    
    x = dataIn{i}.(field);
    for k = 2:length(x)
        x(k,:) = alpha * x(k-1,:) + (1-alpha) * x(k,:);
    end
    
    fData{end+1} = x;
end
    
for j = 1:nDim
    figure(fh(j));
    for k = 1:length(fData)
        plot(fData{k}(:,j));
    end
    
    figure(fh(j+nDim));
    for k = 1:length(fData)
        tmp = dataIn{k}.(field);
        plot(tmp(:,j));
        
    end
    
    pause
end
    
   
    
end



function imlearn = procDataInt ( savedData, config )

%  checkFiltering (savedData, config );

filtData = mvAvgFltForce(savedData, config);
filtData = interpolate_data ( filtData );

if ( config.outTorque )
    filtData = moveDesPos2DesTau (filtData, config);
else
    filtData = moveDesPos2Vel(filtData, config);
end

%         filtData = computeCorrelatioCoeff ( filtData, joints2save, actions2save );
imlearn = toProMPsFormat(filtData, config);


end


function filtData = moveDesPos2DesTau (dataIn, config)

alpha       = config.alphaPos;
Kp          = config.Kp;
action2Save = config.actions2save;
joints2save = config.joints2save;

filtData =  dataIn;

for i = 1:length(dataIn)
    
    xf = dataIn{i}.dataSendArm(:,action2Save);
    for k = 2:length(xf)
        xf(k,:) = alpha * xf(k-1,:) + (1-alpha) * xf(k,:);
    end
    
    xT = Kp * (xf - dataIn{i}.dataEnc(:,joints2save));
    filtData{i}.dataSendArm(:,action2Save) = xT;
    
end

end


function filtData = moveDesPos2Vel(rawData, config)

alpha = config.velFltalpha;

debugPlot = 0;

if(debugPlot)
    debugFigIdxFlt = (1:(size(rawData{1}.dataSendArm,2)-1))+2500; 
    debugFigIdx = (1:(size(rawData{1}.dataSendArm,2)-1))+2600;    
end

filtData = rawData;
dt = rawData{1}.dt;

for i = 1:length(rawData)
    
    filtData{i}.dataSendArmOrg = filtData{i}.dataSendArm;
    
    filtData{i}.dataSendArm(1:end-1,2:end) = diff(rawData{i}.dataSendArm(:,2:end))/dt;
    filtData{i}.dataSendArm(end,2:end) = rawData{i}.dataSendArm(end-1,2:end);
    
    filtData{i}.dataSendArm(1,2:end) = 0;
    
    for j = 2:length(rawData{i}.dataSendArm)   
        
        filtData{i}.dataSendArm(j,2:end) = alpha .* filtData{i}.dataSendArm(j-1,2:end) + ...
                            ( 1 - alpha ) .* filtData{i}.dataSendArm(j,2:end);
    end
    
    if ( debugPlot )
        for j = 1:length(debugFigIdxFlt)
            figure(debugFigIdxFlt(j));hold all;
            % plot(diff(filtData{i}.dataSendArm(:,j+1)));
            plot(filtData{i}.dataSendArm(:,j+1));
            figure(debugFigIdx(j));hold all;
            plot(diff(rawData{i}.dataSendArm(:,j+1))/dt);
        end
    end
    
end


end

% Moving average filter 
function filtData = mvAvgFltForce(rawData, config)

alpha = config.forceFltAlpha;

debugPlot = 0;

if(debugPlot)
    debugFigIdxFlt = (1:(size(rawData{1}.dataForce,2)-1))+2500; 
    debugFigIdx = (1:(size(rawData{1}.dataForce,2)-1))+2600;    
end


filtData = rawData;

for i = 1:length(rawData)
    
    for j = 2:length(rawData{i}.dataForce)
        
        filtData{i}.dataForce(j,2:end) = alpha .* filtData{i}.dataForce(j-1,2:end) + ...
                            ( 1 - alpha ) .* rawData{i}.dataForce(j,2:end);
    end
    
    if ( debugPlot )
        for j = 1:length(debugFigIdxFlt)
            figure(debugFigIdxFlt(j));hold all;
            plot(filtData{i}.dataForce(:,j+1));
            figure(debugFigIdx(j));hold all;
            plot(rawData{i}.dataForce(:,j+1));
            pause(0.3)
        end
    end
    
end
    
end


function intrpData = interpolate_data ( rawData )

endTime_min = 1e10;

%  demos x [ dataEnc, dataForce, dataSendArm]
demo_dt = zeros(length(rawData), 3);

for i=1:length(rawData)
    tE = rawData{i}.dataEnc(end,1);
    tF = rawData{i}.dataForce(end,1);
    tD = rawData{i}.dataSendArm(end,1);
    demo_dt(i,:) = [ tE / length(rawData{i}.dataEnc),...
                tF / length(rawData{i}.dataForce),...
                tD / length(rawData{i}.dataSendArm)];
    endTime_min = min([endTime_min, tE, tF, tD]);
end

%figure;plot(dt)

dt = mean(mean(demo_dt(:,[1,2])));
dt = 0.020;
t_axis = dt:dt:endTime_min;

intrpData = cell(size(rawData));
for i=1:length(rawData)
    
    intrpData{i}.dataEnc = interpDataInternal(rawData{i}, t_axis, 'dataEnc');
    intrpData{i}.dataForce = interpDataInternal(rawData{i}, t_axis, 'dataForce');
    intrpData{i}.dataSendArm = interpDataInternal(rawData{i}, t_axis, 'dataSendArm');
    intrpData{i}.dt = dt;
    
end


end

function intrpData = interpDataInternal(rawData, t_axis, field)

    intrpData = zeros(length(t_axis),size(rawData.(field),2));
    intrpData(:,1) = t_axis;
    for k = 1:size(rawData.(field),2)
        intrpData(:,k) = interp1(rawData.(field)(:,1),rawData.(field)(:,k),t_axis);
    end

end


function imlearn = toProMPsFormat(sData, config )

joints2save  = config.joints2save;
force2save   = config.force2save;
actions2save = config.actions2save;

saveForce = ~isequal ( force2save, 0 );

armName = {'time', 'shoulder pitch', 'shoulder roll', 'shoulder yaw', 'elbow', ...
            'wrist prosup', 'wrist pitch', 'wrist yaw' };
        
actionNames = {'time', 'elbow', 'shoulder pitch', 'wrist prosup' };

forceNames = { 'time', 'Fx', 'Fy', 'Fz', 'Tx', 'Ty', 'Tz'};

numSamples = length(sData);

imlearn.q = cell(numSamples,1);
imlearn.u = cell(numSamples,1);
imlearn.dt = sData{1}.dt;
 
for i = 1:numSamples   
    
    tr = sData{i}.dataEnc(:,joints2save);
    if ( saveForce )
        trF = sData{i}.dataForce(:,force2save);
        tr = [ tr, trF ]; 
    end
    
    trd = diff(tr);
    trd(end+1,:) = trd(end,:);
    
    imlearn.q{i} = zeros(size(tr,1),2*size(tr,2));
    imlearn.q{i}(:,1:2:end) = tr;
    imlearn.q{i}(:,2:2:end) = trd;
    
    imlearn.u{i} = sData{i}.dataSendArm(:,actions2save);
end

imlearn.jointNames = armName(joints2save);
if ( saveForce )
    imlearn.jointNames = [imlearn.jointNames, forceNames(force2save)];
    imlearn.forceIdx   = (1:length(force2save)) + length(joints2save);
end

imlearn.actionNames = actionNames(actions2save);

imlearn.ctlTorque = config.outTorque;

end

function plotDataProMPsFormat ( data, c )

figIdx = (1:(size(data.q{1},2)/2))+1500;
for i = 1:length(figIdx)
    figure(figIdx(i));hold all;
    title(['Joint ',num2str(i),' ',data.jointNames{i}])
end

for i = 1:length(data.q)
    for j = 1:length(figIdx)
        figure(figIdx(j));
        plot(data.q{i}(:,(2*j)-1),'Color',c);
    end
end

figIdx = (1:size(data.u{1},2))+1600;
for i = 1:length(figIdx)
    figure(figIdx(i));hold all;
    title(['Action ',num2str(i),' ',data.actionNames{i}]) %TODO
end

for i = 1:length(data.u)
    for j = 1:length(figIdx)
        figure(figIdx(j));
        plot(data.u{i}(:,j),'Color',c);
    end
end


end


function data = computeCorrelatioCoeff ( dataIn, joints2save, actions2save )
%todo normalize
debugPlot = 1;

fp = figure; hold on;

for i = 1:length(dataIn)
    
    dataIn{i}.ccDPosPos = corrcoef( [ dataIn{i}.dataEnc(:,joints2save), dataIn{i}.dataSendArmOrg(:,actions2save) ]  );
    dataIn{i}.ccDVelPos = corrcoef( [ dataIn{i}.dataEnc(:,joints2save), dataIn{i}.dataSendArm(:,actions2save) ]  );
    
    x = diff(dataIn{i}.dataSendArm(:,actions2save)) / dataIn{i}.dt;
    x(end+1,:) = x(end,:);
    dataIn{i}.ccDAccPos = corrcoef( [ dataIn{i}.dataEnc(:,joints2save), x ]  );
    
    x = dataIn{i}.dataSendArmOrg(:,actions2save);
    xf = x;
    for k = 2:length(x)
        xf(k,:) = 0.99 * xf(k-1,:) + 0.01 * xf(k,:);
    end
    
    xT = 0.05*(x - dataIn{i}.dataEnc(:,joints2save));
    dataIn{i}.ccDTauPos = corrcoef( [ xf, xT ]  );
    
    xdd = diff(dataIn{i}.dataEnc(:,joints2save),2) / dataIn{i}.dt^2;
    xddf = xdd;
    for k = 2:length(xdd)
        xddf(k,:) = 0.99 * xddf(k-1,:) + 0.01 * xddf(k,:);
    end
    
    dataIn{i}.ccDTauAcc = corrcoef( [ xdd, xT(3:(end),:) ]  );
    dataIn{i}.ccDTauAccF = corrcoef( [ xddf, xT(3:(end),:) ]  );
    
end

if ( debugPlot ) 
   
    figure(fp);
%     plot( diag(dataIn{i}.ccDPosPos
    
end

end
    


