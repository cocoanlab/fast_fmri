function data = fast_fmri_task_main(ts, varargin)

% 
% ts{j} = {{'w1', 'w2'}, [6], [0]} -> no rating
% ts{j} = {{'w1', 'w2'}, [6], [6]} -> rating


% Run a survey for the Free ASsociation Task. 
%
% :Usage:
% ::
%
%    data = fast_survey_main(varargin)
%
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'response':**
%        response{i}{j}: j'th response for i'th seed word
%                - The seed word should be saved as the first (response{i}{1}) response.
%
%   **'savedir':**
%        You can specify the directory where you save the data.
%        The default is the /data of the current directory.
%
%   **'psychtoolbox':**
%        You can specify the psychtoolbox directory. 
%
%   **'scriptdir':**
%        You can specify the script directory. 
%
%
% :Output:
%
%   **data:**
%        data.dat{i}{j}.val_self* : valence and self-relevance
%        data.dat{i}{j}.time* : temporal dimension, past--current--future
%        data.dat{i}{j}.body_* : where in the body, feel activated?
%          * trajectory, timing, rating, RT
%
%
% :Examples:
% ::
%       response{1}{1} = '���'
%       response{1}{2} = '�鼳����';
%       response{1}{3} = '����';
%       response{1}{4} = '����';
%       response{1}{5} = '�鸶';
%       response{2}{1} = '����';
%       response{2}{2} = '��ǳ';
%       response{2}{3} = '����Ʈ';
%       response{2}{4} = '����';
%       response{2}{5} = '�鸶';
%      
%       data = fast_survey_main('response', response)
%
%
% ..
%    Copyright (C) 2017  Wani Woo (Cocoan lab)
% ..

testmode = false;
savedir = fullfile(pwd, 'data');
scriptdir = '/Users/clinpsywoo/github/fast_fmri'; % modify this

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
            case {'scriptdir'}
                scriptdir = varargin{i+1};
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
        end
    end
end

cd(scriptdir);

%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor response_W; % color
global fontsize window_rect lb rb tb bb anchor_xl anchor_xr anchor_yu anchor_yd scale_H; % rating scale

%% SETUP: Screen

bgcolor = 100;

if testmode
    window_rect = [1 1 1280 800]; % in the test mode, use a little smaller screen
else
    window_rect = get(0, 'MonitorPositions'); % full screen
end

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;

font = 'NanumBarunGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];
red_trans = [189 0 38 80];
blue_trans = [0 85 169 80];

% rating scale left and right bounds 1/3 and 2/3
lb = 1.5*W/5; % in 1280, it's 384
rb = 3.5*W/5; % in 1280, it's 896 rb-lb = 512

% rating scale upper and bottom bounds 1/4 and 3/4
tb = H/5+100;           % in 800, it's 210
bb = H/2+100;           % in 800, it's 450, bb-tb = 240
scale_H = (bb-tb).*0.15;

anchor_xl = lb-80; % 284
anchor_xr = rb+20; % 916
anchor_yu = tb-40; % 170
anchor_yd = bb+20; % 710

%% SETUP: DATA and Subject INFO

[fname, start_line, SID, SessID] = subjectinfo_check(savedir, 'task'); % subfunction
% if exist(fname, 'file'), load(fname, 'data'); end

% save data using the canlab_dataset object
data.version = 'FAST_fmri_task_v1_10-13-2017';
data.github = 'https://github.com/cocoanlab/fast_fmri';
data.subject = SID;
data.session = SessID;
data.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
data.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
data.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
data.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '_sess' SessID '.mat']);
data.exp_starttime = datestr(clock, 0); % date-time

% initial save of trial sequence
save(data.taskfile, 'ts', 'data');


%% SETUP: Eyelink

% need to be revised when the eyelink is here.
if USE_EYELINK
    edf_filename = ['eyelink_sub' SID '_sess' SessID];
    eyelink_main(edf_filename, 'Init');
    
    status = Eyelink('Initialize');
    if status
        error('Eyelink is not communicating with PC. Its okay baby.');
    end
    Eyelink('Command', 'set_idle_mode');
    waitsec_fromstarttime(GetSecs, .5);
end


%% TASK START

try
    % START: Screen
    % whichScreen = max(Screen('Screens'));
	theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextFont', theWindow, font); % setting font
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    
    %% PROMPT SETUP:
    pre_scan_prompt = double('�̹����� �������� ��� �����ϼ̴� �ܾ���� ������� ���� �� ���Դϴ�.\n�� �ܾ���� 15�� ���� �����帱�ٵ� �� �ð����� �� �ܾ���� �����п��� � �ǹ̷� �ٰ�������\n�ڿ������� �����غ��ñ� �ٶ��ϴ�. ���� ���� ���� ���� �ܾ�� �߿���\n�������� ������ ������ ���� ����� �ܾ �����Ͻø� �˴ϴ�.\n��� �����ϼ����� ��ư�� Ŭ�����ּ���.');
    exp_start_prompt = double('�����ڴ� ��� ���� �� �غ�Ǿ����� üũ���ּ��� (Biopac, Eyelink, ���).\n��� �غ�Ǿ�����, �����̽��ٸ� �����ּ���.');
    ready_prompt = double('�����ڰ� �غ�Ǿ�����, �̹�¡�� �����մϴ� (s).');
    run_end_prompt = double('���ϼ̽��ϴ�. ��� ����� �ּ���.');
    
    % word_prompt = double('�� �ܾ���� �����п��� � ���� �ǹ����� �ڿ������� �����غ�����.');
    % emo_question_prompt = double('���� �ܾ�� �߿��� �� �ܾ��� �����Ͽ� �������� ������ ������ ���� ����� �ܾ�� �����ΰ���?');
    
    %% TEST RATING: Test trackball, click using an example trial... 
    
    
    %% DISPLAY PRESCAN MESSAGE
    while (1)
        [~, ~, button] = GetMouse(theWindow);
        if button(1)
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        DrawFormattedText(theWindow, pre_scan_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
    end
    
    %% DISPLAY EXP START MESSAGE
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        DrawFormattedText(theWindow, exp_start_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
    end
    
    %% WAITING FOR INPUT FROM THE SCANNER
    while (1)
        [~,~,keyCode] = KbCheck;
        
        if keyCode(KbName('s'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment('manual');
        end
        
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, ready_prompt,'center', textH, white);
        Screen('Flip', theWindow);
    end
    
    %% FOR DISDAQ 10 SECONDS
    
    % gap between 's' key push and the first stimuli (disdaqs: data.disdaq_sec)
    % 4 seconds: "�����մϴ�..."
    data.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('�����մϴ�...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(data.runscan_starttime, 4);
    
    % Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
        
    %% EYELINK AND BIOPAC SETUP
    
    if USE_EYELINK
        Eyelink('StartRecording');
        data.eyetracker_starttime = GetSecs; % eyelink timestamp
    end
        
    if USE_BIOPAC
        data.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(data.biopac_starttime, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    % 10 seconds from the runstart
    waitsec_fromstarttime(data.runscan_starttime, 10);
    
    
    %% MAIN TASK 1. SHOW 2 WORDS, WORD PROMPT
    
    for ts_i = 1:numel(ts)
        
        data.dat{ts_i}.trial_starttime = GetSecs;
        display_target_word(ts{ts_i}{1}); % sub-function
        waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, 15);
        
        % Blank for ISI
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, 15+ts{ts_i}{2});
        
        if ts{ts_i}{3} ~=0
            data.dat{ts_i}.rating_starttime = GetSecs;
            [data.dat{ts_i}.rating_emotion_word, data.dat{ts_i}.rating_trajectory] = emotion_rating; % sub-function: 5s
            
            % Blank for ITI
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, 15+ts{ts_i}{2}+5+ts{ts_i}{3});
        end
        
        if mod(ts_i, 2) == 0
            save(data.taskfile, 'data', '-append');
        end
        
    end
    
    %% DISPLAY POSTSCAN MESSAGE
    while (1)
        if keyCode(KbName('n'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        DrawFormattedText(theWindow, run_end_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
    end
    
    save(data.taskfile, 'data', '-append');
    
    ShowCursor; %unhide mouse
    Screen('CloseAll'); %relinquish screen control 
    
catch err
    % ERROR 
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment('error');  
end

end


%% == SUBFUNCTIONS ==============================================


function abort_experiment(varargin)

% ABORT the experiment
%
% abort_experiment(varargin)

str = 'Experiment aborted.';

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'error'}
                str = 'Experiment aborted by error.';
            case {'manual'}
                str = 'Experiment aborted by the experimenter.';
        end
    end
end


ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
disp(str); %present this text in command window

end


%% ========================== SUB-FUNCTIONS ===============================

function display_target_word(words)

global W H white

Screen('TextSize', theWindow, 30);
[response_W(1), response_H(1)] = Screen(theWindow, 'DrawText', words{1}, 0, 0);

Screen('TextSize', theWindow, 50);
[response_W(2), response_H(2)] = Screen(theWindow, 'DrawText', words{2}, 0, 0);

interval = 200;

x(1) = W/2 - interval/2 - response_W(1);
x(2) = W/2 + interval/2;

y(1) = H/2 - response_H(1);
y(2) = H/2 - response_H(2);

Screen(theWindow,'FillRect',bgcolor, window_rect);

Screen('TextSize', theWindow, 30);
DrawFormattedText(theWindow, words{1}, x(1), y(1), white, [], [], [], 1.5);

Screen('TextSize', theWindow, 50);
DrawFormattedText(theWindow, words{2}, x(2), y(2), white, [], [], [], 1.5);

Screen('Flip', theWindow);

end

function [emotion_word, trajectory] = emotion_rating

end