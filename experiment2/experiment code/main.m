%%%%%%%%%%%%%%%%%%%%%%%%% experiment 4 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%  two phase task 1:reproduction 2:2AFC %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% General Settings
clear all;
clc;
commandwindow;
Screen('Preference', 'SkipSyncTests', 0);%0
addpath('Instructions');
addpath('figures');
rng('Shuffle'); % shuffle the randome number seed every time when matlab restarts

%% Startup Questions and Data File %% always start from practice and informaion entering
Prompt = {'Subject Number', 'Name', 'Age', 'Gender: (M for male, F for female)'};
DlgTitle = 'Subject Info';
NumLines = 1;
Answer = inputdlg(Prompt, DlgTitle, NumLines);
SubjID = Answer{1};
SubjName = Answer{2};
SubjAge = str2double (Answer{3});
SubjGender = Answer{4};

%%experiment setup
NumBlocks = 8;
Trials   = 600;
trialpblock = Trials/NumBlocks;
%% Screen Properties
V_dist=70; %70  % visual distance in cm
ScreenNumber = max(Screen('Screens'));
[ResX, ResY] = Screen('WindowSize',ScreenNumber);

Moni_X=64; %60 % monitor width in cm
Moni_Y=38; %33 % monitor height in cm

Cen_X=ResX/2;
Cen_Y=ResY/2;
background_color=[0 0 0]; %black

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
guideExp=imread('Exp.JPG');
guideRest=imread('Rest.JPG');
guideGoon=imread('Goon.JPG');
guideExp_Over=imread('Exp_Over.JPG');
questionmark=imread('questionmark.JPG');

textureGuide=Screen('MakeTexture', wPtr, guide);
textureExp=Screen('MakeTexture', wPtr, guideExp);
textureRest=Screen('MakeTexture', wPtr, guideRest);
textureGoon=Screen('MakeTexture', wPtr, guideGoon);
textureExp_Over=Screen('MakeTexture', wPtr, guideExp_Over);
textureQM=Screen('MakeTexture', wPtr, questionmark);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% STIM VARIABLES %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �?要改ISI_reproduce STI
ISI_reproduce = linspace(0.4,1.2,5);
Interval = Shuffle(repmat(ISI_reproduce,1,Trials/5));%phase1 standard duration

STI(:,1) = [repmat([.8],1,Trials*5/6),repmat([.4],1,Trials/12),repmat([1.2],1,Trials/12)];%%phase2 standard duration
STI(:,2) = repmat([.4:.2:1.2],1,Trials/5); %%phase2 compare duration
r = randperm(size(STI,1));
STI = STI(r,:);
ITI  = 1; %inter trial interval
IPI  = .5; %inter phase interval
ISI  = .5; %inter stimulus iterval
RestTime = 60; % rest time within interBlocks
% size /diameter
FixOvalSize = deg2pix(0.5,Moni_X,ResX,V_dist); %fixation size
StiSize = deg2pix(20,Moni_X,ResX,V_dist); %30 stimuli size

% color and keys
Grey   =     125;
KbName('UnifyKeyNames');
secondshort = KbName('s');
secondlong = KbName('l');
quit = KbName('escape');
EXIT = 0 ;
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
Screen('DrawTexture', wPtr, textureExp);
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
    Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %fixation cross
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
    %fixation point
    [CircleRect_PointList] = CircleRect_4pointList (Cen_X , Cen_Y, FixOvalSize);
    Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
    currTime = Screen('Flip',wPtr,currTime); % fixation duration
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
    if ~mod(i,trialpblock) && (i~=Trials)
        P1_correctness=1-mean(abs((logg(i-74:i,2)-logg(i-74:i,1))./logg(i-74:i,1)));
%         P2_correctness=sum((logg(i-74:i,4)<=logg(i-74:i,5))==logg(i-74:i,6))/75;
%         P2_correctness=(mean((logg(i-74:i,5)>logg(i-74:i,4)) & logg(i-74:i,6)==1)+mean((logg(i-74:i,5)<logg(i-74:i,4)) & logg(i-74:i,6)==0))/2;
        P2_correctness=(mean(logg((logg(:,5)>logg(:,4)),6)==1)+mean(logg((logg(:,5)<logg(:,4)),6)==0))/2;
        text1 = strcat('Phase 1 accuracy in this block: ',num2str(round(P1_correctness*100)),'%');
        text2 = strcat('Phase 2 accuracy in this block: ',num2str(round(P2_correctness*100)),'%');
        Screen('DrawText', wPtr, text1,Cen_X-200,Cen_Y-100,Grey);
        Screen('DrawText', wPtr, text2,Cen_X-200,Cen_Y,Grey);
        Screen('Flip',wPtr);
        KbWait;
        Screen('DrawTexture',wPtr,textureRest);
        Screen('Flip',wPtr);
        WaitSecs(RestTime);
        Screen('DrawTexture',wPtr,textureGoon);
        Screen('Flip',wPtr);
        KbWait;
    end
end
logg_fil = logg(logg(:,4)==.8,:);
Screen('DrawTexture',wPtr,textureExp_Over);
Screen('Flip',wPtr);
WaitSecs(.5)
KbWait;
Screen('CloseAll');
ListenChar(1);
ShowCursor;
%%calculate the catch trial corrent rate

%% save file
data_dir = 'RawData\';
DataFileName = sprintf('%s%s%d%s%s%s%s%s',data_dir,'Sub',str2num(SubjID),'_',SubjName,'\');% suject data file name, e.g. ...\Data\Sub1_x_1-Jan-2016\
if ~exist(DataFileName) 
    mkdir(DataFileName);
end
save([DataFileName,strcat('Data_', SubjID,'_',SubjName,'.mat')])
save([DataFileName,'subj_info.mat'], 'SubjName', 'SubjID', 'SubjAge', 'SubjGender', 'DataFileName'); % save file to directory 'DataFileName'
% fprintf('total accuracy: %f.\n',round(100-Result_List(:,8)));