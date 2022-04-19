%% experiment 3 location analysis without DoG fitting

clear all
cd('C:\experiment\experiment3\analysis')
load Alldata.mat
load Prevdata.mat
sub = 24;
nperms = 10000;
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
fprintf('Fnished Alldata cleansing.\n');

%for nback analysis
cleandata = Prevdata;
for prev = 2:10
    for index = 1:sub
        E7_index = isoutlier(cleandata(prev,index).Eccen7(:,8));
        cleandata(prev,index).Eccen7(E7_index,:) = [];
        fprintf('Removed %d trials of Eccen7 from subject %d \n',sum(E7_index),index);
        E21_index = isoutlier(cleandata(prev,index).Eccen21(:,8));
        cleandata(prev,index).Eccen21(E21_index,:) = [];
        fprintf('Removed %d trials of Eccen21 from subject %d \n',sum(E21_index),index);
    end
end
%exclude reproduced not in range of 0.3~2
% remove 75 trials from subj9 to subj24
lower = 0.3; %s
upper = 2;   %s
for prev = 2:10
    for index = 1:sub
        RM7_index = cleandata(prev,index).Eccen7(:,3)<lower | cleandata(prev,index).Eccen7(:,3) >upper;
        cleandata(prev,index).Eccen7(RM7_index,:) = [];
        fprintf('Removed %d trials(Eccen7) from subject %d \n',sum(RM7_index),index);
        
        RM21_index = cleandata(prev,index).Eccen21(:,3)<lower | cleandata(prev,index).Eccen21(:,3) >upper;
        cleandata(prev,index).Eccen21(RM21_index,:) = [];
        fprintf('Removed %d trials(Eccen21) from subject %d \n',sum(RM21_index),index);
    end
end

fprintf('Fnished Prevdata cleansing.\n');


%% group serial dependence
for index = 1:sub
    %eccen7
    Eccen7 = cleandata(index).Eccen7;
    Delta7(index) = median(Eccen7(Eccen7(:,5)>0,7)) - median(Eccen7(Eccen7(:,5)<0,7));
    %%eccen21
    Eccen21 = cleandata(index).Eccen21;
    Delta21(index) = median(Eccen21(Eccen21(:,5)>0,7)) - median(Eccen21(Eccen21(:,5)<0,7));
end


for index = 1:sub
    %same eccen7
    same7 = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)==0,:);
    DeltaSame7(index) = median(same7(same7(:,5)>0,7)) - median(same7(same7(:,5)<0,7));
    %different eccen7
    Diff7 = cleandata(index).Eccen7(cleandata(index).Eccen7(:,4)~=0,:);
    DeltaDiff7(index) = median(Diff7(Diff7(:,5)>0,7)) - median(Diff7(Diff7(:,5)<0,7));
    %same eccen21
    same21 = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)==0,:);
    DeltaSame21(index) = median(same21(same21(:,5)>0,7)) - median(same21(same21(:,5)<0,7));
    %different eccen21
    Diff21 = cleandata(index).Eccen21(cleandata(index).Eccen21(:,4)~=0,:);
    DeltaDiff21(index) = median(Diff21(Diff21(:,5)>0,7)) - median(Diff21(Diff21(:,5)<0,7));
end

%% plotting
figure(5)
hold on
plot([0 5],[0 0],'k-')
plot(ones(1,24),DeltaSame7,'o',...
     2*ones(1,24),DeltaDiff7,'o',...
     3*ones(1,24),DeltaSame21,'o',...
     4*ones(1,24),DeltaDiff21,'o',...
     'MarkerSize',8,...
    'MarkerEdgeColor','white',...
         'MarkerFaceColor','#999DA0')
plot([DeltaSame7;
    DeltaDiff7;
    DeltaSame21;
    DeltaDiff21],'-','color','#999DA0')
errorbar([1 2 3 4],[mean(DeltaSame7) mean(DeltaDiff7) mean(DeltaSame21) mean(DeltaDiff21)],...
    [std(DeltaSame7)/sqrt(sub) std(DeltaDiff7)/sqrt(sub) std(DeltaSame21)/sqrt(sub) std(DeltaDiff21)/sqrt(sub)],...
    'sk','linewidth',3,'MarkerSize',10,...
    'MarkerEdgeColor','black','MarkerFaceColor','black')
text(0.9,0.05,'n.s.','fontsize',26)
text(1.9,0.05,'p <.01 ','fontsize',26)
text(2.9,0.05,'n.s.','fontsize',26)
text(3.9,0.07,'p <.01 ','fontsize',26)
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
ylabel('Bias from previous trial(s)')
title('Model free analysis')


%% n-back analysis
for prev = 2:10
    for index = 1:sub
        %same eccen7
        same7 = cleandata(prev,index).Eccen7(cleandata(prev,index).Eccen7(:,4)==0,:);
        DeltaSame7(prev,index) = median(same7(same7(:,5)>0,7)) - median(same7(same7(:,5)<0,7));
        %different eccen7
        Diff7 = cleandata(prev,index).Eccen7(cleandata(prev,index).Eccen7(:,4)~=0,:);
        DeltaDiff7(prev,index) = median(Diff7(Diff7(:,5)>0,7)) - median(Diff7(Diff7(:,5)<0,7));
        %same eccen21
        same21 = cleandata(prev,index).Eccen21(cleandata(prev,index).Eccen21(:,4)==0,:);
        DeltaSame21(prev,index) = median(same21(same21(:,5)>0,7)) - median(same21(same21(:,5)<0,7));
        %different eccen21
        Diff21 = cleandata(prev,index).Eccen21(cleandata(prev,index).Eccen21(:,4)~=0,:);
        DeltaDiff21(prev,index) = median(Diff21(Diff21(:,5)>0,7)) - median(Diff21(Diff21(:,5)<0,7));
    end
end
DeltaSame7(1,:)=[];
DeltaDiff7(1,:)=[];
DeltaSame21(1,:)=[];
DeltaDiff21(1,:)=[];

%% plotting
figure(6)
hold on
plot([0 5],[0 0],'k-')
% plot(ones(1,24),DeltaSame7,'o',...
%      2*ones(1,24),DeltaDiff7,'o',...
%      3*ones(1,24),DeltaSame21,'o',...
%      4*ones(1,24),DeltaDiff21,'o',...
%      'MarkerSize',8,...
%     'MarkerEdgeColor','white',...
%          'MarkerFaceColor','#999DA0')
model_series = [median(DeltaSame7,2)    median(DeltaDiff7,2)...
    median(DeltaSame21,2)    median(DeltaDiff21,2)];
model_error  = [std(DeltaSame7,[],2)/sqrt(sub) std(DeltaDiff7,[],2)/sqrt(sub)...
    std(DeltaSame21,[],2)/sqrt(sub) std(DeltaDiff21,[],2)/sqrt(sub)];
b = bar(model_series,'grouped');
[ngroups,nbars] = size(model_series);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',model_series,model_error,'k','linestyle','none')
text(0.9,0.05,'n.s.','fontsize',26)
text(1.9,0.05,'p <.01 ','fontsize',26)
text(2.9,0.05,'n.s.','fontsize',26)
text(3.9,0.07,'p <.01 ','fontsize',26)

xticks(1:9)
xticklabels({'n-2','n-3','n-4','n-5','n-6','n-7','n-8','n-9','n-10'})
legend({'','Same Location Eccentricity 7','Different Location Eccentricity 7',...
            'Same Location Eccentricity 21','Different Location Eccentricity 21'});

set(gca,'fontsize',20)
ylabel('n back trial(s)')
title('Model free analysis')