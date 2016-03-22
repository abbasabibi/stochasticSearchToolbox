classdef NormalizedGaussianBasisGenerator < TrajectoryGenerators.BasisFunctions.BasisGeneratorDerivatives
    properties
        muBasis
    end
    
    properties (SetObservable, AbortSet)
        widthFactorBasis = 1.0;
        numCentersOutsideRange = 2.0;
    end
    
    methods
        
        function obj = NormalizedGaussianBasisGenerator(dataManager, phaseGenerator, basisName)
            if (~exist('basisName', 'var'))
                basisName = 'basis';
            end
            
            obj = obj@TrajectoryGenerators.BasisFunctions.BasisGeneratorDerivatives(dataManager, phaseGenerator, basisName);
            
            obj.linkProperty('widthFactorBasis');
            obj.linkProperty('numCentersOutsideRange');
        end
        
        function sigma = getBasisWidth(obj)
            sigma = ones(1, obj.numBasis) / obj.numBasis * obj.widthFactorBasis;
        end
        
        
        function mu = getMu(obj)
            mu = linspace(-obj.numCentersOutsideRange / obj.numBasis * obj.widthFactorBasis, ...
                1 + obj.numCentersOutsideRange / obj.numBasis * obj.widthFactorBasis, obj.numBasis);
        end
        
        %         function [basis_n, basisD_n, basisDD_n] = generateBasis(obj, phase)
        %
        %             mu = obj.getMu();
        %
        %             sigma = obj.getBasisWidth();
        %             time_mu = bsxfun(@minus, phase, mu );
        %             at = bsxfun(@times, time_mu, 1./sigma);
        %
        %             basis = bsxfun(@times, exp( -0.5 * at.^2 ), 1./sigma/sqrt(2*pi) );
        %
        %             basis_sum = sum(basis,2);
        %
        %             basis_n = bsxfun(@times, basis, 1 ./ basis_sum);
        %
        %             % figure
        %             % plot(time,basis_n')
        %
        %
        %             time_mu_sigma = bsxfun(@times, -time_mu, 1./(sigma.^2) );
        %
        %             if (nargout > 1)
        %                 basisD =  time_mu_sigma .* basis;
        %                 basisD_sum = sum(basisD,2);
        %
        %                 basisD_n_a = bsxfun(@times, basisD, basis_sum);
        %                 basisD_n_b = bsxfun(@times, basis, basisD_sum);
        %                 basisD_n = bsxfun(@times, basisD_n_a - basisD_n_b, 1 ./(basis_sum.^2) );
        %
        %                 tmp =  bsxfun(@times,basis, -1./(sigma.^2) );
        %                 basisDD = tmp + time_mu_sigma .* basisD;
        %                 basisDD_sum = sum(basisDD,2);
        %
        %
        %                 basisDD_n_a = bsxfun(@times, basisDD, basis_sum.^2);
        %                 basisDD_n_b1 = bsxfun(@times, basisD, basis_sum);
        %                 basisDD_n_b = bsxfun(@times, basisDD_n_b1, basisD_sum);
        %
        %                 basisDD_n_c1 =  2 * basisD_sum.^2 - basis_sum .* basisDD_sum;
        %                 basisDD_n_c = bsxfun(@times, basis,  basisDD_n_c1);
        %
        %                 basisDD_n_d = basisDD_n_a - 2 .* basisDD_n_b + basisDD_n_c;
        %
        %                 basisDD_n = bsxfun(@times, basisDD_n_d, 1 ./ basis_sum.^3);
        %             end
        %         end
        
        function basis_n = generateBasis(obj, phase)
            
            mu = obj.getMu();
            
            sigma = obj.getBasisWidth();
            time_mu = bsxfun(@minus, phase, mu );
            at = bsxfun(@times, time_mu, 1./sigma);
            
            basis = bsxfun(@times, exp( -0.5 * at.^2 ), 1./sigma/sqrt(2*pi) );
            
            basis_sum = sum(basis,2);
            
            basis_n = bsxfun(@times, basis, 1 ./ basis_sum);
            
        end
        
        function basisD_n  = generateBasisD(obj, phase)
            
            mu = obj.getMu();
            
            sigma = obj.getBasisWidth();
            time_mu = bsxfun(@minus, phase, mu );
            at = bsxfun(@times, time_mu, 1./sigma);
            
            basis = bsxfun(@times, exp( -0.5 * at.^2 ), 1./sigma/sqrt(2*pi) );
            
            basis_sum = sum(basis,2);
            
            time_mu_sigma = bsxfun(@times, -time_mu, 1./(sigma.^2) );
            
            basisD =  time_mu_sigma .* basis;
            basisD_sum = sum(basisD,2);
            
            basisD_n_a = bsxfun(@times, basisD, basis_sum);
            basisD_n_b = bsxfun(@times, basis, basisD_sum);
            basisD_n = bsxfun(@times, basisD_n_a - basisD_n_b, 1 ./(basis_sum.^2) );
            
        end
        
        
        % Computing the second derivative
        function basisDD_n  = generateBasisDD(obj, phase)
            
            mu = obj.getMu();
            
            sigma = obj.getBasisWidth();
            time_mu = bsxfun(@minus, phase, mu );
            at = bsxfun(@times, time_mu, 1./sigma);
            
            basis = bsxfun(@times, exp( -0.5 * at.^2 ), 1./sigma/sqrt(2*pi) );
            
            basis_sum = sum(basis,2);
            
            time_mu_sigma = bsxfun(@times, -time_mu, 1./(sigma.^2) );
            
            basisD =  time_mu_sigma .* basis;
            basisD_sum = sum(basisD,2);
            
            tmp =  bsxfun(@times,basis, -1./(sigma.^2) );
            basisDD = tmp + time_mu_sigma .* basisD;
            basisDD_sum = sum(basisDD,2);
            
            basisDD_n_a = bsxfun(@times, basisDD, basis_sum.^2);
            basisDD_n_b1 = bsxfun(@times, basisD, basis_sum);
            basisDD_n_b = bsxfun(@times, basisDD_n_b1, basisD_sum);
            
            basisDD_n_c1 =  2 * basisD_sum.^2 - basis_sum .* basisDD_sum;
            basisDD_n_c = bsxfun(@times, basis,  basisDD_n_c1);
            
            basisDD_n_d = basisDD_n_a - 2 .* basisDD_n_b + basisDD_n_c;
            
            basisDD_n = bsxfun(@times, basisDD_n_d, 1 ./ basis_sum.^3);
            
        end
        
    end
end
