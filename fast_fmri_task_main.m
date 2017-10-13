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
%       response{1}{1} = '사과'
%       response{1}{2} = '백설공주';
%       response{1}{3} = '마녀';
%       response{1}{4} = '왕자';
%       response{1}{5} = '백마';
%       response{2}{1} = '나무';
%       response{2}{2} = '단풍';
%       response{2}{3} = '데이트';
%       response{2}{4} = '왕자';
%       response{2}{5} = '백마';
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
    pre_scan_prompt = double('이번에는 여러분이 방금 말씀하셨던 단어들을 순서대로 보게 될 것입니다.\n각 단어들을 15초 동안 보여드릴텐데 그 시간동안 그 단어들이 여러분에게 어떤 의미로 다가오는지\n자연스럽게 생각해보시기 바랍니다. 이후 여러 개의 감정 단어들 중에서\n여러분이 느끼는 감정과 가장 가까운 단어를 선택하시면 됩니다.\n모두 이해하셨으면 버튼을 클릭해주세요.');
    exp_start_prompt = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    ready_prompt = double('피험자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    word_prompt = double('이 단어들이 여러분에게 어떤 의미인지 자연스럽게 생각해보세요.');
    emo_question_prompt = double('감정 단어들 중에서 이 단어들과 관련하여 여러분이 느끼는 감정과 가장 가까운 단어는 무엇인가요?');
    
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
    % 4 seconds: "시작합니다..."
    data.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(data.runscan_starttime, 4);
    
    % 4 seconds: Blank
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
    
    
    
    
    
    
    
    
    
    %% Main function: show 2-3 response words
    for seeds_i = start_line(1):numel(response) % loop through the seed words
        
        % Get ready message: waiting for a space bar
        while (1)
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('space'))==1
                break;
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            for i = 1:numel(ready_prompt{1})
                DrawFormattedText(theWindow, ready_prompt{1}{i},'center', H/2-40*(2-i), white);
            end
            Screen('Flip', theWindow);
        end
        
        for target_i = 1:numel(response{seeds_i}) % loop through the response words
            
            %% FIRST question: valence, self-relevance
            rec_i = 0;
            data.dat{seeds_i}{target_i}.val_self_trajectory = [];
            data.dat{seeds_i}{target_i}.val_self_timing = [];
            
            SetMouse((rb+lb)/2, bb); % set mouse at the center
            start_t = GetSecs;
            data.dat{seeds_i}{target_i}.start_time = start_t;
            
            while(1)
                % draw scale:
                draw_scale_170519('valance_selfrelevance');
                
                % display target word and previous words
                display_target_word(seeds_i, target_i, response);
                
                % instruction:
                Screen('TextSize', theWindow, 23);
                DrawFormattedText(theWindow,question_prompt{1}{1},'center',40, white);
                DrawFormattedText(theWindow,question_prompt{1}{2},'center',70, white);
                Screen('TextSize', theWindow, fontsize);
                
                % Track Mouse coordinate
                [x, y, button] = GetMouse(theWindow);
                
                if x < lb, x = lb;
                elseif x > rb, x = rb;
                end
                
                if y < tb, y = tb;
                elseif y > bb, y = bb;
                end
                
                % Get trajectory
                rec_i = rec_i+1; % the number of recordings
                data.dat{seeds_i}{target_i}.val_self_trajectory(rec_i,:) = vs_converter([x y], 'xy_to_ratings');
                data.dat{seeds_i}{target_i}.val_self_timing(rec_i,1) = GetSecs - start_t;
                
                % draw a line between the current location and the previous rating
                if target_i > 1 
                    xy1 = vs_converter(data.dat{seeds_i}{target_i-1}.val_self_rating, 'ratings_to_xy')';
                    Screen('DrawDots', theWindow, xy1, 7, 220, [0 0], 1);
                    Screen('DrawLines', theWindow, [xy1 [x;y]], 1.5, 220);
                end
                
                % draw a line between the previous rating and the previous^2 rating
                if target_i > 2
                    xy2 = vs_converter(data.dat{seeds_i}{target_i-2}.val_self_rating, 'ratings_to_xy')';
                    Screen('DrawDots', theWindow, xy2, 7, 120, [0 0], 1);
                    Screen('DrawLines', theWindow, [xy2 xy1], 1.5, 120);
                end
                
                Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                Screen('Flip', theWindow);
                
                if button(1)
                    data.dat{seeds_i}{target_i}.val_self_rating = vs_converter([x y], 'xy_to_ratings');
                    data.dat{seeds_i}{target_i}.val_self_RT = data.dat{seeds_i}{target_i}.val_self_timing(end) - data.dat{seeds_i}{target_i}.val_self_timing(1);
                    WaitSecs(.2);
                    break;
                end
            end
            
            %% SECOND question: time
            rec_i = 0;
            SetMouse(W/2, H/2); % set mouse at the center
            
            data.dat{seeds_i}{target_i}.time_trajectory = [];
            data.dat{seeds_i}{target_i}.time_timing = [];
            start_t = GetSecs;

            while(1)
                % draw scale:
                draw_scale_170519('time');
                
                % display target word and previous words
                display_target_word(seeds_i, target_i, response);
                
                % insturction
                Screen('TextSize', theWindow, 23);
                DrawFormattedText(theWindow,question_prompt{2}{1},'center', 70, white);
                Screen('TextSize', theWindow, fontsize);
                
                % Track Mouse coordinate
                [x, ~, button] = GetMouse(theWindow);
                
                if x < lb, x = lb;
                elseif x > rb, x = rb;
                end
                
                % Get trajectory
                rec_i = rec_i+1; % the number of recordings
                data.dat{seeds_i}{target_i}.time_trajectory(rec_i,1) = ((x-lb)./(rb-lb))*2-1;
                data.dat{seeds_i}{target_i}.time_timing(rec_i,1) = GetSecs - start_t;
                
                xy = [x; bb];
                Screen('DrawDots', theWindow, xy, 11, orange);
                Screen('Flip', theWindow);
                
                if button(1)
                    data.dat{seeds_i}{target_i}.time_rating = ((x-lb)./(rb-lb))*2-1;
                    data.dat{seeds_i}{target_i}.time_RT = data.dat{seeds_i}{target_i}.time_timing(end) - data.dat{seeds_i}{target_i}.time_timing(1);
                    
                    draw_scale_170519('time');
                    display_target_word(seeds_i, target_i, response);
                    Screen('TextSize', theWindow, 23);
                    DrawFormattedText(theWindow,question_prompt{2}{1},'center', 70, white);
                    Screen('TextSize', theWindow, fontsize);
                    Screen('DrawDots', theWindow, xy, 11, red);
                    Screen('Flip', theWindow);
                    
                    WaitSecs(.5);
                    break;
                end
            
            end
            
            %% THIRD question: body map - activate and deactivate
            rec_i = 0;
%             keyCode(keyCode==1) = 0; % init the keyCode
            SetMouse(W/2, H/2); % set mouse at the center
            
            data.dat{seeds_i}{target_i}.body_trajectory = [];
            data.dat{seeds_i}{target_i}.body_timing = [];
            data.dat{seeds_i}{target_i}.body_rating_red = [];
            data.dat{seeds_i}{target_i}.body_rating_blue = [];
            
            start_t = GetSecs;
            
            % default
            color = red;
            color_code = 1;
            
            while(1)
                % draw scale:
                Screen(theWindow, 'FillRect', bgcolor, window_rect); % reset
                Screen('PutImage', theWindow, bodymap); % put bodymap image on screen
                
                % display target word and previous words
                display_target_word(seeds_i, target_i, response);
                
                % insturction
                Screen('TextSize', theWindow, 23);
                DrawFormattedText(theWindow, question_prompt{3}{1},'center', 40, white);
                DrawFormattedText(theWindow, question_prompt{3}{2},'center', 70, white);
                Screen('TextSize', theWindow, fontsize);
                
                % Track Mouse coordinate
                [x, y, button] = GetMouse(theWindow);
                [~,~,keyCode] = KbCheck;
                
                if keyCode(KbName('r'))==1
                    color = red;
                    color_code = 1;
                    keyCode(KbName('r')) = 0;
                elseif keyCode(KbName('b'))==1
                    color = blue;
                    color_code = 2;
                    keyCode(KbName('b')) = 0;
                end
                
                % Get trajectory
                rec_i = rec_i+1; % the number of recordings
                data.dat{seeds_i}{target_i}.body_trajectory(rec_i,:) = [x y color_code button(1)];
                data.dat{seeds_i}{target_i}.body_timing(rec_i,1) = GetSecs - start_t;
                
                % current location
                Screen('DrawDots', theWindow, [x;y], 8, color, [0 0], 1);
                
                % color the previous clicked regions
                if ~isempty(data.dat{seeds_i}{target_i}.body_rating_red)
                    Screen('DrawDots', theWindow, data.dat{seeds_i}{target_i}.body_rating_red', 8, red, [0 0], 1);
                end
                
                if ~isempty(data.dat{seeds_i}{target_i}.body_rating_blue)
                    Screen('DrawDots', theWindow, data.dat{seeds_i}{target_i}.body_rating_blue', 8, blue, [0 0], 1);
                end

                Screen('Flip', theWindow);
                
                if button(1) && color_code == 1
                    data.dat{seeds_i}{target_i}.body_rating_red = [data.dat{seeds_i}{target_i}.body_rating_red; [x y]];
                elseif button(1) && color_code == 2
                    data.dat{seeds_i}{target_i}.body_rating_blue = [data.dat{seeds_i}{target_i}.body_rating_blue; [x y]];     
                end
                
                if keyCode(KbName('n'))==1
                    data.dat{seeds_i}{target_i}.body_RT = data.dat{seeds_i}{target_i}.body_timing(end) - data.dat{seeds_i}{target_i}.body_timing(1);
                    Screen(theWindow, 'FillRect', bgcolor, window_rect);
                    Screen('Flip', theWindow);
                    WaitSecs(.5);
                    break; 
                end
            end
            
        end
        
        %% Run End
        if seeds_i < numel(response)
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
            Screen('Flip', theWindow);
        end
        
        % save data
        save(fname, 'data')
        WaitSecs(1.0);
        
    end
    
    %% Experiment end message
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, exp_end_prompt, 'center', textH, white);
    Screen('Flip', theWindow);
    WaitSecs(2);
    
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

function display_target_word(seeds_i, target_i, response)

global orange theWindow response_W W;

response_W{i}{j} = Screen(theWindow, 'DrawText', double(response{i}{j}), 0, 0);

interval = 50;
y_loc = 140;

% ==== DISPLAY 2-3 RESPONSE WORDS ====

% 1. target word
target_loc = W/2-response_W{seeds_i}{target_i}/2;
Screen('DrawText', theWindow, double(response{seeds_i}{target_i}), target_loc, y_loc, orange);

% 2. Previous word
if target_i > 1
    pre_target_loc = target_loc-interval-response_W{seeds_i}{target_i-1};
    Screen('DrawText', theWindow, double(response{seeds_i}{target_i-1}), pre_target_loc, y_loc, 180);
end

% 3. Pre-Previous word
if target_i > 2
    pre_pre_target_loc = pre_target_loc-interval-response_W{seeds_i}{target_i-2};
    Screen('DrawText', theWindow, double(response{seeds_i}{target_i-2}), pre_pre_target_loc, y_loc, 130);
end

end

function xy = vs_converter(xy, type)

global lb rb bb tb;
% xy: x - xy(:,1), y - xy(:,2)
% type = 1: x, y coordinate to ratings 
% type = 2: ratings to x, y coordinate

x = xy(:,1);
y = xy(:,2);

switch type
    
    case {'xy_to_ratings'}
        x = (x-lb)./(rb-lb).*2-1;
        y = (y-tb)./(bb-tb);
    case {'ratings_to_xy'}
        x = (x+1).*(rb-lb)./2+lb;
        y = y.*(bb-tb)+tb;
end

xy = [x y];
    
end

