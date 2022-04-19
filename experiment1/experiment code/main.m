clear;
clc;
promptParameters = {'Subject ID','Subject Name', 'Gender (F or M?)','Age','delay'};
defaultParameters = {'99', 'Alice','F', '25','0'};
Subinfo = inputdlg(promptParameters, 'Subject Info  ', 1, defaultParameters);
id        = Subinfo{1};    % collect participant ID.
subName   = Subinfo{2};
subGender = Subinfo{3};
subAge    = Subinfo{4};
delay     = str2num(Subinfo{5});
%configuration
format long;
KbName('UnifyKeyNames');
Screen('Preference','SkipSyncTests',1);
  
%change distribution here
IOI     = linspace(0.54,1.26,10);%均值（500-1200）
trials  = 200;%每组200个trial
% section = 4;%每个section100

%prameters
dis        = 700;%视距
r_fix      = deg2pix(0.25,dis);
r_stimulate= deg2pix(0.75,dis);
threashold = 20;

guide=imread('starter.JPG');
guidefinish=imread('finish.JPG');

log_initiate=ones(6,trials)*(-1);
color=[50 50 50];
c=1;

ListenChar(2);
HideCursor;
% Screen('Preference', 'SkipSyncTests', 1);

screens = Screen('Screens');
screenNumber = max(screens);
[win]=Screen('Openwindow',1,[0,0,0]);
[x, y] = Screen('WindowSize', win);
% [w_pix]=Screen('WindowSize',screenNumber);
% w_size=Screen('DisplaySize',screenNumber);
% sca


Screen('TextSize',win,50);
Screen('TextColor',win,[255,255,255]);
textureG=Screen('MakeTexture', win, guide);
textureF=Screen('MakeTexture', win, guidefinish);
Screen('DrawTexture', win, textureG);
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

sti_order = Shuffle(repmat(1:20,[1,trials/20]));
iois = repmat(IOI,[1,trials/length(IOI)]);
iois = Shuffle(iois); %%要不要counterbalance

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
    t0 = Screen(win,'Flip',t1+delay);
    
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
    log_initiate(2,i)=t0;
    log_initiate(3,i)=rt1;
    log_initiate(4,i)=rt2;    
    log_initiate(5,i)=rt;
    log_initiate(6,i)=error_rate;
    
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

cd '..\Rawdata'
save(strcat('Data_', id,subName,'_delay_',mat2str(delay)),'log_initiate')
cd '..\experiment code'

accuracy=100-mean(log_initiate(6,:));
fprintf('Your accuracy in this session is : %10.9f\n',accuracy)
% m=log_initiate;
% finder=find(m(4,:)<0.25);
% m(:,finder)=[];
% finder2=find(m(4,:)>1.5);
% m(:,finder2)=[];
% 
% group = 10;
% bias=zeros(2,group);
% vari=zeros(2,group);
% ioi_list=sort(unique(iois));
% for i = 1:group
%     ioi=ioi_list(i);
%     inde=find(m(1,:)==ioi);
%     vari(1,i)=ioi;
%     bias(1,i)=ioi;
%     bias(2,i)=mean(m(4,inde))-ioi;
%     vari(2,i)=var(m(4,inde));
% end
% bia=rms(bias(2,:));
% va= nanmean((vari(2,:)));
% accuracy=mean(m(4,:));
% %report
% fprintf('bias: %10.9f\n',bia)
% fprintf('variance: %10.9f\n',va)
% 
