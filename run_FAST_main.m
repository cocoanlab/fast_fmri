%% run task
% seeds = {'생각', '따스함', '아픔', '아빠', '여행', '한숨', '건물'};

seeds = {'생각'};
fast_task_main(seeds,'repeat',3,'test');

%% transcription
transcribe_responses;

%% survey

fast_survey_main('scriptdir', '/Users/byeoletoile/CloudStation/Project/Experiment/scripts/fast_task_preparing');