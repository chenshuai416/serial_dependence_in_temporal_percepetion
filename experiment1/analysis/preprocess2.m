%preprocess for n-1 trial
clear all
cd('C:\Experiment\experiment2\Rawdata');
sub = 16;
condition = 4; % 0/1/3/6
for prev = 2:10
    for index = 1:sub
        path = strcat('.\Sub',num2str(index));
        cd(path);
        file = dir(strcat('*_0.mat')); %0s
        load(file.name);
        data = log_initiate';
        %%%1: current ST
        %%%2: cross onset(to be check)
        %%%3: first button press
        %%%4: second button press
        %%%5: reproduced duration
        %%%6: error rate
        %%%7: ST in previous trial
        data(:,7)   = circshift(data(:,1),[prev 0]);
        data(1:prev,:) = [];
        %%%8: previous ST - current ST
        data(:,8) = data(:,7) - data(:,1);
        [means,sd,counts] = grpstats(data(:,5),data(:,1));
        con = unique(data(:,1));
        %%%9 group mean
        data(data(:,1)==con(1),9) = means(1); %mean
        data(data(:,1)==con(2),9) = means(2);
        data(data(:,1)==con(3),9) = means(3);
        data(data(:,1)==con(4),9) = means(4);
        data(data(:,1)==con(5),9) = means(5);
        data(data(:,1)==con(6),9) = means(6);
        data(data(:,1)==con(7),9) = means(7);
        data(data(:,1)==con(8),9) = means(8);
        data(data(:,1)==con(9),9) = means(9);
        data(data(:,1)==con(10),9) = means(10);
        
        %%%10 deviation
        data(:,10) = data(:,5) - data(:,9);
        data(:,11) = data(:,5) - data(:,1); %response error
        eval(['prev' num2str(prev) '(index).delay0=data']);
        
        %1s
        file = dir(strcat('*_1.mat')); %1s
        load(file.name);
        clear data;
        data = log_initiate';
        data(:,7)                 = circshift(data(:,1),[prev 0]);
        data(1:prev,:)            = [];
        data(:,8)                 = data(:,7) - data(:,1);
        [means,sd,counts]         = grpstats(data(:,5),data(:,1));
        con                       = unique(data(:,1));
        data(data(:,1)==con(1),9) = means(1); %mean
        data(data(:,1)==con(2),9) = means(2);
        data(data(:,1)==con(3),9) = means(3);
        data(data(:,1)==con(4),9) = means(4);
        data(data(:,1)==con(5),9) = means(5);
        data(data(:,1)==con(6),9) = means(6);
        data(data(:,1)==con(7),9) = means(7);
        data(data(:,1)==con(8),9) = means(8);
        data(data(:,1)==con(9),9) = means(9);
        data(data(:,1)==con(10),9) = means(10);
        data(:,10) = data(:,5) - data(:,9);
        data(:,11) = data(:,5) - data(:,1);
        eval(['prev' num2str(prev) '(index).delay1=data'])
        
        %3s
        file = dir(strcat('*_3.mat'));
        load(file.name);
        clear data
        data                      = log_initiate';
        data(:,7)                 = circshift(data(:,1),[prev 0]);
        data(1:prev,:)            = [];
        data(:,8)                 = data(:,7) - data(:,1);
        [means,sd,counts]         = grpstats(data(:,5),data(:,1));
        con                       = unique(data(:,1));
        data(data(:,1)==con(1),9) = means(1); %mean
        data(data(:,1)==con(2),9) = means(2);
        data(data(:,1)==con(3),9) = means(3);
        data(data(:,1)==con(4),9) = means(4);
        data(data(:,1)==con(5),9) = means(5);
        data(data(:,1)==con(6),9) = means(6);
        data(data(:,1)==con(7),9) = means(7);
        data(data(:,1)==con(8),9) = means(8);
        data(data(:,1)==con(9),9) = means(9);
        data(data(:,1)==con(10),9) = means(10);
        data(:,10) = data(:,5) - data(:,9);
        data(:,11) = data(:,5) - data(:,1);
        eval(['prev' num2str(prev) '(index).delay3=data'])
        
        %6s
        file = dir(strcat('*_6.mat'));
        load(file.name);
        data                      = log_initiate';
        data(:,7)                 = circshift(data(:,1),[prev 0]);
        data(1:prev,:)            = [];
        data(:,8)                 = data(:,7) - data(:,1);
        [means,sd,counts]         = grpstats(data(:,5),data(:,1));
        con                       = unique(data(:,1));
        data(data(:,1)==con(1),9) = means(1); %mean
        data(data(:,1)==con(2),9) = means(2);
        data(data(:,1)==con(3),9) = means(3);
        data(data(:,1)==con(4),9) = means(4);
        data(data(:,1)==con(5),9) = means(5);
        data(data(:,1)==con(6),9) = means(6);
        data(data(:,1)==con(7),9) = means(7);
        data(data(:,1)==con(8),9) = means(8);
        data(data(:,1)==con(9),9) = means(9);
        data(data(:,1)==con(10),9) = means(10);
        data(:,10) = data(:,5) - data(:,9);
        data(:,11) = data(:,5) - data(:,1);
        eval(['prev' num2str(prev) '(index).delay6=data'])
        
        cd ..
    end
end
save Alldata_n.mat prev2 prev3 prev4 prev5 prev6 prev7 prev8 prev9 prev10