%calculate for n-back trial
clear all
cd('C:\Experiment\experiment4\Rawdata');
addpath('C:\Experiment\experiment4\analysis');
sub = 15;
Alldata = [];
for prev = 1:10
    for index = 1:sub
        path = strcat('.\Sub',num2str(index));
        cd(path);
        file = dir(strcat('Data_*.mat'));
        load(file.name);
        data = logg;
        %%%1: standard duration
        %%%2: reproduction duration
        %%%3: rt1
        %%%4: standard duration
        %%%5: compare duration
        %%%6: response
        %%%7: rt2
        data(:,8)   = circshift(data(:,1),[prev 0]);
        data(1:prev,:) = [];
        data(data(:,4)~=.8,:)=[];
        %%%8: previous n
        
        Alldata = cat(1,Alldata,data);
        %short inducer
        data_short            = data(data(:,8)<data(:,4),:);
        [a,PSE,JND,perc]      = fitpsy(data_short(:,5:6));
        a_short(index,:)      = a;
        PSE_short(index,:)    = PSE;
        choose_short(index,:) = perc;
        %         rt(1,index)           = mean(data_short(:,7));
        %         acc(1,index)          = sum(data_short(:,6)==(data_short(:,4)<data_short(:,5)))/length(data_short);
        %         JNDall(1,index)       = JND;
        %long inducer
        data_long             = data(data(:,8)>data(:,4),:);
        [a,PSE,JND,perc]      = fitpsy(data_long(:,5:6));
        a_long(index,:)       = a;
        PSE_long(index,:)     = PSE;
        choose_long(index,:)  = perc;
        %         rt(2,index)           = mean(data_long(:,7));
        %         acc(2,index)          = sum(data_long(:,6)==(data_long(:,4)<data_long(:,5)))/length(data_long);
        %         JNDall(2,index)       = JND;
        %same inducer
        data_same             = data(data(:,8)==data(:,4),:);
        [a,PSE,JND,perc]      = fitpsy(data_same(:,5:6));
        a_same(index,:)       = a;
        PSE_same(index,:)     = PSE;
        choose_same(index,:)  = perc;
        %         rt(3,index)           = mean(data_same(:,7));
        %         JNDall(3,index)          = JND;
        
        cd ..
    end
    
    Alldata_short = Alldata(Alldata(:,8)<Alldata(:,4),:);
    [a1,b1,~] = fitpsy(Alldata_short(:,5:6));
    Alldata_long = Alldata(Alldata(:,8)>Alldata(:,4),:);
    [a2,b2,~] = fitpsy(Alldata_long(:,5:6));
    Alldata_same = Alldata(Alldata(:,8)==Alldata(:,4),:);
    [a3,b3,~] = fitpsy(Alldata_same(:,5:6));
  
    
    deltas(prev) = b2-b1;
    nperms = 1000;
    [pvalue_c(prev), pvalue_z(prev)] = permutationNback(Alldata,nperms);
    fprintf('previous %d finished\n',prev)
%     psyfun = @(x,a,b)1./(1+exp(-1*a*(x-b)));
%     x=0.3:0.001:1.3;
%     figure(prev)
%     hold on
%     y1 = psyfun(x,a1,b1);
%     y2 = psyfun(x,a2,b2);
%     y3 = psyfun(x,a3,b3);
%     plot(x,y1,x,y2,x,y3)
%     legend({'short','long','same'})
%     title([num2str(prev) 'back trial'])

end

save nbackresults deltas pvalue_c pvalue_z
%
load nbackresults.mat

figure
hold on
barplot = bar(deltas,0.5,'FaceAlpha',0.4);
% 
% im_hatch = applyhatch_pluscolor(gcf,'\',1,[1],[],400,3,10);
xticks(1:10)
xticklabels(1:10)
ylim([-0.01 0.01])
yticks(-0.01:0.002:0.01)
yticklabels(-10:2:10)
% text(3.85,-0.028,'*','fontsize',16)
text(5,0.003,'n.s.','fontsize',16)
xlabel('n-back trial')
ylabel('\Delta PSE(ms)')
set(gca,'fontsize',16)