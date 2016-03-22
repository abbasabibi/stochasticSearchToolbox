classdef VonMisesBasisGenerator < TrajectoryGenerators2.BasisFunctions.BasisGeneratorDerivatives
    
    properties
        widthFactorBasis = 2.0;
    end
    
    methods
        
        function obj = VonMisesBasisGenerator(settings)
            
            obj = obj@TrajectoryGenerators2.BasisFunctions.BasisGeneratorDerivatives(settings);
            obj.addProperty('widthFactorBasis');
            obj.registerParameters(settings);
       
        end
        
        function mu = getMu(obj)
            mu = linspace(0, 1, (obj.numBasis + 1));            
            mu = mu(1:end-1);
        end
        
        function sigma = getBasisWidth(obj)
            sigma = ones(1, obj.numBasis) * obj.widthFactorBasis;            
        end
        
        function [basis_n, basisD_n, basisDD_n] = generateBasisWithDerivatives(obj, phase)
            
            mu = obj.getMu();
            k  = obj.widthFactorBasis;
            
            
            phase_mu = bsxfun(@minus, phase, mu );
            
            basis = exp ( k * cos ( phase_mu * 2 * pi ) - k );
            
            
            basisD = - basis * k .* sin ( phase_mu * 2 * pi ) * 2 * pi;
            
            basisDD = - basisD * k .* sin ( phase_mu * 2 * pi ) * 2 * pi ...
                      - basis  * k .* cos ( phase_mu * 2 * pi ) * 4 * pi^2;
                  
                  
                  
            basis_n = bsxfun ( @rdivide, basis , sum(basis,2) );


            basisD_n = bsxfun ( @times, basisD , sum(basis,2) ) ;
            basisD_n = basisD_n - bsxfun ( @times, basis , sum(basisD,2) ) ;
            basisD_n = bsxfun ( @rdivide, basisD_n , sum(basis,2).^2 ) ;
            
            
            basisDD_n = bsxfun ( @rdivide, basisDD , sum(basis,2) );
            basisDD_n = basisDD_n -  bsxfun ( @times, 2 .* basisD , sum(basisD,2) ./ (sum(basis,2)).^2  );
            
            basisDD_n = basisDD_n -  bsxfun ( @times, basis , sum(basisDD,2) ./ (sum(basis,2)).^2  );
            
            basisDD_n = basisDD_n +  bsxfun ( @times, 2.* basis , sum(basisD,2).^2 ./ (sum(basis,2)).^3  );
            
            
        end
        
        function [] = writeBasisData(obj, basisPref)
            fd = fopen( strcat(basisPref,'mu.cf'), 'w' );
            fprintf ( fd, '%e ', obj.getMu() );
            fprintf ( fd, '\n' );
            fclose ( fd );
            
            
            fd = fopen ( strcat(basisPref,'sigma.cf'), 'w' );
            fprintf ( fd, '%e  ', obj.getBasisWidth() );
            fprintf ( fd, '\n' );
            fclose ( fd );            
        end
        
        function [ok] = writeBasisHeader(obj, fd)             
            fprintf ( fd, 'numBasisType 1 \n' );
            fprintf ( fd, 'basisType VonMisesNorm \n' );
            fprintf ( fd, 'basisTypeName b1 \n\n' );
        end
    end
    
end

