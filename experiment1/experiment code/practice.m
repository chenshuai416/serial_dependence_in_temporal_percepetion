clear;
clc;
rng('shuffle');

%configuration
format long;
KbName('UnifyKeyNames');
% Screen('Preference','SkipSyncTests',1);

%change distribution here
IOI     = linspace(0.54,1.26,10);%均值（500-1200）
trials  = 20;%每组200个trial
% section = 4;%每个section100

%prameters
dis        = 700;%视距
r_fix      = deg2pix(0.25,dis);
r_stimulate= deg2pix(0.75,dis);
threashold = 20;

guidepractice = imread('Practice.JPG');
guidefinish   = imread('Practicefinish.JPG');

log_initiate=ones(6,trials)*(-1);
color=[50 50 50];
c=1;
ListenChar(2);
HideCursor;

screens = Screen('Screens');
screenNumber = max(screens);
[win]=Screen('Openwindow',screenNumber,[0,0,0]);
[x, y] = Screen('WindowSize', win);
Screen('TextSize',win,50);
Screen('TextColor',win,[255,255,255]);
textureP=Screen('MakeTexture', win, guidepractice);
textureF=Screen('MakeTexture', win, guidefinish);

Screen('DrawTexture', win, textureP);
Screen(win,'Flip');
goon=0;

%读取mask
for s=1:20
    stimulate_im(s).im=imread(strcat('Stimulate',mat2str(s),'.jpg'));
end
for s=1:20
    textStimulate(s).im=Screen('MakeTexture', win, stimulate_im(s).im);
end

while goon~=1
    [keyIsDown,seconds,keyCode]=KbCheck;
    if keyIsDown
        goon=1;
    end
end

theta_log = zeros(2,trials);
theta = [Shuffle(linspace(1,360,trials));Shuffle(linspace(1,180,trials))];
theta_log(:,:) = theta;

sti_order = Shuffle(1:20);
iois = repmat(IOI,[1,trials/length(IOI)]);
iois = Shuffle(iois); %%要不要counterbalance
delay = repmat([0,1,3,6],[1,5]);
delay = Shuffle(delay);

%产生注视点
Screen('FillOval',win,color*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);
Screen(win,'Flip');

for i=1:trials
    angle1 = theta(1,i);
    angle2 = theta(2,i);
    noStimulate = sti_order(i);
    
    tic
    wait = min(exprnd(2)/10+0.75,1.25);
    while toc<wait;end
    %呈现第一个刺激
    Screen('DrawTexture', win, textStimulate(noStimulate).im);
    Screen('FillArc',win,[0,0,0],[0.5*x-r_fix-500 0.5*y-r_fix-500 0.5*x+r_fix+500 0.5*y+r_fix+500],angle1,270)
    Screen('FillOval',win,color.*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
    t1 = Screen(win,'Flip',0);
    %产生注视点
    Screen('FillOval',win,color.*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
    t1 = Screen(win,'Flip',t1+0.1);
    %呈现第二个刺激
    Screen('DrawTexture', win, textStimulate(noStimulate).im);
    Screen('FillArc',win,[0,0,0],[0.5*x-r_fix-500 0.5*y-r_fix-500 0.5*x+r_fix+500 0.5*y+r_fix+500],angle1+90+angle2,270)
    Screen('FillOval',win,color*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
    t1 = Screen(win,'Flip',t1+iois(i));
    %产生注视点
    Screen('FillOval',win,color.*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
    t1 = Screen(win,'Flip',t1+0.1);
 
    %产生十字注视点
    Screen('DrawLine',win,color*1.5, 0.5*x, 0.5*y-r_fix, 0.5*x, 0.5*y+r_fix,5);
    Screen('DrawLine',win,color*1.5, 0.5*x-r_fix, 0.5*y, 0.5*x+r_fix, 0.5*y,5);
    Screen(win,'Flip',t1+delay(i));

    %被试第一次按键
    goon=0;
    while goon~=1
        [keyIsDown,rt1,keyCode]=KbCheck();
        if keyIsDown
            if find(keyCode)==32 %space
                goon=1;
                while KbCheck;end
            elseif find(keyCode)==27 %esc
                goon=1;
                c=0;
            end
        end
    end
    %被试第二次按键
    goon = 0;
    while goon~=1
        [keyIsDown,rt2,keyCode]=KbCheck;
        if keyIsDown
            if find(keyCode)==32 %space
                goon=1;
                while KbCheck;end
            elseif find(keyCode)==27 %esc
                goon=1;
                c=0;
            end
        end
    end
    rt = rt2 - rt1;
    
    %计算error rate 产生feedback
    error_rate=round((abs(rt-iois(i))/iois(i))*100);
    if error_rate<threashold
        Screen('FillOval',win,[0,100,0],[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
        t2=Screen(win,'Flip');
        if threashold>2
            threashold=threashold-1.5;
        end
        log_initiate(6,i)=1;
    else
        Screen('FillOval',win,[80,0,0],[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
        t2=Screen(win,'Flip');
        if threashold<25
            threashold=threashold+1.5;
        end
        log_initiate(6,i)=0;
    end
    Screen('FillOval',win,color*1.5,[0.5*x-r_fix 0.5*y-r_fix 0.5*x+r_fix 0.5*y+r_fix]);%产生注视点
    Screen(win,'Flip',t2+0.1);
    %1:standard duration; 2-4:rt; 5:error rate; 6:feedback
    log_initiate(1,i)=iois(i);
    log_initiate(2,i)=rt1;
    log_initiate(3,i)=rt2;    
    log_initiate(4,i)=rt;
    log_initiate(5,i)=error_rate;
    
    if c==0
        break
    end
end

Screen('DrawTexture', win, textureF);
Screen(win,'Flip');
KbWait;
Screen('CloseAll');
ListenChar(1);
ShowCursor;
accuracy = mean(log_initiate(5,:));
fprintf('Your accuracy in Practice is : %10.9f\n',accuracy)

