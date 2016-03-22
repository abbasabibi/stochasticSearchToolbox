%==========================================================================
% NLopt installation
%==========================================================================
% This script will install NLopt into policysearchtoolbox/NLopt. No root 
% privileges required.
%==========================================================================
% Version: 2.4.2
% Needed software: wget
% Tested with: Matlab R2014a (8.3.0.532)
%==========================================================================

% create NLfolder inside the PST
w = what;
system(['mkdir ',w.path,'/NLopt']);
nlfolder = [w.path,'/NLopt'];


% download source code
% You need wget if you cant install it place the sourcecode in the
% NLopt folder
system(['wget -O ',nlfolder,'/nlopt-2.4.2.tar.gz ', 'http://ab-initio.mit.edu/nlopt/nlopt-2.4.2.tar.gz']);

% unzip
system(['tar -xzf ',nlfolder,'/nlopt-2.4.2.tar.gz -C ',nlfolder]);

% create folder for the sourcecode
sfolder = [nlfolder,'/nlopt-2.4.2'];

% compiling code
system(['cd ',sfolder,' && ./configure --prefix=',nlfolder,' --enable-shared MEX=',matlabroot,'/bin/mex MEX_INSTALL_DIR=',nlfolder,' MATLAB=',matlabroot]);
system(['make --directory ',sfolder]);
system(['make install --directory ',sfolder]);

% add to matlab path
addpath(nlfolder);

% cleanup
system(['rm -r ',sfolder]);
system(['rm ',nlfolder,'/nlopt-2.4.2.tar.gz']);

fprintf('\n\n\nInstallation done! You have to add the directory %s/lib to your LD_LIBRARY_PATH variable!\n',nlfolder);
fprintf('please copy paste the following lines add the end of your .bashrc file!\n')
fprintf('LD_LIBRARY_PATH=$LD_LIBRARY_PATH:%s/lib\n', nlfolder);
fprintf('export LD_LIBRARY_PATH\n');


