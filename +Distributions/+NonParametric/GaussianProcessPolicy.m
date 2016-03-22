
classdef GaussianProcessPolicy < Distributions.NonParametric.GaussianProcess
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    

    
    methods
        function obj = GaussianProcessPolicy(dataManager, kernelfc, inputVar)
            if(~exist('inputVar', 'var'))
                inputVar = 'states';
            end
            obj = obj@Distributions.NonParametric.GaussianProcess(dataManager, kernelfc, 'actions', inputVar);


            
            

            % obj.registerMappingInterfaceDistribution();
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function writeParameters(obj, filename)
            f = fopen(filename,'w');
            gaussian = false;
            if(isa(obj.kernel.kernel,'FeatureGenerators.Kernel.ExponentialQuadraticKernel'))
                gaussian = true;
                bandwidth = obj.kernel.kernel.bandwidth;
                scale = obj.kernel.kernel.scale;
            end
            if(isa(obj.kernel.kernel,'FeatureGenerators.Kernel.ProductKernel'))
                gaussian = true;
                bandwidth = [];
                scale = 1;
                for i = 1:numel(obj.kernel.kernel.kernels)
                    if(~isa(obj.kernel.kernel.kernels{i},'FeatureGenerators.Kernel.ExponentialQuadraticKernel'))
                        gaussian=false;
                    else
                        bandwidth = [bandwidth, obj.kernel.kernel.kernels{i}.bandwidth];
                        scale = scale * obj.kernel.kernel.kernels{i}.scale;                        
                    end
                end
            end            
            if(~gaussian)
                error('Non-Gaussian kernels not implemented yet')
            end
            fprintf(f, 'nparams 7\n');
            fprintf(f, ['bandwidth', sprintf(' %d', bandwidth),'\n']);
            fprintf(f, 'scale %d\n', scale);
            fprintf(f, 'lambda %d\n', obj.kernel.kernel.lambda);
            fprintf(f, ['minvalues', sprintf(' %d',obj.dataManager.getMinRange('actions')),'\n']);
            fprintf(f, ['maxvalues', sprintf(' %d',obj.dataManager.getMaxRange('actions')),'\n']);
            fprintf(f, ['stdevInit', sprintf(' %d', obj.dataManager.getRange('actions') .* obj.initSigma),'\n']);
            fprintf(f, 'resetProb %d\n',Common.Settings().getProperty('resetProb')); 
            
            idxs = find(obj.weighting > max(obj.weighting)*10e-4);
            
            fprintf(f, 'npoints %d\n', numel(idxs));
            dlmwrite(filename, obj.trainingInput(idxs,:), '-append');
            dlmwrite(filename, obj.trainingOutput(idxs,:), '-append');
            dlmwrite(filename, obj.weighting(idxs), '-append');
            fclose(f);
        end
        
   

    end
    
end

