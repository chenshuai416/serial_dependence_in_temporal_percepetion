%%pooliing data together and calculate PSE
clear all;

cd('D:\experiment\experiment4\Rawdata');
addpath('..\analysis')
sub = 16;
Alldata=[];
for index = 1:sub
    path = strcat('.\Sub',num2str(index));
    cd(path);
    file = dir(strcat('Data*.mat')); 
    load(file.name);
    data = logg_fil;
    Alldata = cat(1,Alldata,data);
    %short inducer
    data_short            = logg_fil(logg_fil(:,1)<logg_fil(:,4),:); 
    [a,PSE,JND,perc]      = fitpsy(data_short(:,5:6));
    a_short(index,:)      = a;
    PSE_short(index,:)    = PSE;
    choose_short(index,:) = perc;
    rt(1,index)           = mean(data_short(:,7));
    acc(1,index)          = sum(data_short(:,6)==(data_short(:,4)<data_short(:,5)))/length(data_short);
    JNDall(1,index)       = JND;
    %long inducer
    data_long             = logg_fil(logg_fil(:,1)>logg_fil(:,4),:); 
    [a,PSE,JND,perc]      = fitpsy(data_long(:,5:6));
    a_long(index,:)       = a;
    PSE_long(index,:)     = PSE;
    choose_long(index,:)  = perc;
    rt(2,index)           = mean(data_long(:,7));
    acc(2,index)          = sum(data_long(:,6)==(data_long(:,4)<data_long(:,5)))/length(data_long);
    JNDall(2,index)       = JND;
    %same inducer
    data_same             = logg_fil(logg_fil(:,1)==logg_fil(:,4),:); 
    [a,PSE,JND,perc]          = fitpsy(data_same(:,5:6));
    a_same(index,:)       = a;
    PSE_same(index,:)     = PSE;
    choose_same(index,:)  = perc;
    rt(3,index)           = mean(data_same(:,7));
    JNDall(3,index)          = JND;
    
    cd('..\')
end
%画errorbar用的
choose_short(17,:) = mean(choose_short);%mean
choose_short(18,:) = std(choose_short)/sqrt(length(choose_short));%standard error
choose_long(17,:) = mean(choose_long);%mean
choose_long(18,:) = std(choose_long)/sqrt(length(choose_long));%standard error
choose_same(17,:) = mean(choose_same);%mean
choose_short(18,:) = std(choose_same)/sqrt(length(choose_same));%standard error
cd('..\analysis')
save Alldata.mat Alldata
save choose.mat choose_short choose_long choose_same
save PSE a_short PSE_short a_long PSE_long a_same PSE_same


%% PSE shift vs JND
[coef, pval] = corr(PSE_long-PSE_short,JNDall(3,:)');
%group fit psych curve
Alldata_short = Alldata(Alldata(:,1)<Alldata(:,4),:);
[a1,b1,JND1] = fitpsy(Alldata_short(:,5:6));
Alldata_long = Alldata(Alldata(:,1)>Alldata(:,4),:);
[a2,b2,JND2] = fitpsy(Alldata_long(:,5:6));
Alldata_same = Alldata(Alldata(:,1)==Alldata(:,4),:);
[a3,b3,JND3] = fitpsy(Alldata_same(:,5:6));
psyfun = @(x,a,b)1./(1+exp(-1*a*(x-b)));
x=0.3:0.001:1.3;
figure(1)
hold on
y1 = psyfun(x,a1,b1);
y2 = psyfun(x,a2,b2);
y3 = psyfun(x,a3,b3);
plot(x,y1,x,y2,x,y3)

%% different inducer length effect on PSE
Alldata_400 = Alldata(Alldata(:,1)==.4,:);
[a1,b1,~] = fitpsy(Alldata_400);
Alldata_600 = Alldata(Alldata(:,1)==.6,:);
[a2,b2,~] = fitpsy(Alldata_600);
Alldata_800 = Alldata(Alldata(:,1)==.8,:);
[a3,b3,~] = fitpsy(Alldata_600);
Alldata_1000 = Alldata(Alldata(:,1)==1,:);
[a4,b4,~] = fitpsy(Alldata_1000);
Alldata_1200 = Alldata(Alldata(:,1)==1.2,:);
[a5,b5,~] = fitpsy(Alldata_1200);
save length a1 b1 a2 b2 a3 b3 a4 b4 a5 b5

%% permutation test
%group level 
nperms = 10000;
[pvalue_c, pvalue_z] = permutation(Alldata,nperms);
save groupp pvalue_c pvalue_z
%individual level
for index = 1:sub
    path = strcat('..\Rawdata\Sub',num2str(index));
    cd(path);
    file = dir(strcat('Data*.mat')); %0s
    load(file.name);
    p(index) = permutation(logg_fil,nperms);
    cd('..\')
    fprintf('subj %d completed.\n',index);
end
save individualp p
%different inducer
testdata = Alldata(Alldata(:,1)== .4 | Alldata(:,1)== .6,:);
p_400600 = permutation_inducer(testdata,nperms);
testdata = Alldata(Alldata(:,1)== .6 | Alldata(:,1)== 1,:);
p_6001000 = permutation_inducer(testdata,nperms);
testdata = Alldata(Alldata(:,1)== 1 | Alldata(:,1)== 1.2,:);
p_10001200 = permutation_inducer(testdata,nperms);

save differentinducer p_400600 p_6001000 p_10001200
%% serial dependence of reproduction task
SDdata = [];
for index = 1:sub
    path = strcat('..\Rawdata\Sub',num2str(index));
    cd(path);
    file = dir(strcat('Data*.mat')); %0s
    load(file.name);
    data = logg_fil;
    % data col 8 group average
    means = grpstats(data(:,2),data(:,1));
    data(data(:,1) == .4,8) = means(1); 
    data(data(:,1) == .6,8) = means(2);
    data(data(:,1) == .8,8) = means(3);
    data(data(:,1) == 1,8) = means(4);
    data(data(:,1) == 1.2,8) = means(5);
    % data col 9 previous - current
    data(:,9) = circshift(data(:,1),1) - data(:,1);
    % data col 10 deviation
    data(:,10) = data(:,2) - data(:,8);
    data(1,:) = [];
    
    SDdata = cat(1,SDdata,data);
    cd('..\')
end
% x = SDdata(:,9);
% y = SDdata(:,10);
% beta = fit_DoG(x,y)
figure()
hold on;
scatter(SDdata(:,9),SDdata(:,10),'filled');
x = unique(round(SDdata(:,9)*100)/100);
y = grpstats(SDdata(:,10),round(SDdata(:,9)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(SDdata(:,9),SDdata(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])

p_value = perform_permutation_test(SDdata(:,9),SDdata(:,10));
CI = bootstr_p2p(SDdata(:,9),SDdata(:,10),nperms);
save SDresult SDdata beta p_value CI

%% rt from phase 2
for index = 1:sub-1
    path = strcat('.\Sub',num2str(index));
    cd(path);
    file = dir(strcat('PSE_*_1.mat')); 
    load(file.name);
    data          = logg_filter;
    rtN(index)    = mean(data(:,4));
    accN(index)   = sum(data(:,3)==(data(:,1)<data(:,2)))/length(data);
    [a,PSE,JND,~] = fitpsy(data(:,2:3));
    JNDN(index)   = JND;
    cd('..\')
end

%% confidence related plotting
% rt plotting
rt(:,16)=[];
data2plot = cat(1,rt,rtN);

figure();hold on;
plot(data2plot,'-o','color',[.8 .8 .8],'MarkerSize',5,'MarkerFaceColor',[.8 .8 .8])
errorbar([.811 .848 .774 .750],[.0852 .1 .0692 .0884],'-sk','LineStyle','none','linewidth',2,...
    'MarkerSize',10,'MarkerFaceColor','k')
xticks([1 2 3 4])
xticklabels({'short inducer','long inducer','same inducer','neutral'})
xlim([0.5 4.5])
ylabel('reaction time')
set(gca,'fontsize',20)


% acc plotting
acc(:,16)=[];
clear data2plot
data2plot = cat(1,acc,accN);

figure();hold on;
plot(data2plot,'-o','color',[.8 .8 .8],'MarkerSize',5,'MarkerFaceColor',[.8 .8 .8])
errorbar([.82 .828 .705],[.01188 .01027 .00945],'-sk','LineStyle','none','linewidth',2,...
    'MarkerSize',10,'MarkerFaceColor','k')
xticks([1 2 3])
xticklabels({'short inducer','long inducer','neutral'})
xlim([0.5 3.5])
ylim([.6 1])
yticks([0.6:0.1:1])
yticklabels({'60','70','80','90','100'})
ylabel('accuracy(%)')
set(gca,'fontsize',20)
plot([1 3],[.95 .95],'-k','linewidth',2)
text(2,.96,'***','FontSize',20)
plot([2 3],[.92 .92],'-k','linewidth',2)
text(2.5,.93,'***','FontSize',20)

% jnd plotting
JNDall(:,16)=[];
clear data2plot
data2plot = cat(1,JNDall,JNDN);
figure();hold on;
plot(data2plot,'-o','color',[.8 .8 .8],'MarkerSize',5,'MarkerFaceColor',[.8 .8 .8])
errorbar([.111 .112 .1 .292],[.01016 .00797 .00885 .01889],'-sk','LineStyle','none','linewidth',2,...
    'MarkerSize',10,'MarkerFaceColor','k')
xticks([1 2 3 4])
xticklabels({'short inducer','long inducer','same inducer','neutral'})
xlim([0.5 4.5])
ylim([0 .5])
yticks([0:0.1:.5])
% yticklabels({'60','70','80','90','100'})
ylabel('JND(s)')
set(gca,'fontsize',20)
plot([1 4],[.4 .4],'-k','linewidth',2)
text(2.5,.41,'***','FontSize',20)
plot([2 4],[.36 .36],'-k','linewidth',2)
text(2.9,.37,'***','FontSize',20)
plot([3 4],[.32 .32],'-k','linewidth',2)
text(3.4,.33,'***','FontSize',20)
%% correlation between bias and rt/acc/JND
PSE_shift = PSE_long - PSE_short;

% corr(PSE_shift,rt(1,:)')
% corr(PSE_shift,rt(2,:)')
% corr(PSE_shift,rt(3,:)')
% corr(PSE_shift,acc(1,:)')
% corr(PSE_shift,acc(2,:)')
% corr(PSE_shift,JNDall(1,:)')
% corr(PSE_shift,JNDall(2,:)')
% corr(PSE_shift,JNDall(3,:)')
mean_rt   = mean(rt(1:2,:));
mean_acc  = mean(acc(1:2,:)); 
mean_JND  = mean(JNDall(1:2,:));
rt_diff   = mean_rt(1:15) - rtN;
scatter(mean_rt,PSE_shift,'o')
%% plot difficulty

clear data2plot;
data2plot = [3,6
3,6
3,5
3,4
5,6
3,7
3,3
4,6
3,5
5,7
4,3
4,7
3,5
3,6
4,5];
figure();hold on;
plot(data2plot','-o','color',[.8 .8 .8],'MarkerSize',5,'MarkerFaceColor',[.8 .8 .8])
errorbar([3.53 5.40],[.192 0.335],'-sk','LineStyle','none','linewidth',2,...
    'MarkerSize',10,'MarkerFaceColor','k')
xticks([1 2])
xticklabels({'1st phase(two-stage task)','2nd phase'})
xlim([0.7 2.3])
ylim([2 7])
ylabel('Difficulty')
set(gca,'fontsize',20)
plot([1 2],[6 6],'-k','linewidth',2)
text(1.5,6.1,'**','FontSize',20)
