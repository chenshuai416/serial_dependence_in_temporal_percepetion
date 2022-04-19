% experiment 5 location eccentricity pre process
clear all;
cd('C:\Experiment\experiment5\Rawdata');
sub = 17; %
for index = 1:sub
    path = strcat('.\Sub',num2str(index));
    cd(path);
    file = dir(strcat('Data_*.mat')); %Eccen 7 
    load(file.name);
    %%% Result_list
    %%%1: Block
    %%%2: trial
    %%%3: Location 1 top left 2 bottom left 3 bottom right 4 top right
    %%%4: Interval Index
    %%%5: Interval
    %%%6: reproduced
    %%%7: rt
    %%%8: errorrate
    %%%9: feedback
    data = Result_List(:,[3,5,6]);
    %%%1:location
    %%%2:standard
    %%%3:reproduced
    %%%4:previous location
    %%%5:previous-current
    %%%6:group mean
    %%%7:deviation
    %%%8:response error
    data(:,4) = circshift(data(:,1),1);  
    data(:,5) = circshift(data(:,2),1) - data(:,2);
    [means,sd,counts] = grpstats(data(:,3),data(:,2));
    con = unique(data(:,2));
    for i = 1:10 
    data(data(:,2)==con(i),6) = means(i); %mean
    end

   
    data(:,7) = data(:,3) - data(:,6);
    data(:,8) = data(:,3) - data(:,2);
    
    data([1,201,401,601],:)=[];
    Alldata(index).raw = data;  
    cd ..\
end
cd ..\analysis
save Alldata.mat Alldata