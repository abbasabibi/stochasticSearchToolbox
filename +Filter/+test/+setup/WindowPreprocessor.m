%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('window_size','var')
    window_size = 4;
end

if ~exist('obs_ind','var')
%     obs_ind = window_size;
    obs_ind = 1;
end

if ~exist('window_prepro_input','var')
    window_prepro_input = current_data_pipe;
end

if ~exist('window_prepro_output','var')
    window_prepro_output = cellfun(@(A) [A 'Windows'],window_prepro_input, 'UniformOutput', false);
end

if ~exist('window_prepro_name','var')
    window_prepro_name = 'windowsPrepro';
end

% general settings
% settings.setProperty('windowSize', window_size);
% settings.setProperty('observationIndex', obs_ind);


% window settings
settings.setProperty([window_prepro_name '_inputNames'], window_prepro_input);
settings.setProperty([window_prepro_name '_outputNames'], window_prepro_output);
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
settings.setProperty([window_prepro_name '_indexPoint'], obs_ind);
settings.setProperty([window_prepro_name '_windowSize'], window_size);

% preprocessors
windowsPrepro = DataPreprocessors.GenerateDataWindowsPreprocessor(dataManager,window_prepro_name);

current_data_pipe = window_prepro_output;