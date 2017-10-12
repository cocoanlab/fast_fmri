bgcolor = 100;

window_rect = get(0, 'MonitorPositions'); % full screen
if size(window_rect,1)>1
        window_rect = window_rect(1,:);
end

theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
W = window_rect(3); %width of screen
H = window_rect(4); %height of screen

%%
square = [0 0 130 60];
r=350;
t=360/28;
theta=[t, t*3, t*5, t*7, t*9, t*11, t*13, t*15, t*17, t*19, t*21, t*23, t*25, t*27];
xy=[W/2+r*cosd(theta(1)) H/2-r*sind(theta(1)); W/2+r*cosd(theta(2)) H/2-r*sind(theta(2)); ...
    W/2+r*cosd(theta(3)) H/2-r*sind(theta(3)); W/2+r*cosd(theta(4)) H/2-r*sind(theta(4));...
    W/2+r*cosd(theta(5)) H/2-r*sind(theta(5)); W/2+r*cosd(theta(6)) H/2-r*sind(theta(6));...
    W/2+r*cosd(theta(7)) H/2-r*sind(theta(7)); W/2+r*cosd(theta(8)) H/2-r*sind(theta(8));...
    W/2+r*cosd(theta(9)) H/2-r*sind(theta(9)); W/2+r*cosd(theta(10)) H/2-r*sind(theta(10));...
    W/2+r*cosd(theta(11)) H/2-r*sind(theta(11)); W/2+r*cosd(theta(12)) H/2-r*sind(theta(12));...
    W/2+r*cosd(theta(13)) H/2-r*sind(theta(13)); W/2+r*cosd(theta(14)) H/2-r*sind(theta(14))];

colors = 230;

%% text

choice{1}{1} = double('���');
choice{1}{2} = double('���ο�');
choice{1}{3} = double('���');
choice{1}{4} = double('�η���');
choice{1}{5} = double('����');
choice{1}{6} = double('�Ǹ�');
choice{1}{7} = double('�ںν�');
choice{1}{8} = double('�β�����');
choice{1}{9} = double('��ȸ');
choice{1}{10} = double('����');
choice{1}{11} = double('�г�');
choice{1}{12} = double('���');
choice{1}{13} = double('�̿�');
choice{1}{14} = double('����');

z=randperm(numel(theta));


%%
SetMouse(W/2, H/2); % set mouse at the center

while(1)
    for i = 1:numel(theta)
        Screen('FrameRect', theWindow, colors', CenterRectOnPoint(square,xy(i,1),xy(i,2)),3);
    end
    
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    font = 'NanumBarunGothic';
    fontsize = 30;
    Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize);
    
    for i = 1:numel(choice{1})
        DrawFormattedText(theWindow, choice{1}{z(i)},'center', 'center', colors, [],[],[],[],[],...
            [xy(i,1)-square(3)/2, xy(i,2)-square(4)/2-15, xy(i,1)+square(3)/2, xy(i,2)+square(4)/2]);
    end
    
    [x, y, button] = GetMouse(theWindow);
%     if (x-W/2)^2+(y-H/2)^2<=r^2,
%         alpha = acos((x-W/2)/sqrt((x-W/2)^2+(y-H/2)^2));
%         if y <= 450,
%             x=W/2+r*cos(alpha);
%             y=H/2-r*sin(alpha);
%         else 
%             x=W/2+r*cos(alpha+pi);
%             y=H/2-r*sin(alpha+pi);
%         end
%     end
    
    Screen('Flip', theWindow); 
    
    if button(1)
        break;
    end
end

% KbWait;
Screen('CloseAll');