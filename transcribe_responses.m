function transcribe_responses(varargin)

% This function can be used to transcribe the FAST task responses.
%
% :Usage:
% :: 
%       transcribe_responses(varargin)
%
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'savedir':**
%           default is /data of the current directory
%
%   **'seed_start':**
%           default is 1, but you can specify the word
%

savedir = fullfile(pwd, 'data');
seed_start = 1;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'savedir'}
                savedir = varargin{i+1};
            case {'seed_start'}
                seed_start = varargin{i+1};
        end
    end
end

SID = input('Subject ID (number)? ', 's');

% data file
dat_file= fullfile(savedir, ['taskdata_s' SID '.mat']);
load(dat_file); % load data

% play each word
for seeds_i = seed_start:numel(out.response)
    
    % input_key = '';
    str{1} = '==================================================';
    str{2} = sprintf('    %3dth seed words: %s   ', seeds_i, out.response{seeds_i}{1});
    str{3} = '==================================================';
    
    clc;  % clear the screen...
    for i = 1:numel(str), disp(str{i}); end
    
    for response_i = 1:(numel(out.audiodata{seeds_i}))
        
        input_key = '';
        while isempty(deblank(input_key))
            disp(['''' out.response{seeds_i}{response_i} '''의 다음 단어는 무엇인가요? ']);
            players = audioplayer(out.audiodata{seeds_i}{response_i}', 44100);
            play(players);
            input_key = input('단어를 적고 엔터키를 눌러주세요. 다시 듣고 싶으시면 엔터키를 눌러주세요:  ', 's');
        end
        
        out.response{seeds_i}{response_i+1} = input_key;
    end
    
    save(dat_file, 'out');
end

end