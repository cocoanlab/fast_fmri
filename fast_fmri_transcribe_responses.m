function fast_fmri_transcribe_responses(varargin)

% This function can be used to transcribe the FAST fmri task responses.
%
% :Usage:
% :: 
%       fast_fmri_transcribe_responses(varargin)
%
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'savedir':**
%           default is /data of the current directory
%
%   **'response_n':**
%           If you want to transcribe some specific numbers, you can use
%           this option. 
% 
%   **'nosound':**
%           You can use this option while running the word generation task 
%           in the scanner (fast_fmri_word_generation.m).
%
%   **'only_na':**
%           This will play the sound for the responses you couldn't hear at
%           the first try ('na').
%
% :Example:
%    fast_fmri_transcribe_responses('nosound') % while running fast_fmri_word_generation in the scanner
%
%    fast_fmri_transcribe_responses('only_na') % after running fast_fmri_word_generation
%
%    fast_fmri_transcribe_responses('response_n', [2 6 38]) % playing sound only a few specific trials
%
%    fast_fmri_transcribe_responses('response_n', [2 6 38], 'nosound') % playing sound only a few specific trials
%
%    fast_fmri_transcribe_responses % after running fast_fmri_word_generation
%
%

%% PARSING OUT OPTIONAL INPUT
savedir = fullfile(pwd, 'data');
do_playsound = true;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'savedir'}
                savedir = varargin{i+1};
                varargin{i} = [];
                varargin{i+1} = [];
            case {'nosound'}
                do_playsound = false;
                varargin{i} = [];
        end
    end
end

%% LOAD DATA
SID = input('Subject ID (number)? ', 's');
SessID = input('Session number? ', 's');

dat_file = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
save_file = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);

load(dat_file); 
load(save_file);

%% Response_N
response_n = 1:numel(out.audiodata);

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'response_n'}
                response_n = varargin{i+1};
                if size(response_n,1) > size(response_n,2), response_n = response_n'; end
            case {'only_na'}
                response_n = find(strcmp(response, 'na'));
        end
    end
end

%% PLAY RESPONSES

for response_i = response_n

    str{1} = '==================================================';
    str{2} = sprintf('    %2dth response word   ', response_i);
    str{3} = '==================================================';
    
    clc;  % clear the screen...
    
    for i = 1:numel(str), disp(str{i}); end
    
    input_key = '';
    while isempty(deblank(input_key))
        disp(['''' response{response_i} '''�� ���� �ܾ�� �����ΰ���? ']);
        if do_playsound
            players = audioplayer(out.audiodata{response_i}', 44100);
            play(players);
            input_key = input('�ܾ ���� ����Ű�� �����ּ���. �ٽ� ��� �����ø� ����Ű�� �����ּ���:  ', 's');
        else
            input_key = input('�ܾ ���� ����Ű�� �����ּ���. ��������� ''na''�� ���� �� ����Ű�� �����ּ���:  ', 's');
        end
    end
    
    response{response_i+1} = input_key;
    
    save(save_file, 'response');
end

end