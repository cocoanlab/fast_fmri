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
fast_fmri_word_generation(seeds_rand{1}, 'biopac', 'eyelink');

%% 
fast_fmri_transcribe_responses('nosound') % while running fast_fmri_word_generation
fast_fmri_transcribe_responses('only_na') % after running fast_fmri_word_generation

%%
ts = fast_fmri_generate_ts;
fast_fmri_task_main(ts, 'biopac', 'eyelink', 'practice');

%% Sess 2
fast_fmri_word_generation(seeds_rand(2), 'biopac', 'eyelink');
fast_fmri_task_main(response, 'biopac', 'eyelink');

%%

%% transcription
transcribe_responses;

%% survey
fast_survey_main('scriptdir', '/Users/byeoletoile/CloudStation/Project/Experiment/scripts/fast_task_preparing');