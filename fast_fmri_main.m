function data = fast_fmri_main(varargin)

% 


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

response = '';
testmode = false;
savedir = fullfile(pwd, 'data');
psychtoolboxdir = '/Users/clinpsywoo/Documents/MATLAB/Psychtoolbox';
scriptdir = '/Users/clinpsywoo/Dropbox/W_FAST/script';

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
            case {'psychtoolbox'}
                psychtoolboxdir = varargin{i+1};
            case {'scriptdir'}
                scriptdir = varargin{i+1};
            case {'response'}
                response = varargin{i+1};
        end
    end
end

cd(scriptdir);

%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor response_W; % color
global fontsize window_rect lb rb tb bb anchor_xl anchor_xr anchor_yu anchor_yd scale_H; % rating scale

%% SETUP: Screen

addpath(genpath(psychtoolboxdir));

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

% ready for body map
bodymap = imread('imgs/bodymap_bgcolor.jpg');
bodymap = bodymap(:,:,1);
[body_y, body_x] = find(bodymap(:,:,1) == 255);

bodymap([1:10 791:800], :) = [];
bodymap(:, [1:10 1271:1280]) = []; % make the picture smaller 

%% SETUP: DATA and Subject INFO

[fname, start_line, SID] = subjectinfo_check(savedir, 'survey'); % subfunction
if exist(fname, 'file'), load(fname, 'data'); end

if isempty(response)
    dat_file= fullfile(savedir, ['taskdata_s' SID '.mat']);
    load(dat_file); % load data
    response = out.response;
    clear out;
end

% save data using the canlab_dataset object
data.version = 'FAST_survey_v1_05-19-2017';
data.subject = SID;
data.datafile = fname;
data.starttime = datestr(clock, 0); % date-time
data.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial

% initial save of trial sequence
save(data.datafile, 'response', 'data');


%% Survey start

% try
    % START: Screen
    % whichScreen = max(Screen('Screens'));
	theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    HideCursor;
    Screen('TextFont', theWindow, font); % setting font
    Screen('TextSize', theWindow, fontsize);
    
    %% Prompts
    
    ready_prompt{1}{1} = double('다음에 주어지는 질문에 솔직하게 대답해주세요.');
    ready_prompt{1}{2} = double('앞 단어와 연결되어 있는 맥락을 고려해서 대답해주시면 됩니다.');
    ready_prompt{1}{3} = double('준비되셨으면 스페이스바를 눌러주세요.');
    
    question_prompt{1}{1} = double('가로축: 단어에서 느껴지는 감정 (부정-긍정)');
    question_prompt{1}{2} = double('세로축: 나와의 관련성 (관련없음-관련많음)');
    question_prompt{2}{1} = double('이 단어는 시간적으로 과거-현재-미래의 축에서 어디쯤 위치할까요?');
    question_prompt{3}{1} = double('이 단어를 생각할 때, 활동이 ''증가''(빨강:r)되거나 ''감소''(파랑:b)되는 몸의 부위가 어디인가요?');
    question_prompt{3}{2} = double('클릭한 채로 움직이면 색칠이 됩니다. 색칠이 끝나면 n을 눌러주세요.');
    
    run_end_prompt = double('잘하셨습니다. 다음 단어 세트를 기다려주세요.');
    exp_end_prompt = double('설문을 마치셨습니다. 감사합니다!');
    
    % W and H for seed words
    for i = 1:numel(response)
        for j = 1:numel(response{i})
            response_W{i}{j} = Screen(theWindow, 'DrawText', double(response{i}{j}), 0, 0);
        end
    end
    
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
    
    
% catch err
%     % ERROR 
%     disp(err);
%     disp(err.stack(end));
%     abort_experiment('error'); 
% end

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

