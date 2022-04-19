%%%%%%%%%%%%%%%%%%%%%%%%% experiment 4 practice %%%%%%%%%%%%%%%%%%%%%%%%%
%%%  two phase task 1:reproduction 2:2AFC %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% General Settings
clear all;
clc;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);%0
addpath('Instructions');
addpath('figures');
rng('Shuffle'); % shuffle the randome number seed every time when matlab restarts

%%
NumBlocks = 1;
Trials   = 20;
trialpblock = Trials/NumBlocks;
%% Screen Properties
V_dist=70; %70  % visual distance in cm
ScreenNumber = max(Screen('Screens'));
[ResX, ResY] = Screen('WindowSize',ScreenNumber);

Moni_X=64; %60 % monitor width in cm
Moni_Y=38; %33 % monitor height in cm

Cen_X=ResX/2;
Cen_Y=ResY/2;

% color and keys
background_color=[0 0 0]; %black
Grey   =     125;
KbName('UnifyKeyNames');
secondshort = KbName('s');
secondlong = KbName('l');
quit = KbName('escape');
EXIT = 0 ;

% Open initial screen and initiate OpenGL for faster drawing
AssertOpenGL;
[wPtr,screenRect] = Screen('OpenWindow',ScreenNumber,background_color,[],[],2);
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
slack=Screen('GetFlipInterval',wPtr)/2;
refresh=Screen('FrameRate', wPtr);     % get the refresh rate of Screen in Hz.
ListenChar(2);
HideCursor;

%% Figure Import
for s=1:20
    stimuli_im(s).im=imread(strcat('Stimulate',mat2str(s),'.jpg'));
end
for s=1:20
    textStimuli(s).im=Screen('MakeTexture', wPtr, stimuli_im(s).im);
end
img_x=size(stimuli_im(1).im,2);
img_y=size(stimuli_im(1).im,1);
Sti_Order(1,:) = Shuffle(repmat(1:20,1,Trials/20));
Sti_Order(2,:) = Shuffle(repmat(1:20,1,Trials/20));
Sti_Order(3,:) = Shuffle(repmat(1:20,1,Trials/20));

% Instruction
guide=imread('instructions.JPG');
PracEnd=imread('Prac_Over.JPG');
questionmark=imread('questionmark.JPG');
textureGuide=Screen('MakeTexture', wPtr, guide);
texturePracEnd=Screen('MakeTexture', wPtr, PracEnd);
textureQM=Screen('MakeTexture', wPtr, questionmark);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% STIM VARIABLES %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �?要改ISI_reproduce STI
ISI_reproduce = linspace(0.4,1.2,5);
Interval = Shuffle(repmat(ISI_reproduce,1,Trials/5));%phase1 standard duration

STI(:,1) = repmat([.8],1,Trials);%%phase2 standard duration
STI(:,2) = repmat([.4:.2:1.2],1,Trials/5); %%phase2 compare duration
r = randperm(size(STI,1));
STI = STI(r,:);
ITI  = 1; %inter trial interval
IPI  = .5; %inter phase interval
ISI  = .5; %inter stimulus iterval

% size /diameter
FixOvalSize = deg2pix(0.5,Moni_X,ResX,V_dist); %fixation size
StiSize = deg2pix(20,Moni_X,ResX,V_dist); %30 stimuli size

%% %%%%%%%%%%%%%%%%%%% Instruction %%%%%%%%%%%%%%%%%%
Screen('DrawTexture', wPtr, textureGuide);
Screen('Flip', wPtr);
WaitSecs(.5)
goon=0;
while ~goon
    [keyIsdown, keyTime, keyCode] = KbCheck;
    if (keyIsdown && (find(keyCode)==KbName('space')) )
        goon=1;
    end
end

for i=1:Trials
    %% phase 1 reproduce task
    currTime=Screen('Flip',wPtr);
    % center fixation
    FixDur = min(exprnd(2)/10+0.5,1);

    Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
    currTime = Screen('Flip',wPtr,currTime+ITI-slack);
    % stimulus1 presentation
    [ sourceRect] = [(img_x-img_y)/2 0 (img_x-img_y)/2+img_y img_y];
    [ destiRect] = CircleRect_4pointList (Cen_X, Cen_Y, img_y/2);
    Screen('DrawTexture', wPtr, textStimuli(Sti_Order(1,i)).im, [sourceRect],[destiRect]);
%     [ CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
%     Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
    Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
    currTime = Screen('Flip',wPtr,currTime+FixDur-slack); % fixation duration
    % reproduce cue
    Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
    currTime = Screen('Flip',wPtr,currTime+Interval(i)-slack);
    % record key response
    goon=0;
    press_time=0;
    while goon~=1
        [keyIsDown,seconds,keyCode]=KbCheck;
        if keyIsDown
            tic
            if find(keyCode)==32
                goon=1;
                while KbCheck;end
                press_time = toc ;
                
            elseif find(keyCode)==27
                goon=1;
                EXIT=1;
            end
        end
    end
    
    if EXIT
        break;
    end
    
    rt1=seconds-currTime;
    
    %% phase 2 2AFC task
%   currTime = Screen('Flip',wPtr);
%     FixDur = min(exprnd(2)/10+0.75,1.25);
    %fixation point
    [CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
    Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
%     currTime = Screen('Flip',wPtr,currTime+IPI-slack); % fixation duration
    currTime = Screen('Flip',wPtr); % fixation duration
    % stimulus1 presentation
    [ sourceRect] = [(img_x-img_y)/2 0 (img_x-img_y)/2+img_y img_y];
    [ destiRect] = CircleRect_4pointList (Cen_X, Cen_Y, img_y/2);
    Screen('DrawTexture', wPtr, textStimuli(Sti_Order(1,i)).im, [sourceRect],[destiRect]);
    [ CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
    Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
    currTime = Screen('Flip',wPtr,currTime+IPI-slack); % fixation duration
    %fixation point
    [ CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
    Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
    currTime = Screen('Flip',wPtr,currTime+STI(i,1)-slack);
    % stimulus2 presentation
    [ sourceRect] = [(img_x-img_y)/2 0 (img_x-img_y)/2+img_y img_y];
    [ destiRect] = CircleRect_4pointList (Cen_X, Cen_Y, img_y/2);
    Screen('DrawTexture', wPtr, textStimuli(Sti_Order(2,i)).im, [sourceRect],[destiRect]);
    [ CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
    Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
    currTime = Screen('Flip',wPtr,currTime+ISI-slack); % fixation duration
    % compare cue
    Screen('DrawTexture', wPtr, textureQM);
    currTime = Screen('Flip',wPtr,currTime+STI(i,2)-slack);
    % record key response
    while 1
        [KeyIsDown,KeyTime,KeyCode]=KbCheck;
        if any([KeyCode(secondshort),KeyCode(secondlong),KeyCode(quit)])
            ktime=GetSecs;
            break;
        end
    end
    
    if KeyCode(quit)
        goon=1;
        EXIT=1;
    elseif KeyCode(secondshort)
        goon=1;
        response=0;
    elseif KeyCode(secondlong)
        goon=1;
        response=1;
    end
    while KbCheck ; end
    
    rt2 =ktime-currTime;
    if EXIT
        break;
    end
    logg(i,1)= Interval(i);
    logg(i,2)= press_time;
    logg(i,3)= rt1;
    logg(i,4)= STI(i,1); %compare duration
    logg(i,5)= STI(i,2); %standard duration
    logg(i,6)= response; %0 第二个更�? 1 第二个更�?
    logg(i,7)= rt2;%反应�?
   
    % fprintf('total accuracy: %f.\n',round(100-Result_List(:,8)));
end
if i==1
P1_correctness=0;
P2_correctness=0;
else
P1_correctness=1-mean(abs((logg(:,2)-logg(:,1))./logg(:,1)));
P2_correctness=(mean(logg((logg(:,5)>logg(:,4)),6)==1)+mean(logg((logg(:,5)<logg(:,4)),6)==0))/2;
end
text1 = strcat('Phase 1 accuracy in practice: ',num2str(round(P1_correctness*100)),'%');
text2 = strcat('Phase 2 accuracy in practice: ',num2str(round(P2_correctness*100)),'%');
text3 = 'Press SPACEBAR to continue...';
Screen('DrawText', wPtr, text1,Cen_X-200,Cen_Y-100,Grey);
Screen('DrawText', wPtr, text2,Cen_X-200,Cen_Y,Grey);
Screen('DrawText', wPtr, text3,Cen_X-200,Cen_Y+100,Grey);
Screen('Flip',wPtr);
WaitSecs(.5)
KbWait;

Screen('DrawTexture',wPtr,texturePracEnd);
Screen('Flip',wPtr);
WaitSecs(.5)
KbWait;
Screen('CloseAll');
ListenChar(1);
ShowCursor;
