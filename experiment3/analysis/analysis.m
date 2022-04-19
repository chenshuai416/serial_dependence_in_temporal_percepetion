%% experiment 3 location analysis 

clear all
cd('D:\experiment\experiment3\analysis')
load Alldata.mat
sub = 24;
nperms = 10000;
colors = [125,212,158;
    71,194,124;
    87,173,199;
    57,105,172]./255;
    
    %%%1:location
    %%%2:standard
    %%%3:reproduced
    %%%4:same loc or different loc
    %%%5:previous-current
    %%%6:group mean
    %%%7:deviation
%% Datacleansing
%exclude trials 3sd away from mean subjectwise
% remove 179 trials from subj9 to subj24
cleandata = Alldata;
for index = 1:sub
    E7_index = isoutlier(Alldata(index).Eccen7(:,8));
    cleandata(index).Eccen7(E7_index,:) = [];
    fprintf('Removed %d trials of Eccen7 from subject %d \n',sum(E7_index),index);
    E21_index = isoutlier(Alldata(index).Eccen21(:,8));
    cleandata(index).Eccen21(E21_index,:) = [];
    fprintf('Removed %d trials of Eccen21 from subject %d \n',sum(E21_index),index);
end
%exclude reproduced not in range of 0.3~2
% remove 75 trials from subj9 to subj24
lower = 0.3; %s
upper = 2;   %s
for index = 1:sub
    RM7_index = cleandata(index).Eccen7(:,3)<lower | cleandata(index).Eccen7(:,3) >upper;
    cleandata(index).Eccen7(RM7_index,:) = [];
    fprintf('Removed %d trials(Eccen7) from subject %d \n',sum(RM7_index),index);

    RM21_index = cleandata(index).Eccen21(:,3)<lower | cleandata(index).Eccen21(:,3) >upper;
    cleandata(index).Eccen21(RM21_index,:) = [];
    fprintf('Removed %d trials(Eccen21) from subject %d \n',sum(RM21_index),index);

end


fprintf('Fnished data cleansing.\n');


%find previous trials loc and duration
load Prevdata




%pick all or 2nd half use single hand
groupdata7  = [];
groupdata21 = [];
for index = 1:sub
    groupdata7  = cat(1,groupdata7,cleandata(index).Eccen7); 
    groupdata21 = cat(1,groupdata21,cleandata(index).Eccen21);
end

%% group central tendency
figure(1)
subplot 121
hold on
scatter(groupdata7(:,2),groupdata7(:,3),'filled');
[p,S]  = polyfit(groupdata7(:,2),groupdata7(:,3),1);
con = linspace(0.52,1.26,10);
[y_fit,delta] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
xlim([0.5 1.3])
ylim([0.5 1.3])
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)
axis square
subplot 122
hold on
scatter(groupdata21(:,2),groupdata21(:,3),'filled');
[p,S]  = polyfit(groupdata21(:,2),groupdata21(:,3),1);
con = linspace(0.52,1.26,10);
[y_fit,delta] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
xlim([0.5 1.3])
ylim([0.5 1.3])
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)
axis square
fprintf('Fnished group central tendency.\n');
save centraltendency groupdata7 groupdata21

%% group serial dependence 
figure(2)
subplot 121
hold on
scatter(groupdata7(:,5),groupdata7(:,7),'filled','color',colors(1,:),'FaceAlpha',0.2);
x = unique(round(groupdata7(:,5)*100)/100);
y = grpstats(groupdata7(:,7),round(groupdata7(:,5)*100)/100);
scatter(x,y,'color',colors(1,:),'MarkerSize',10);
beta7 = fit_DoG(groupdata7(:,5),groupdata7(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,beta7(1),beta7(2));
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta7(1))+'w='+num2str(beta7(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])


subplot 122
hold on
scatter(groupdata21(:,5),groupdata21(:,7),'filled','color',colors(2,:),'FaceAlpha',0.2);
x = unique(round(groupdata21(:,5)*100)/100);
y = grpstats(groupdata21(:,7),round(groupdata21(:,5)*100)/100);
scatter(x,y,'color',colors(2,:),'MarkerSize',10);
beta21 = fit_DoG(groupdata21(:,5),groupdata21(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,beta21(1),beta21(2));
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
plot(theta,DoG_y,'-o','linewidth',2);
strings={"a="+num2str(beta21(1))+'w='+num2str(beta21(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])



%statistic test
p_value7 = perform_permutation_test(groupdata7(:,5),groupdata7(:,7),nperms);
CI7 = bootstr_p2p(groupdata7(:,5),groupdata7(:,7),nperms);
p_value21 = perform_permutation_test(groupdata21(:,5),groupdata21(:,7),nperms);
CI21 = bootstr_p2p(groupdata21(:,5),groupdata21(:,7),nperms);


fprintf('Fnished group serial dependence.\n');
save groupSD beta7 beta21 p_value7 CI7 p_value21 CI21

%% different location serial dependence

% groupdata7(groupdata7(:,5)>0.5,:)=[];
% groupdata7(groupdata7(:,5)<-0.5,:)=[];
Same7 = groupdata7(groupdata7(:,4)==0,:);
Different7 = groupdata7(groupdata7(:,4)~=0,:);
figure(3)
subplot 221
hold on
scatter(Same7(:,5),Same7(:,7),'filled','MarkerFacecolor',colors(1,:),'MarkerFaceAlpha',0.2);
x = unique(round(Same7(:,5)*100)/100);
y = grpstats(Same7(:,7),round(Same7(:,5)*100)/100);
scatter(x,y,50,'MarkerFacecolor',colors(1,:));
betaSame7 = fit_DoG(Same7(:,5),Same7(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,betaSame7(1),betaSame7(2));
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1.5);
plot([0 0],ax.YLim,'-k','linewidth',1.5);
plot(theta,DoG_y,'-r','linewidth',2);
% strings={"a="+num2str(roundn(betaSame7(1),-4))};
text(0.2,.05,strings,'FontSize',16)
ylim([-0.1 0.1])
xlabel('Difference between standard stimulus(s)')
ylabel('Deviation(s)')
title('Same location of visual angle 7')
set(gca,'fontsize',16)

subplot 222
hold on
scatter(Different7(:,5),Different7(:,7),'filled','MarkerFacecolor',colors(2,:),'MarkerFaceAlpha',0.2);
x = unique(round(Different7(:,5)*100)/100);
y = grpstats(Different7(:,7),round(Different7(:,5)*100)/100);
scatter(x,y,50,'MarkerFacecolor',colors(2,:));
betaDifferent7 = fit_DoG(Different7(:,5),Different7(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,betaDifferent7(1),betaDifferent7(2));

ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1.5);
plot([0 0],ax.YLim,'-k','linewidth',1.5);
plot(theta,DoG_y,'-r','linewidth',2);
% strings={"a="+num2str(roundn(betaDifferent7(1),-4))};
text(0.2,.05,strings,'FontSize',16)
ylim([-0.1 0.1])
xlabel('Difference between standard stimulus(s)')
ylabel('Deviation(s)')
title('Different location of visual angle 7')
set(gca,'fontsize',16)

% groupdata21(groupdata21(:,5)>0.5,:)=[];
% groupdata21(groupdata21(:,5)<-0.5,:)=[];
Same21 = groupdata21(groupdata21(:,4)==0,:);
Different21 = groupdata21(groupdata21(:,4)~=0,:);

subplot 223
hold on
scatter(Same21(:,5),Same21(:,7),'filled','MarkerFacecolor',colors(3,:),'MarkerFaceAlpha',0.2);
x = unique(round(Same21(:,5)*100)/100);
y = grpstats(Same21(:,7),round(Same21(:,5)*100)/100);
scatter(x,y,50,'MarkerFacecolor',colors(3,:));
betaSame21 = fit_DoG(Same21(:,5),Same21(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,betaSame21(1),betaSame21(2));
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
plot(theta,DoG_y,'-r','linewidth',2);
% strings={"a="+num2str(roundn(betaSame21(1),-4))};
text(0.2,.05,strings,'FontSize',20)
ylim([-0.1 0.1])
xlabel('Difference between standard stimulus(s)')
ylabel('Deviation(s)')
title('Same location of visual angle 21')
set(gca,'fontsize',16)

subplot 224
hold on
scatter(Different21(:,5),Different21(:,7),'filled','MarkerFacecolor',colors(3,:),'MarkerFaceAlpha',0.2);
x = unique(round(Different21(:,5)*100)/100);
y = grpstats(Different21(:,7),round(Different21(:,5)*100)/100);
scatter(x,y,50,'MarkerFacecolor',colors(3,:));
betaDifferent21 = fit_DoG(Different21(:,5),Different21(:,7));
theta = -1:0.001:1;
DoG_y = dog(theta,betaDifferent21(1),betaDifferent21(2));
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
plot(theta,DoG_y,'-r','linewidth',2);
% strings={"a="+num2str(roundn(betaDifferent21(1),-4))};
text(0.2,.05,strings,'FontSize',20)
ylim([-0.1 0.1])
xlabel('Difference between standard stimulus(s)')
ylabel('Deviation(s)')
title('Different location of visual angle 21')
set(gca,'fontsize',16)

%statistic test
p_value_Same7 = perform_permutation_test(Same7(:,5),Same7(:,7),nperms);
% p = perform_slope_permutation(Same7(:,5),Same7(:,7),nperms)
CI_Same7 = bootstr_p2p(Same7(:,5),Same7(:,7),nperms);
% slopeCI_Same7 = bootstrap_slope(Same7(:,5),Same7(:,7),nperms);

p_value_Different7 = perform_permutation_test(Different7(:,5),Different7(:,7),nperms);
CI_Different7 = bootstr_p2p(Different7(:,5),Different7(:,7),nperms);
% slopeCI_Different7 = bootstrap_slope(Different7(:,5),Different7(:,7),nperms);

p_value_Same21 = perform_permutation_test(Same21(:,5),Same21(:,7),nperms);
CI_Same21 = bootstr_p2p(Same21(:,5),Same21(:,7),nperms);
% slopeCI_Same21 = bootstrap_slope(Same21(:,5),Same21(:,7),nperms);

p_value_Different21 = perform_permutation_test(Different21(:,5),Different21(:,7),nperms);
% p = perform_slope_permutation(Different21(:,5),Different21(:,7),nperms)
CI_Different21 = bootstr_p2p(Different21(:,5),Different21(:,7),nperms);
% slopeCI_Different21 = bootstrap_slope(Different21(:,5),Different21(:,7),nperms);

%plotting
figure()
hold on
bar([CI_Same7(1) CI_Different7(1) CI_Same21(1) CI_Different21(1)],0.4,...
    'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5])
errorbar([1 2 3 4],[CI_Same7(1) CI_Different7(1) CI_Same21(1) CI_Different21(1)],...
    [CI_Same7(4) CI_Different7(4) CI_Same21(4) CI_Different21(4)],...
    'k','linewidth',1,'linestyle','none')
text(0.8,0.027,'p = 0.043','fontsize',18)
text(1.8,0.028,'p <.05 ','fontsize',18)
text(2.95,0.025,'n.s.','fontsize',18)
text(3.8,0.028,'p < .05','fontsize',18)
xlim([0.5 4.5])
xticks(1:4)
xticklabels({''})
myLabels = [{'Same Location','Different Location','Same Location','Different Location';
            'Eccentricity 7','Eccentricity 7','Eccentricity 21','Eccentricity 21'}];
ax = gca;
for i = 1:length(myLabels)
    text(ax.XTick(i), ax.YLim(1), sprintf('%s\n%s\n%s', myLabels{:,i}), ...
        'fontsize',16,'horizontalalignment', 'center', 'verticalalignment', 'top');    
end
set(gca,'fontsize',20)
ylabel('p2p values(s)')
title('p2p values of different conditions')



save groupLoc betaSame7 p_value_Same7 CI_Same7 betaDifferent7 p_value_Different7 CI_Different7 ...
              betaSame21 betaDifferent7 p_value_Same21 CI_Same21 betaDifferent21 p_value_Different21 CI_Different21
fprintf('Fnished group and location serial dependence.\n');


%% jackknife p2p a w
% Eccen7 Same location
a0 = 1:sub;
JackSame7 = [];
resultSame7 = [];
for j = 1:length(a0)
    subj = a0;
    subj(j)=[];
    for i = subj
        JackSame7 =  cat(1,JackSame7,Alldata(i).Eccen7(Alldata(i).Eccen7(:,4)==0,:));
    end
    resultSame7=cat(1,resultSame7,p2p(JackSame7(:,5),JackSame7(:,7)));
    betaSame7(j,:) =  fit_DoG(JackSame7(:,5),JackSame7(:,7));
    JackSame7=[];
end
% Eccen7 Diff location
JackDifferent7 = [];
resultDifferent7 = [];
for j = 1:length(a0)
    subj = a0;
    subj(j)=[];
    for i = subj
        JackDifferent7 =  cat(1,JackDifferent7,Alldata(i).Eccen7(Alldata(i).Eccen7(:,4)~=0,:));
    end
    resultDifferent7=cat(1,resultDifferent7,p2p(JackDifferent7(:,5),JackDifferent7(:,7)));
    betaDifferent7(j,:) =  fit_DoG(JackDifferent7(:,5),JackDifferent7(:,7));
    JackDifferent7=[];
end

% Eccen21 Same location
JackSame21 = [];
resultSame21 = [];
for j = 1:length(a0)
    subj = a0;
    subj(j)=[];
    for i = subj
        JackSame21 =  cat(1,JackSame21,Alldata(i).Eccen21(Alldata(i).Eccen21(:,4)==0,:));
    end
    resultSame21=cat(1,resultSame21,p2p(JackSame21(:,5),JackSame21(:,7)));
    betaSame21(j,:) =  fit_DoG(JackSame21(:,5),JackSame21(:,7));
    JackSame21=[];
end
% Eccen21 Diff location
JackDifferent21 = [];
resultDifferent21 = [];
for j = 1:length(a0)
    subj = a0;
    subj(j)=[];
    for i = subj
        JackDifferent21 =  cat(1,JackDifferent21,Alldata(i).Eccen21(Alldata(i).Eccen21(:,4)~=0,:));
    end
    resultDifferent21=cat(1,resultDifferent21,p2p(JackDifferent21(:,5),JackDifferent21(:,7)));
    betaDifferent21(j,:) =  fit_DoG(JackDifferent21(:,5),JackDifferent21(:,7));
    JackDifferent21=[];
end
save JKresult resultSame7 betaSame7 resultDifferent7 betaDifferent7 ...
     resultSame21 betaSame21 resultDifferent21 betaDifferent21
fprintf('Fnished Jackknife resampling.\n');

%% individual serial dependence
for index = 1:sub
    figure()
    subplot 221
    Eccen7Same = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)==0,:);
    beta(index).coff1 = plot_DoG(Eccen7Same);
    
    subplot 222
    Eccen7Different = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)~=0,:);
    beta(index).coff2 = plot_DoG(Eccen7Different);
    
    subplot 223
    Eccen21Same = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)==0,:);
    beta(index).coff3 = plot_DoG(Eccen21Same);
      
    subplot 224
    Eccen21Different = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)~=0,:);
    beta(index).coff4 = plot_DoG(Eccen21Different);
end


for index = 1:sub
figure()
Eccen7Same = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)==0,:);
Eccen21Same = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)==0,:);
Same = cat(1,Eccen7Same,Eccen21Same);
subplot 121
plot_DoG(Same);
Eccen7Different = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)~=0,:);
Eccen21Different = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)~=0,:);
Different = cat(1,Eccen7Different,Eccen21Different);
subplot 122
plot_DoG(Different);
end

%% calculate individual p2p
for index = 1:sub
   SingleSame7 = Alldata(index).Eccen7(Alldata(index).Eccen7(:,4)==0,:);
   SingleDifferent7 = Alldata(index).Eccen7(Alldata(index).Eccen7(:,4)~=0,:);
   p2pvalueSame7(index,:) = bootstr_p2p(SingleSame7(:,5),SingleSame7(:,7),nperms);
   pvalueSame7(index,:)=perform_permutation_test(SingleSame7(:,5),SingleSame7(:,7),nperms);
   p2pvalueDifferent7(index,:) = bootstr_p2p(SingleDifferent7(:,5),SingleDifferent7(:,7),nperms);
   pvalueDifferent7(index,:)=perform_permutation_test(SingleDifferent7(:,5),SingleDifferent7(:,7),nperms);
   
   SingleSame21 = Alldata(index).Eccen21(Alldata(index).Eccen21(:,4)==0,:);
   SingleDifferent21 = Alldata(index).Eccen21(Alldata(index).Eccen21(:,4)~=0,:);
   p2pvalueSame21(index,:) = bootstr_p2p(SingleSame21(:,5),SingleSame21(:,7),nperms);
   pvalueSame21(index,:)=perform_permutation_test(SingleSame21(:,5),SingleSame21(:,7),nperms);
   p2pvalueDifferent21(index,:) = bootstr_p2p(SingleDifferent21(:,5),SingleDifferent21(:,7),nperms);
   pvalueDifferent21(index,:)=perform_permutation_test(SingleDifferent21(:,5),SingleDifferent21(:,7),nperms);
end
save individualdata p2pvalueSame7 pvalueSame7 p2pvalueDifferent7 pvalueDifferent7 ...
     p2pvalueSame21 pvalueSame21 p2pvalueDifferent21 pvalueDifferent21
fprintf('Fnished Individual and location serial dependence.\n');