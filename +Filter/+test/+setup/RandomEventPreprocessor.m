%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('eventProbability','var')
    eventProbability = 1/30;
end

if ~exist('random_event_prepro_input','var')
    random_event_prepro_input = current_data_pipe;
end

if ~exist('random_event_prepro_output','var')
    random_event_prepro_output = cellfun(@(A) [A 'Noisy'],random_event_prepro_input, 'UniformOutput', false);
end

if ~exist('random_event_prepro_name','var')
    random_event_prepro_name = 'eventPrepro';
end

% observation noise settings
settings.setProperty([random_event_prepro_name '_eventProbability'], eventProbability);
settings.setProperty([random_event_prepro_name '_inputNames'], random_event_prepro_input);
settings.setProperty([random_event_prepro_name '_outputNames'], random_event_prepro_output);

% preprocessors
eventPrepro = DataPreprocessors.RandomEventPreprocessor(dataManager,random_event_prepro_name);

current_data_pipe = random_event_prepro_output;