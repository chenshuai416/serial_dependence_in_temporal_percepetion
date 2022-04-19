%% experiment 5 location x hemisphere analysis
clear all;
cd('C:\experiment\experiment5\analysis')
load Alldata.mat
sub = 17;
nperms = 10000;
%%%1:location
%%%2:standard
%%%3:reproduced
%%%4:previous location
%%%5:previous-current
%%%6:group mean
%%%7:deviation

%% Datacleansing
%reproduced 在0.3~2
lower    = 0.3; %s
upper    = 2;   %s
rmtrials = 0;

for index = 1:sub
    RM_index             = Alldata(index).raw(:,3)>lower & Alldata(index).raw(:,3) <upper;
    Alldata(index).clean = Alldata(index).raw(RM_index,:);
    fprintf('Removed %d trials(Eccen7) from subject %d \n',796-sum(RM_index),index);
    rmtrials             = rmtrials+800-sum(RM_index);
end
fprintf('Removed %d trials out of range(0.3~2s) in total. \n',rmtrials);

%exclude 3sd subject-wise
sdtrials = 0;
for index = 1:sub
    totaltrials = length(Alldata(index).clean(:,8));
    RM_index    = isoutlier(Alldata(index).clean(:,8));
    Alldata(index).clean(RM_index,:) = [];
    fprintf('Removed %d trials from subject %d \n',sum(RM_index),index);
    sdtrials    = sdtrials+sum(RM_index);
end
fprintf('Removed %d trials 3sd from average in total. \n',sdtrials);
fprintf('Fnished data cleansing.\n');

groupdata  = [];
for index = 1:sub
    groupdata  = cat(1,groupdata,Alldata(index).clean);
end

%% group serial dependence
figure(1)
%same location
sameloc = groupdata(groupdata(:,1) == groupdata(:,4),:);
subplot 131
hold on
scatter(sameloc(:,5),sameloc(:,7),'filled');
x = unique(round(sameloc(:,5)*100)/100);
y = grpstats(sameloc(:,7),round(sameloc(:,5)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(sameloc(:,5),sameloc(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])
title('same location')
%same hemisphere
hemi_index = (groupdata(:,1) == 1 & groupdata(:,4) == 2)|...
    (groupdata(:,1) == 2 & groupdata(:,4) == 1)|...
    (groupdata(:,1) == 3 & groupdata(:,4) == 4)|...
    (groupdata(:,1) == 4 & groupdata(:,4) == 3);
samehemi = groupdata(hemi_index,:);
subplot 132
hold on
scatter(samehemi(:,5),samehemi(:,7),'filled');
x = unique(round(samehemi(:,5)*100)/100);
y = grpstats(samehemi(:,7),round(samehemi(:,5)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(samehemi(:,5),samehemi(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])
title('same hemisphere')

%Different hemisphere
hemi_index = (groupdata(:,1) == 1 & groupdata(:,4) == 4)|...
    (groupdata(:,1) == 4 & groupdata(:,4) == 1)|...
    (groupdata(:,1) == 3 & groupdata(:,4) == 2)|...
    (groupdata(:,1) == 2 & groupdata(:,4) == 3);
Diffhemi = groupdata(hemi_index,:);
subplot 133
hold on
scatter(Diffhemi(:,5),Diffhemi(:,7),'filled');
x = unique(round(Diffhemi(:,5)*100)/100);
y = grpstats(Diffhemi(:,7),round(Diffhemi(:,5)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(Diffhemi(:,5),Diffhemi(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])
title('Different hemisphere')


% model free
for index = 1:sub
    data = Alldata(index).clean;
    %same location
    sameloc = data(data(:,1) == data(:,4),:);
    DeltaSameLoc(index) = median(sameloc(sameloc(:,5)>0,7)) - median(sameloc(sameloc(:,5)<0,7));
    %same hemisphere
    hemi_index = (data(:,1) == 1 & data(:,4) == 2)|...
        (data(:,1) == 2 & data(:,4) == 1)|...
        (data(:,1) == 3 & data(:,4) == 4)|...
        (data(:,1) == 4 & data(:,4) == 3);
    samehemi = data(hemi_index,:);
    DeltaSameHemi(index) = median(samehemi(samehemi(:,5)>0,7)) - median(samehemi(samehemi(:,5)<0,7));
    %different hemisphere
    hemi_index = (data(:,1) == 1 & data(:,4) == 4)|...
        (data(:,1) == 4 & data(:,4) == 1)|...
        (data(:,1) == 3 & data(:,4) == 2)|...
        (data(:,1) == 2 & data(:,4) == 3);
    Diffhemi = data(hemi_index,:);
    DeltaDiffHemi(index) = median(Diffhemi(Diffhemi(:,5)>0,7)) - median(Diffhemi(Diffhemi(:,5)<0,7));
end

fprintf('Fnished group serial dependence.\n');

%% plotting
figure(3)
hold on
plot([0 4],[0 0],'k--')

plot(ones(1,sub),DeltaSameLoc,'o',...
     2*ones(1,sub),DeltaSameHemi,'o',...
     3*ones(1,sub),DeltaDiffHemi,'o','MarkerSize',8,...
    'MarkerEdgeColor','white',...
         'MarkerFaceColor','#999DA0')
plot([DeltaSameLoc;
    DeltaSameHemi;
    DeltaDiffHemi],'-','color','#999DA0')
errorbar([1 2 3],[mean(DeltaSameLoc) mean(DeltaSameHemi) mean(DeltaDiffHemi)],...
    [std(DeltaSameLoc)/sqrt(17) std(DeltaSameHemi)/sqrt(17) std(DeltaDiffHemi)/sqrt(17)],...
    'sk','linewidth',3,'MarkerSize',10,...
    'MarkerEdgeColor','black','MarkerFaceColor','black')
text(2.8,0.072,'p < .05','fontsize',26)
text(0.9,0.072,'n.s.','fontsize',26)
text(1.9,0.072,'n.s.','fontsize',26)
xlim([0.5 3.5])
xticks(1:3)
xticklabels({'Same Location','Same Hemisphere','Different Hemisphere'})
set(gca,'fontsize',20)
ylabel('Bias from previous trial(s)')
title('Model free analysis')