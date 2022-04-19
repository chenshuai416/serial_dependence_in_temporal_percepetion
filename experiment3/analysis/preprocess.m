cd('C:\Experiment\experiment3\Rawdata');
sub = 24; %9-24 single hand
for index = 1:sub
    path = strcat('.\Sub',num2str(index));
    cd(path);
    file = dir(strcat('*_Eccen7.mat')); %Eccen 7 
    load(file.name);
    %%% Result_list
    %%%1: Block
    %%%2: trial
    %%%3: Location -1 left 1 right
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
    %%%4:same loc or different loc
    %%%5:previous-current
    %%%6:group mean
    
    data(:,4) = circshift(data(:,1),1) - data(:,1);  
    data(:,5) = circshift(data(:,2),1) - data(:,2);
    [means,sd,counts] = grpstats(data(:,3),data(:,2));
    con = unique(data(:,2));
    for i = 1:10 
    data(data(:,2)==con(i),6) = means(i); %mean
    end
%     data(data(:,2)==con(2),6) = means(2);
%     data(data(:,2)==con(3),6) = means(3);
%     data(data(:,2)==con(4),6) = means(4);
%     data(data(:,2)==con(5),6) = means(5);
%     data(data(:,2)==con(6),6) = means(6);
%     data(data(:,2)==con(7),6) = means(7);
%     data(data(:,2)==con(8),6) = means(8);
%     data(data(:,2)==con(9),6) = means(9);
%     data(data(:,2)==con(10),6) = means(10);
    %%%7 deviation
    data(:,7) = data(:,3) - data(:,6);
    data(:,8) = data(:,3) - data(:,2);%response error
    data([1,201,401,601],:)=[];
    Alldata(index).Eccen7 = data;  
    cd ..\
end
for index = 1:sub
    path = strcat('.\Sub',num2str(index));
    cd(path);
    file = dir(strcat('*_Eccen21.mat')); %Eccen 21 
    load(file.name);

    data = Result_List(:,[3,5,6]);

    data(:,4) = circshift(data(:,1),1) - data(:,1);  
    data(:,5) = circshift(data(:,2),1) - data(:,2);
    [means,sd,counts] = grpstats(data(:,3),data(:,2));
    con = unique(data(:,2));
    for i = 1:10 
    data(data(:,2)==con(i),6) = means(i); %mean
    end
%     data(data(:,2)==con(2),6) = means(2);
%     data(data(:,2)==con(3),6) = means(3);
%     data(data(:,2)==con(4),6) = means(4);
%     data(data(:,2)==con(5),6) = means(5);
%     data(data(:,2)==con(6),6) = means(6);
%     data(data(:,2)==con(7),6) = means(7);
%     data(data(:,2)==con(8),6) = means(8);
%     data(data(:,2)==con(9),6) = means(9);
%     data(data(:,2)==con(10),6) = means(10);
    %%%7 deviation
    data(:,7) = data(:,3) - data(:,6);
    data(:,8) = data(:,3) - data(:,2);%response error
    data([1,201,401,601],:)=[];
    Alldata(index).Eccen21 = data;  
    cd ..\
end
cd ..\analysis
save Alldata.mat Alldata