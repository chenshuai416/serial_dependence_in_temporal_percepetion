%%%%%%%%%%%%%%%%%%%%%%%%% experiment 3 %%%%%%%%%%%%%%%%%%%%%%%%%
%%%  serial dependence in different spatial location %%%%%%%%%%%
%%%  Eccen = 7 or 21                                 %%%%%%%%%%%
%% General Settings
clear all;
clc;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);%0
KbName('UnifyKeyNames');
addpath('Instructions');
addpath('figures');
rng('Shuffle'); % shuffle the randome number seed every time when matlab restarts
% experiment setup
Eccen = 7;
NumBlocks = 1;
Trials   = 10;
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


% Instruction
guidePrac=imread('Prac.JPG');
guidePrac_Over=imread('Prac_Over.JPG');

texturePrac=Screen('MakeTexture', wPtr, guidePrac);
texturePrac_Over=Screen('MakeTexture', wPtr, guidePrac_Over);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% STIM VARIABLES %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ISI = linspace(0.54,1.26,10); %standard duration
threshold_left = 30;
threshold_right = 30;
RestTime = 60; % rest time within interBlocks

% size /diameter
FixOvalSize = deg2pix(0.5,Moni_X,ResX,V_dist); %fixation size
StiSize = deg2pix(20,Moni_X,ResX,V_dist); %30 stimuli size
EccDis = deg2pix(Eccen,Moni_X,ResX,V_dist); %eccentricity

% color
Red    =     [80,0,0];
Green  =     [0,100,0];
Grey   =     125;

%% %%%%%%%%%%%%%%%%%%% Instruction %%%%%%%%%%%%%%%%%%
%实验指导�?
Screen('DrawTexture', wPtr, texturePrac);
Screen('Flip', wPtr);
goon=0;
while ~goon
    [keyIsdown, keyTime, keyCode] = KbCheck;
    if (keyIsdown && (find(keyCode)==KbName('space')) )
        goon=1;
    end
end

%% Start Block/Design
Result_List=[];
Sti_Order_Log = [];
Exit = 0;

for Block =1 : NumBlocks
    
    % Design matrix for exp blocks, Conditions 1,2,3,4,...
    Conditions(:,1) = reshape(repmat([-1,1],100,1), 200, 1); % location -1 left, 1 right
    Conditions(:,2) = repmat([1:10]', 20, 1); % interval index
    
    % Shuffle the rows
    % e.g.Conditions = Shuffle(Conditions,2);
    Sum_Trials= size(Conditions,1);
    Conditions = Conditions(randperm(Sum_Trials),:);
    
    % stimuli related
    Sti_Order = Shuffle(repmat(1:20,1,10)); % 200 trials
    Sti_Order_Log(Block, :) = Sti_Order;
    
    for Trial = 1:Trials
        % get trial variables
        FixDur(Trial) = min(exprnd(2)/10+0.75,1.25); %中心注视点到左右侧注视点出现的间�?
        Loc(Trial) = Conditions(Trial,1);%当前是左侧刺�?还是右侧刺激
        Interval_Index = Conditions(Trial,2);%标准时长的编�?
        Interval(Trial) = ISI(Interval_Index);%标准时长
        No_Stimuli(Trial) = Sti_Order(1,Trial);%图形编号
        
        % center fixation
        Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
        currTime = Screen('Flip',wPtr);
        
        % left cue presentation
        if Loc(Trial) == -1
            % stimulus presentation
            [ sourceRect] = [(img_x-img_y)/2 0 (img_x-img_y)/2+img_y img_y];
            [ destiRect] = CircleRect_4pointList (Cen_X + Loc(Trial)*EccDis, Cen_Y, img_y/2);
            Screen('DrawTexture', wPtr, textStimuli(No_Stimuli(Trial)).im, [sourceRect],[destiRect]);
            [ CircleRect_PointList] = CircleRect_4pointList (Cen_X + Loc(Trial)*EccDis, Cen_Y, FixOvalSize);
            Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
            Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); % center cross point
            currTime = Screen('Flip',wPtr,currTime+FixDur(Trial)); % fixation duration
            
            
            % right cue presentation
        elseif Loc(Trial) == 1
            [ sourceRect] = [(img_x-img_y)/2 0 (img_x-img_y)/2+img_y img_y];
            [ destiRect] = CircleRect_4pointList (Cen_X + Loc(Trial)*EccDis, Cen_Y, img_y/2);
            Screen('DrawTexture', wPtr, textStimuli(No_Stimuli(Trial)).im, [sourceRect],[destiRect]);
            [ CircleRect_PointList] = CircleRect_4pointList (Cen_X + Loc(Trial)*EccDis, Cen_Y, FixOvalSize);
            Screen('FillOval', wPtr, Grey, CircleRect_PointList); % fixation point
            Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); % opposite cross point
            currTime = Screen('Flip',wPtr,currTime+FixDur(Trial)); % fixation duration
        end
        % central fixation
        Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
        currTime = Screen('Flip',wPtr,currTime+Interval(Trial)-slack); %
        
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
                    Exit=1;
                end
            end
        end
        rt=seconds-currTime;
        
        %feedback based on the different sides
        error_rate=round((abs(press_time-Interval(Trial))/Interval(Trial))*100);
        if Loc(Trial) == -1 && error_rate<threshold_left %left correct
            feedback = 1;
            Fixation_cross(wPtr,Cen_X,Cen_Y,Green,FixOvalSize); %
            currTime = Screen('Flip',wPtr,[]); %
            if threshold_left>2
                threshold_left=threshold_left-1.5;
            end
        elseif  Loc(Trial) == 1 && error_rate<threshold_right %right correct
            feedback = 1;
            Fixation_cross(wPtr,Cen_X,Cen_Y,Green,FixOvalSize);
            currTime = Screen('Flip',wPtr,[]);
            if threshold_right>2
                threshold_right=threshold_right-1.5;
            end
        elseif  Loc(Trial) == -1 && error_rate >= threshold_left   %left wrong
            feedback = 0;
            Fixation_cross(wPtr,Cen_X,Cen_Y,Red,FixOvalSize);
            currTime = Screen('Flip',wPtr,[]);
            if threshold_left<50
                threshold_left=threshold_left+1.5;
            end
        elseif  Loc(Trial) == 1 && error_rate >= threshold_right %right wrong
            feedback = 0;
            Fixation_cross(wPtr,Cen_X,Cen_Y,Red,FixOvalSize);
            currTime = Screen('Flip',wPtr,[]);
            if threshold_right<50
                threshold_right=threshold_right+1.5;
            end
        end
        
        %fixation
        Fixation_cross(wPtr,Cen_X,Cen_Y,Grey,FixOvalSize); %
        currTime = Screen('Flip',wPtr,currTime+0.1); %
        [keyIsDown,seconds,keyCode]=KbCheck;
        if keyIsDown
            if  find(keyCode)==27
                Exit=1;
            end
        end
        
        % save trial result
        result_trial=[Block, Trial, ...
            Loc(Trial), Interval_Index, Interval(Trial), ...
            press_time, rt, error_rate, feedback];
        Result_List = [Result_List; result_trial];
        if Exit
            break;
        end
    end % end of trial loop
    
% 
%     Screen('DrawTexture', wPtr, texturePrac_Over);
%     Screen('Flip',wPtr);
%     goon=0;
%     while ~goon
%         [keyIsDown, keyTime,keyCode]=KbCheck;
%         if keyIsDown
%             if find(keyCode)==32
%                 goon=1;
%             elseif find(keyCode)==27
%                 goon=1;
%                 Exit=1;
%             end
%         end
%     end
    acc = mean(Result_List(:,8));
    text = strcat('Your practice accuracy: ',num2str(100-acc),'%');
    Screen('DrawText', wPtr, text,Cen_X-200,Cen_Y,Grey+[255 255 255].*acc/100);
    Screen('Flip',wPtr);
    goon=0;
    while ~goon
        [keyIsDown, keyTime,keyCode]=KbCheck;
        if keyIsDown
            if find(keyCode)==32
                goon=1;
            elseif find(keyCode)==27
                goon=1;
                Exit=1;
            end
        end
    end
    
    if Exit
        break;
    end
end
Screen('CloseAll');
ListenChar(1);
ShowCursor;
fprintf('Your practice accuracy is %f.\n',100-mean(Result_List(:,8)));