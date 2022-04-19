%preprocess for n-1 trial
cd('D:\Experiment\experiment2\Rawdata');
sub = 16;
condition = 4; % 0/1/3/6
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
        data(:,7)   = circshift(data(:,1),[1 0]);
        data(1,7) = data(1,1);
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
        Alldata(index).delay0 = data;
        xlswrite(strcat('Sub_',num2str(index),'_delay',num2str(0),'.xlsx'),data);
        
        %1s
        file = dir(strcat('*_1.mat')); %1s
        load(file.name);
        data = log_initiate';
        data(:,7)   = circshift(data(:,1),[1 0]);
        data(1,7) = data(1,1);
        data(:,8) = data(:,7) - data(:,1);
        [means,sd,counts] = grpstats(data(:,5),data(:,1));
        con = unique(data(:,1));
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
        Alldata(index).delay1 = data;
        xlswrite(strcat('Sub_',num2str(index),'_delay',num2str(1),'.xlsx'),data);
        
        file = dir(strcat('*_3.mat')); %3s
        load(file.name);
        data = log_initiate';
        data(:,7)   = circshift(data(:,1),[1 0]);
        data(1,7) = data(1,1);
        data(:,8) = data(:,7) - data(:,1);
        [means,sd,counts] = grpstats(data(:,5),data(:,1));
        con = unique(data(:,1));
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
        Alldata(index).delay3 = data;
        xlswrite(strcat('Sub_',num2str(index),'_delay',num2str(3),'.xlsx'),data);
        
        file = dir(strcat('*_6.mat')); %6s
        load(file.name);
        data = log_initiate';
        data(:,7)   = circshift(data(:,1),[1 0]);
        data(1,7) = data(1,1);
        data(:,8) = data(:,7) - data(:,1);
        [means,sd,counts] = grpstats(data(:,5),data(:,1));
        con = unique(data(:,1));
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
        Alldata(index).delay6 = data;
        xlswrite(strcat('Sub_',num2str(index),'_delay',num2str(6),'.xlsx'),data);
        
    cd ..
end
save Alldata.mat Alldata