classdef ExternalEpisodeSampler < Sampler.IndependentSampler
    properties (Access = protected)
        rewardFunction 
        returnSampler
    end
    
    properties
        policy
        controller_file='/dev/shm/controller.txt'
        data_file='/dev/shm/rolloutdata.txt'
        
    end
    

    
    methods
        function [obj] = ExternalEpisodeSampler(dataManager, samplerName)
            
            if (~exist('dataManager', 'var'))
                dataManager = Data.DataManager('episodes');
            end
            
            if (~exist('samplerName', 'var'))
                samplerName = 'episodes';
            end            
            
            obj = obj@Sampler.IndependentSampler(dataManager, samplerName);
            
            stepsDataManager = Data.DataManager('steps');
            obj.dataManager.setSubDataManager(stepsDataManager);
            
            obj.addSamplerPool('Return', 7);
        end
        
        function [] = setRewardFunction(obj, rewardFunction)
            obj.rewardFunction = rewardFunction;
        end
        
        function [] = setReturnFunction(obj, rewardSampler, samplerName)
            if ( ~exist('samplerName', 'var') || isempty(samplerName) )
                samplerName = 'sampleReturn';
            end
            if (strcmp(samplerName, 'sampleReturn'))
                obj.returnSampler = rewardSampler;
            end
            
            obj.addSamplerFunctionToPool('Return', samplerName, rewardSampler, 1);
        end
        
        function [dataManager] = getEpisodeDataManager(obj)
            dataManager = obj.dataManager;
        end
        
        function [value] = readint(obj, f, name)
            value_cell = textscan(f, '%s %f', 1);
            assert(strcmp(value_cell{1}{1}, name), 'unexpected entry in file');
            value = value_cell{2};
        end
        
        function writeParameters(obj, filename)
            gp = obj.policy;
            f = fopen(filename,'w');
            gaussian = false;
            if(isa(gp.kernel,'Kernels.ExponentialQuadraticKernel'))
                gaussian = true;
                if(gp.kernel.ARD)
                    bandwidth = gp.kernel.bandWidth;
                else
                    bandwidth = gp.kernel.bandWidth * ones(1, gp.kernel.numDims); 
                end
            end
            if(isa(gp.kernel,'Kernels.ProductKernel'))
                gaussian = true;
                bandwidth = [];
                for i = 1:numel(gp.kernel.kernels)
                    if(~isa(gp.kernel.kernels{i},'Kernels.ExponentialQuadraticKernel'))
                        gaussian=false;
                    else
                        if(gp.kernel.kernels{i}.ARD)
                            bandwidth = [bandwidth, gp.kernel.kernels{i}.bandWidth];
                        else
                            bandwidth = [bandwidth, gp.kernel.kernels{i}.bandWidth * ones(1, gp.kernel.kernels{i}.numDims)];
                        end             
                    end
                end
            end            
            if(~gaussian)
                error('Non-Gaussian kernels not implemented yet')
            end
            fprintf(f, 'nparams 7\n');
            fprintf(f, ['bandwidth', sprintf(' %d', bandwidth),'\n']);
            fprintf(f, 'scale %d\n', gp.GPPriorVariance);
            fprintf(f, 'lambda %d\n', gp.GPRegularizer);
            fprintf(f, ['minvalues', sprintf(' %d',gp.dataManager.getMinRange('actions')),'\n']);
            fprintf(f, ['maxvalues', sprintf(' %d',gp.dataManager.getMaxRange('actions')),'\n']);
            fprintf(f, ['stdevInit', sprintf(' %d', gp.dataManager.getRange('actions') .* gp.initSigma),'\n']);
            fprintf(f, 'resetProb %d\n',Common.Settings().getProperty('resetProbTimeSteps')); 
            
            %idxs = find(gp.weighting > max(gp.weighting)*10e-4);
            
            fprintf(f, 'npoints %d\n', size(gp.getReferenceSet,1));
            dlmwrite(filename, gp.getReferenceSet, '-append');
            dlmwrite(filename, gp.alpha, '-append');
            dlmwrite(filename, gp.cholKy, '-append');
            fclose(f);
        end
        
        function [] = createSamples(obj, newData, varargin)
            numSamples = obj.getNumSamples(newData, varargin{:});
                        
            if (numSamples > 0)
                newData.reserveStorage(numSamples, varargin{:});
                newData.resetFeatureTags();
                newData.setDataEntry('iterationNumber', obj.iterIdx);

                % write controller files
                obj.writeParameters(obj.controller_file)
                fprintf('written controller file, waiting for input\n')
                % wait for data file to be written
                l = dir(obj.data_file);
                if(numel(l)==1)
                    old_filetime = l.datenum;
                else
                    old_filetime = 0;
                end                  
                new_filetime = old_filetime;
                while(new_filetime == old_filetime)
                    
                    l = dir(obj.data_file);
                    if(numel(l)==1)
                        new_filetime = l.datenum;
                    else
                        new_filetime = 0;
                    end
                    pause(1)
                end
                
                % read return file and store everything in newData
                f = fopen(obj.data_file);
                nentries = obj.readint(f, 'nrollouts:');
                fgetl(f); %read newline character
                dimstates = 12; %obj.dataManager.getDataManagerForEntry('states').dataEntries('states').numDimensions;
                dimactions = obj.dataManager.getDataManagerForEntry('actions').dataEntries('actions').numDimensions;
                
                %entries_cell = textscan(f, '%s %f', nentries);
                %entry_names = entries_cell{1};
                %entry_sizes = entries_cell{2}';
                %ncols = sum(entry_sizes);
                
                %nrollouts = readint(f, 'nrollouts');
                
                for i = 1:nentries
                    %skip header
                    fgetl(f);
                    %read actual data
                    c = cell2mat(textscan(f, repmat('%f ', 1, dimstates + dimactions)));
                    
                    nsteps = size(c,1) - 1;
                    newData.reserveStorage(nsteps,i);
                    rawstates = c(:, 1:dimstates);
                    
                    %changes here have to be done in gp_controller.py as
                    %well!
                    %scale 10-30 between 0-1
                    %states1 = min(1, (sum(abs(rawstates(:,1:4)),2) - 10)/30); 
                    %states2 = min(1, (sum(abs(rawstates(:,5:8)),2) - 10)/30);
                    %states1 = zeros(size(rawstates,1),1); 
                    states1 = 2/pi*atan(pi/2*sum(abs(rawstates(:,1:4)),2)/40);
                    %states2 = zeros(size(rawstates,1),1); 
                    states2 = 2/pi*atan(pi/2*sum(abs(rawstates(:,5:8)),2)/40);
                    %states3 = rawstates(:,9) -rawstates(:,10);
                    %states4 = rawstates(:,10) - rawstates(:,9);
                    states3 = rawstates(:,9);
                    states4 = rawstates(:,10);
                    %states5 = rawstates(:,11) + rawstates(:,12);
                    %states6 = rawstates(:,12) + rawstates(:,11);
                    states5 = rawstates(:,11);
                    states6 = rawstates(:,12);
                    
                    allStates = [states1, states2, states3, states4, states5, states6];
                    states = allStates(1:end-1, :);
                    nextStates = allStates(2:end, :);
                    
                    actions = c(1:nsteps, (dimstates+1):end);
                    
                    % calculate rewards
                    %rewardInputNames = {'states','actions'}; %possible with obj.rewardFunction.inputArguments ??
                    %rewardInputs = newData.getDataEntryCellArray(rewardInputNames);
                    rewardInputs = {states, actions};
                    r = obj.rewardFunction.rewardFunction(rewardInputs{:});
                    
                    newData.setDataEntryCellArray(...
                        {'states','actions','nextStates','timeSteps', 'rewards'},...
                        {states, actions, nextStates,(1:nsteps)', r},i);
                    %nsteps = readint(f, 'nsteps');
                    %data.reserveStorage(nsteps, i);
                    %data = dlmread(obj.data_file, ',', [0 0 nsteps ncols]);
                    %celldata = mat2cell(data,  entry_sizes);
                    %newData.setDataEntryCellArray(entry_names, celldata, i);
                end
                fclose(f);
                

                
                numElements = newData.getNumElements;
                obj.sampleAllPools(newData, 1:numElements);
            end
        end
        
        function [] = setActionPolicy(obj, actionPolicy)
            obj.policy = actionPolicy;
        end

        %%  Sampler Pools add, flush, set ( flush and set )
        
%         function [] = setReturnFunction(obj, rewardSampler, samplerName)
%             if ( ~exist('samplerName', 'var') || isempty(samplerName) )
%                 samplerName = 'sampleReturn';
%             end
%             if (strcmp(samplerName, 'sampleReturn'))
%                 obj.returnSampler = rewardSampler;
%             end
%             
%             obj.addSamplerToPoolInternal('Return', samplerName, rewardSampler, 1);
%         end
        
 
        
%         function [] = addReturnFunction(obj, rewardSampler, samplerName)
%             if ( ~exist('samplerName', 'var') || isempty(samplerName) )
%                 samplerName = 'sampleReturn';
%             end
%             obj.addSamplerToPoolInternal( 'Return', samplerName, rewardSampler);
%         end
        

        
        %%
        
    end
end