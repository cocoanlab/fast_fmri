%% RUN ONCE for the experiment
seeds = {'생각', '따스함', '아픔', '아빠', '여행', '한숨'};
InitializePsychSound;
seeds_rand = seeds(randperm(numel(seeds)));

% savename
% save

%% If you need to start in the middle

% load
InitializePsychSound;

%% Sess 1
fast_fmri_word_generation(seeds_rand(1), 'biopac', 'eyelink');
fast_fmri_task_main(response, 'biopac', 'eyelink');

%% Sess 2
fast_fmri_word_generation(seeds_rand(2), 'biopac', 'eyelink');
fast_fmri_task_main(response, 'biopac', 'eyelink');

%%

%% transcription
transcribe_responses;

%% survey
fast_survey_main('scriptdir', '/Users/byeoletoile/CloudStation/Project/Experiment/scripts/fast_task_preparing');