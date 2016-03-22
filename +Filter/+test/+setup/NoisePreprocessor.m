%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('obs_noise','var')
    obs_noise = 1e-2;
end

if ~exist('noise_prepro_input','var')
    noise_prepro_input = current_data_pipe;
end

if ~exist('noise_prepro_output','var')
    noise_prepro_output = cellfun(@(A) [A 'Noisy'],noise_prepro_input, 'UniformOutput', false);
end

if ~exist('noise_prepro_name','var')
    noise_prepro_name = 'noisePrepro';
end

% observation noise settings
settings.setProperty([noise_prepro_name '_sigma'], obs_noise);
settings.setProperty([noise_prepro_name '_inputNames'], noise_prepro_input);
settings.setProperty([noise_prepro_name '_outputNames'], noise_prepro_output);

% preprocessors
noisePrepro = DataPreprocessors.AdditiveGaussianNoisePreprocessor(dataManager,noise_prepro_name);

current_data_pipe = noise_prepro_output;