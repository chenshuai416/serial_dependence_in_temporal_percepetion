%% Calculate the serial dependence from n-1 trial

clear all
sub = 16;
load Alldata.mat
addpath 'C:\Experiment\experiment2\analysis'
colors  = [252,210,113;
            247,141,63;
            0,0,161;
            31,110,212;
            173 216 230]./255;
        
        %%%1: current ST
        %%%2: cross onset(to be check)
        %%%3: first button press
        %%%4: second button press
        %%%5: reproduced duration
        %%%6: error rate
        %%%7: ST in previous trial
        %%%8: previous ST - current ST
        %%%9 group mean
        %%%10 deviation
%% data cleansing (TODO) 0.52~1.26s
%reproduced 在0.3~2
lower = 0.3; %s
upper = 2;   %s
for index = 1:16
    R0_index = Alldata(index).delay0(:,5)>lower & Alldata(index).delay0(:,5) <upper;
    cleandata(index).delay0 = Alldata(index).delay0(R0_index,:);
    fprintf('Removed %d trials of delay 0s from subject %d \n',200-sum(R0_index),index);
    R1_index = Alldata(index).delay1(:,5)>lower & Alldata(index).delay1(:,5) <upper;
    cleandata(index).delay1 = Alldata(index).delay1(R1_index,:);
    fprintf('Removed %d trials of delay 1s from subject %d \n',200-sum(R1_index),index);
    R3_index = Alldata(index).delay3(:,5)>lower & Alldata(index).delay3(:,5) <upper;
    cleandata(index).delay3 = Alldata(index).delay3(R3_index,:);
    fprintf('Removed %d trials of delay 3s from subject %d \n',200-sum(R3_index),index);
    R6_index = Alldata(index).delay6(:,5)>lower & Alldata(index).delay6(:,5) <upper;
    cleandata(index).delay6 = Alldata(index).delay6(R6_index,:);
    fprintf('Removed %d trials of delay 6s from subject %d \n',200-sum(R6_index),index);
end
save cleandata cleandata
% rt exclude criterion>2s
%% variance ~ delay
delays = [0, 1, 3, 6];
[errors0,errors1,errors3,errors6] = deal([]);
clear variance
for Subi = 1:sub
    errors0 = cat(1,errors0,Alldata(Subi).delay0(:,10));
    errors1 = cat(1,errors1,Alldata(Subi).delay1(:,10));
    errors3 = cat(1,errors3,Alldata(Subi).delay3(:,10));
    errors6 = cat(1,errors6,Alldata(Subi).delay6(:,10));
end
variance(1) = var(errors0);
variance(2) = var(errors1);
variance(3) = var(errors3);
variance(4) = var(errors6);

n_perm = 1000;
bootstrapped_variance = zeros(4,n_perm);
for j = 1:n_perm
ind = randsample(length(errors0),length(errors0),true);
bootstrapped_variance(1,j) = var(errors0(ind));
bootstrapped_variance(2,j) = var(errors1(ind));
bootstrapped_variance(3,j) = var(errors3(ind));
bootstrapped_variance(4,j) = var(errors6(ind));
end
ci_low(1) = prctile(bootstrapped_variance(1,:),2.5);
ci_low(2) = prctile(bootstrapped_variance(2,:),2.5);
ci_low(3) = prctile(bootstrapped_variance(3,:),2.5);
ci_low(4) = prctile(bootstrapped_variance(4,:),2.5);
ci_high(1) = prctile(bootstrapped_variance(1,:),97.5);
ci_high(2) = prctile(bootstrapped_variance(2,:),97.5);
ci_high(3) = prctile(bootstrapped_variance(3,:),97.5);
ci_high(4) = prctile(bootstrapped_variance(4,:),97.5);

% Fit a line to the variance.

[p,S] = polyfit(delays, variance, 1);
[y_fit,~] = polyval(p,delays,S);
hold on
plot(delays,y_fit,':k','linewidth',3);
% Fit a power law to the variance.
modelfun = @(b,x) b(1) * (x + b(2)).^ b(3);
beta0 = [0.02, 1.45, 0.55];
[beta nse]= lsqcurvefit(modelfun,beta0,delays,variance,[0;-10;0],[1;10;1]);
t=0:0.01:6;
y=beta(1) * (t+beta(2)).^beta(3);
plot(t, y, 'g-','linewidth',3)
vq_low  = interp1(delays,ci_low,0:0.01:6,'spline');
vq_high = interp1(delays,ci_high,0:0.01:6,'spline');
scatter(delays,variance,200,'r+','linewidth',3)
h = fill([t,fliplr(t)],[vq_low,fliplr(vq_high)],'g');
set(h,'edgealpha',0,'facealpha',0.15) 
xticks([0 1 3 6])
xticklabels({'delay0s','delay1s','delay3s','delay6s'})
yticks([0 :0.02: 0.08])
yticklabels({'0','20','40','60','80'})
axis padded
xlabel('current trial''s delay')
ylabel('variance(ms^2)')
legend({'linear fitting curve, R^2 = 0.9683','power fitting curve, R^2 = 0.9926','variances'},'Location','northwest')
set(gca,'fontsize',24)


%% combine data subject-wise
for index = 1:16
    fields = fieldnames(Alldata(index));
    data = [];
    for k = 1:numel(fields)
        aField   = fields{k};
        clean_index = Alldata(index).(aField)(:,5)>lower & Alldata(index).(aField)(:,5)<upper;
        fprintf('Removed %d trials from subject %d \n',200-sum(clean_index),index);
        data  = cat(1,data,Alldata(index).(aField)(clean_index,:));
    end
    Mixdata(index).alldelays=data;
end

for index = 1:16 
figure()
hold on
scatter(Mixdata(index).alldelays(:,8),Mixdata(index).alldelays(:,10),'filled');
x = unique(round(Mixdata(index).alldelays(:,8)*100)/100);
y = grpstats(Mixdata(index).alldelays(:,10),round(Mixdata(index).alldelays(:,8)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(Mixdata(index).alldelays(:,8),Mixdata(index).alldelays(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])
end

%calculate p2p
for index = 1:16
   p2pvalue(index,:)=bootstr_p2p(Mixdata(index).alldelays(:,8),Mixdata(index).alldelays(:,10),1000);
end
save individualdata p2pvalue
for index = 1:16
   pvalue(index,:)=perform_permutation_test(Mixdata(index).alldelays(:,8),Mixdata(index).alldelays(:,10),1000);
end
save individualp pvalue
%% combine valid data
delay0 = []; % sub9 
delay1 = [];
delay3 = [];
delay6 = []; % sub7 sub9 sub11
% for index = [1:8,10:16]
% delay0 =  cat(1,delay0,cleandata(index).delay0);
% end
% for index = [1:6,8,10,12:16]
% delay6 =  cat(1,delay6,cleandata(index).delay6);
% end
for index = 1:16
delay0 =  cat(1,delay0,cleandata(index).delay0);
delay1 =  cat(1,delay1,cleandata(index).delay1);
delay3 =  cat(1,delay3,cleandata(index).delay3);
delay6 =  cat(1,delay6,cleandata(index).delay6);
end

delay0((delay0(:,3)-delay0(:,2))>2,:)=[];
delay1((delay1(:,3)-delay1(:,2))>2,:)=[];
delay3((delay3(:,3)-delay3(:,2))>2,:)=[];
delay6((delay6(:,3)-delay6(:,2))>2,:)=[];
delay0((delay0(:,8)<-0.56)|(delay0(:,8)>0.56),:)=[];
delay1((delay1(:,8)<-0.56)|(delay1(:,8)>0.56),:)=[];
delay3((delay3(:,8)<-0.56)|(delay3(:,8)>0.56),:)=[];
delay6((delay6(:,8)<-0.56)|(delay6(:,8)>0.56),:)=[];%删除两端的previous-current极端值
save delays delay0 delay1 delay3 delay6
%% central tendency
figure()
subplot 221
hold on
scatter(delay0(:,1),delay0(:,5),'filled');
[p,S]  = polyfit(delay0(:,1),delay0(:,5),1);
con = linspace(0.52,1.26,10);
[y_fit,~] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)

subplot 222
hold on
scatter(delay1(:,1),delay1(:,5),'filled');
[p,S]  = polyfit(delay1(:,1),delay1(:,5),1);
[y_fit,delta] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)

subplot 223
hold on
scatter(delay3(:,1),delay3(:,5),'filled');
[p,S]  = polyfit(delay3(:,1),delay3(:,5),1);
[y_fit,delta] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)

subplot 224
hold on
scatter(delay6(:,1),delay6(:,5),'filled');
[p,S]  = polyfit(delay6(:,1),delay6(:,5),1);
[y_fit,delta] = polyval(p,con,S);
plot(con,y_fit,':r','linewidth',2);
plot([0.5 1.3],[0.5 1.3],'-k','linewidth',2);
strings={"slope="+num2str(p(1))};
text(0.6,1.8,strings,'FontSize',20)

lower = 0.3; %s
upper = 2;   %s
for index = 1:16
    fields=fieldnames(Alldata(index));
    for i=1:numel(fields)
        aField   = fields{i};
        clean_index = Alldata(index).(aField)(:,5)>lower & ...
                      Alldata(index).(aField)(:,5)<upper;
        cleandata = Alldata(index).(aField)(clean_index,:);
        [p,S]  = polyfit(cleandata(:,1),cleandata(:,5),1);
        CT(index,i)=1-p(1);
    end
end
long_CT = reshape(CT,64,1)
long_CT(:,2) = repmat([1:16],1,4)'
long_CT(:,3) = [repmat(1,16,1);repmat(2,16,1);repmat(3,16,1);repmat(4,16,1)];
save centralTendency long_CT

%% serial dependence devition use group mean
figure()

subplot 221
hold on
scatter(delay0(:,8),delay0(:,10),'filled');
x = unique(round(delay0(:,8)*100)/100);
y = grpstats(delay0(:,10),round(delay0(:,8)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(delay0(:,8),delay0(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])

subplot 222
hold on
scatter(delay1(:,8),delay1(:,10),'filled');
x = unique(round(delay1(:,8)*100)/100);
y = grpstats(delay1(:,10),round(delay1(:,8)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(delay1(:,8),delay1(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])

subplot 223
hold on
scatter(delay3(:,8),delay3(:,10),'filled');
x = unique(round(delay3(:,8)*100)/100);
y = grpstats(delay3(:,10),round(delay3(:,8)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(delay3(:,8),delay3(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])

subplot 224
hold on
scatter(delay6(:,8),delay6(:,10),'filled');
x = unique(round(delay6(:,8)*100)/100);
y = grpstats(delay6(:,10),round(delay6(:,8)*100)/100);
scatter(x,y,'filled');
beta = fit_DoG(delay6(:,8),delay6(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
ax = gca;
plot(ax.XLim,[0 0],'--g','linewidth',1);
plot(theta,DoG_y,'-k','linewidth',2);
strings={"a="+num2str(beta(1))+'w='+num2str(beta(2))};
text(0,.5,strings,'FontSize',20)
ylim([-0.1 0.1])


% figure()
% plot([0.88 1.54 3.63 6.76],[.021677 .02069 .027449 .025053])

%% model comparison
for i = 1:1000
[AICc_DoG0, AICc_cliford0,AICc_Gabor0,AICc_Linear0,AICc_non0]=calculate_AIC(delay0(:,8),delay0(:,10));
[AICc_DoG1, AICc_cliford1,AICc_Gabor1,AICc_Linear1,AICc_non1]=calculate_AIC(delay1(:,8),delay1(:,10));
[AICc_DoG3, AICc_cliford3,AICc_Gabor3,AICc_Linear3,AICc_non3]=calculate_AIC(delay3(:,8),delay3(:,10));
[AICc_DoG6, AICc_cliford6,AICc_Gabor6,AICc_Linear6,AICc_non6]=calculate_AIC(delay6(:,8),delay6(:,10));
comparison(:,:,i)=[AICc_DoG0, AICc_cliford0,AICc_Gabor0,AICc_Linear0,AICc_non0;
    AICc_DoG1, AICc_cliford1,AICc_Gabor1,AICc_Linear1,AICc_non1;
    AICc_DoG3, AICc_cliford3,AICc_Gabor3,AICc_Linear3,AICc_non3;
    AICc_DoG6, AICc_cliford6,AICc_Gabor6,AICc_Linear6,AICc_non6];
end
mean_AIC=mean(comparison,3);
baseline=repmat(mean_AIC(:,5),[1,5]);
difference=mean_AIC-baseline;
save diff difference

%% compute CI for DoG parameters
CI0 = bootstr(delay0(:,8),delay0(:,10));
CI1 = bootstr(delay1(:,8),delay1(:,10));
CI3 = bootstr(delay3(:,8),delay3(:,10));
CI6 = bootstr(delay6(:,8),delay6(:,10));
save coef CI0 CI1 CI3 CI6

%% compute p2p

p_value0 = perform_permutation_test(delay0(:,8),delay0(:,10));
p_value1 = perform_permutation_test(delay1(:,8),delay1(:,10));
p_value3 = perform_permutation_test(delay3(:,8),delay3(:,10));
p_value6 = perform_permutation_test(delay6(:,8),delay6(:,10));
p2p_value = [];
for i = 1:1000
p2p_value(1,i)=p2p(delay0(:,8),delay0(:,10));
p2p_value(2,i)=p2p(delay1(:,8),delay1(:,10));
p2p_value(3,i)=p2p(delay3(:,8),delay3(:,10));
p2p_value(4,i)=p2p(delay6(:,8),delay6(:,10));
end
p2p0_lower = prctile(p2p_value(1,:),5);
p2p0_upper = prctile(p2p_value(1,:),95);
p2p1_lower = prctile(p2p_value(2,:),5);
p2p1_upper = prctile(p2p_value(2,:),95);
p2p3_lower = prctile(p2p_value(3,:),5);
p2p3_upper = prctile(p2p_value(3,:),95);
p2p6_lower = prctile(p2p_value(4,:),5);
p2p6_upper = prctile(p2p_value(4,:),95);

%jackknife p2p
a0 = 1:16;
a1 = 1:16;
a3 = 1:16;
a6 = 1:16;
delay0J = []; % sub9 
delay1J = [];
delay3J = [];
delay6J = []; % sub7 sub9 sub11
result0=[];
result1=[];
result3=[];
result6=[];
for j = 1:length(a0)
    subj = a0;
    subj(j)=[];
    for i = subj
        delay0J =  cat(1,delay0J,cleandata(i).delay0);
    end
    
    result0=cat(1,result0,p2p(delay0J(:,8),delay0J(:,10)));
    delay0J=[];
end

for j = 1:length(a1)
    subj = a1;
    subj(j)=[];
    for i = subj
        delay1J =  cat(1,delay1J,cleandata(i).delay1);
    end
    
    result1=cat(1,result1,p2p(delay1J(:,8),delay1J(:,10)));
    delay1J=[];
end

for j = 1:length(a3)
    subj = a3;
    subj(j)=[];
    for i = subj
        delay3J =  cat(1,delay3J,cleandata(i).delay3);
    end
    
    result3=cat(1,result3,p2p(delay3J(:,8),delay3J(:,10)));
    delay0J=[];
end

for j = 1:length(a6)
    subj = a6;
    subj(j)=[];
    for i = subj
        delay6J =  cat(1,delay6J,cleandata(i).delay6);
    end
    
    result6=cat(1,result6,p2p(delay6J(:,8),delay6J(:,10)));
    delay6J=[];
end
save p2presult result0 result1 result3 result6

%jackknife parameter a & w
for j = 1:16
    subj = 1:16;
    subj(j)=[];
    x=[];
    y=[];
    for i = subj
        x=cat(1,x,cleandata(i).delay0);
    end
    beta0(j,:) =  fit_DoG(x(:,8),x(:,10));
end
for j = 1:16
    subj = 1:16;
    subj(j)=[];
    x=[];
    y=[];
    for i = subj
        x=cat(1,x,cleandata(i).delay1);
    end
    beta1(j,:) =  fit_DoG(x(:,8),x(:,10));
end
for j = 1:16
    subj = 1:16;
    subj(j)=[];
    x=[];
    y=[];
    for i = subj
        x=cat(1,x,cleandata(i).delay3);
    end
    beta3(j,:) =  fit_DoG(x(:,8),x(:,10));
end
for j = 1:16
    subj = [1:16];
    subj(j)=[];
    x=[];
    y=[];
    for i = subj
        x=cat(1,x,cleandata(i).delay6);
    end
    beta6(j,:) =  fit_DoG(x(:,8),x(:,10));
end
beta0(:,3)=beta0(:,1).*beta0(:,2)*sqrt(2)/exp(-0.5);
beta1(:,3)=beta1(:,1).*beta1(:,2)*sqrt(2)/exp(-0.5);
beta3(:,3)=beta3(:,1).*beta3(:,2)*sqrt(2)/exp(-0.5);
beta6(:,3)=beta6(:,1).*beta6(:,2)*sqrt(2)/exp(-0.5);

%plot bar plot
color = [252,210,113;
       247,141,63;
       0,0,161;
       31,110,212;
       228,23,73;
       38,148,171]./255;
figure();hold on;
x0 = randn(16,1)*0.05 ;
scatter(x0,beta0(:,3),30,color(1,:),'filled','MarkerfaceAlpha',0.8)
x1 = randn(16,1)*0.05 + 1;
scatter(x1,beta1(:,3),30,color(2,:),'filled','MarkerfaceAlpha',0.8)
x3 = rand(16,1)*0.05 + 3;
scatter(x3,beta3(:,3),30,color(3,:),'filled','MarkerfaceAlpha',0.8)
x6 = rand(16,1)*0.05 + 6;
scatter(x6,beta6(:,3),30,color(4,:),'filled','MarkerfaceAlpha',0.8)
x = [0,1,3,6];
y = [mean(beta0(:,3)),mean(beta1(:,3)),mean(beta3(:,3)),mean(beta6(:,3))];
error = [std(beta0(:,3)),std(beta1(:,3)),std(beta3(:,3)),std(beta6(:,3))];
errorbar(x,y,error,'ko','linewidth',1.5,'markersize',8,'markerfacecolor','white','markeredgecolor','k');
set(gca,'Xtick',[0 1 3 6])
xticklabels({'delay 0s','delay 1s','delay 3s','delay 6s'})
xlabel('experiment conditions')
ylabel('instantaneous slope')
set(gca,'fontsize',16)
xlim([-1 7])
plot([0 1],[0.12 0.12],'-k')
text( .4,.125,'***','fontsize',14)
plot([1 3],[0.14 0.14],'-k')
text( 1.9,.145,'***','fontsize',14)
plot([1 6],[0.18 0.18],'-k')
text( 3.4,.185,'**','fontsize',14)
fitx = 0:0.01:7;
fity = 0.01967.*fitx.^0.6902+0.06007;
plot(fitx,fity,'--','color',[192 192 192]./255,'linewidth',3)
text( 6,.24,'y = a * x^{\beta} + c','fontsize',14)
text( 6,.23,'{\beta} = 0.69','fontsize',14)
%% calculate variance bias
lower = 0.3; %s
upper = 2;   %s
for index = 1:16
    fields=fieldnames(Alldata(index));
    for i=1:numel(fields)
        aField   = fields{i};
        clean_index = Alldata(index).(aField)(:,5)>lower & ...
                      Alldata(index).(aField)(:,5)<upper;
        cleandata = Alldata(index).(aField)(clean_index,:);
        logg = [cleandata(:,1),cleandata(:,5),cleandata(:,9)];
        bias_vari=cal_bias_var2(logg);
        bias(index,i) = rms(bias_vari(:,2));
        variance(index,i) = mean((bias_vari(:,3)));
        RMSE(index,i) = sqrt(variance(index,i) + bias(index,i)^2);
    end
    
end

figure()
subplot 221
hold on;
scatter(bias(:,1),sqrt(variance(:,1)),80,[0 .45 .74],'filled','MarkerFaceAlpha',.2)
plotfan(0,0,mean(RMSE(:,1)));
xlim([0 .4])
xticks([0 0.1 0.2 0.3 0.4])
ylim([0 .4])
xlabel('BIAS(s)')
ylabel({'$$\sqrt{VAR}$$(s)'},'Interpreter','latex')
title('delay 0s')
set(gca,'FontSize',20,'Fontname', 'Times New Roman');
subplot 222
hold on;
scatter(bias(:,2),sqrt(variance(:,2)),80,[.85 .33 .1],'filled','MarkerFaceAlpha',.2)
plotfan(0,0,mean(RMSE(:,2)));
xlim([0 .4])
xticks([0 0.1 0.2 0.3 0.4])
ylim([0 .4])
xlabel('BIAS(s)')
ylabel({'$$\sqrt{VAR}$$(s)'},'Interpreter','latex')
title('delay 1s')
set(gca,'FontSize',20,'Fontname', 'Times New Roman');
subplot 223
hold on
scatter(bias(:,3),sqrt(variance(:,3)),80,[.93 .69 .13],'filled','MarkerFaceAlpha',.2)
plotfan(0,0,mean(RMSE(:,3)));
xlim([0 .4])
xticks([0 0.1 0.2 0.3 0.4])
ylim([0 .4])
xlabel('BIAS(s)')
ylabel({'$$\sqrt{VAR}$$(s)'},'Interpreter','latex')
title('delay 3s')
set(gca,'FontSize',20,'Fontname', 'Times New Roman');
subplot 224
hold on
scatter(bias(:,4),sqrt(variance(:,4)),80,[.49 .18 .56],'filled','MarkerFaceAlpha',.2)
plotfan(0,0,mean(RMSE(:,4)));
xlim([0 .4])
xticks([0 0.1 0.2 0.3 0.4])
ylim([0 .4])
xlabel('BIAS(s)')
ylabel({'$$\sqrt{VAR}$$(s)'},'Interpreter','latex')
title('delay 6s')
set(gca,'FontSize',20,'Fontname', 'Times New Roman');


%% calculate serial dependence from previous n-2 to n-10 trials
load Alldata_n.mat
% data cleansing 换了一个 用每个被试每种条件下超过复制误差3sd的
%reproduced 在0.3~2
cleanprev = [prev2;prev3;prev4;prev5;prev6;prev7;prev8;prev9;prev10];
for i=1:9
    for index = 1:16
        R0_index = isoutlier(cleanprev(i,index).delay0(:,11));
        cleanprev(i,index).delay0(R0_index,:) = [];
        fprintf('Removed %d trials of delay 0s from subject %d \n',sum(R0_index),index);
        
        R1_index = isoutlier(cleanprev(i,index).delay1(:,11));
        cleanprev(i,index).delay1(R1_index,:) = [];
        fprintf('Removed %d trials of delay 1s from subject %d \n',sum(R1_index),index);
        
        R3_index = isoutlier(cleanprev(i,index).delay3(:,11));
        cleanprev(i,index).delay3(R3_index,:) = [];
        fprintf('Removed %d trials of delay 3s from subject %d \n',sum(R3_index),index);
        
        R6_index = isoutlier(cleanprev(i,index).delay6(:,11));
        cleanprev(i,index).delay6(R6_index,:) = [];
        fprintf('Removed %d trials of delay 6s from subject %d \n',sum(R6_index),index);
    end
end
% group analysis
for nback = 1:9
    delay0 = [];
    delay1 = [];
    delay3 = [];
    delay6 = [];
    
    for index = 1:16
        delay0 =  cat(1,delay0,cleanprev(nback,index).delay0);
        delay1 =  cat(1,delay1,cleanprev(nback,index).delay1);
        delay3 =  cat(1,delay3,cleanprev(nback,index).delay3);
        delay6 =  cat(1,delay6,cleanprev(nback,index).delay6);
    end
    
[pvalues(nback,1),p2pvalues(nback,1)] = perform_permutation_test(delay0(:,8),delay0(:,10));
[pvalues(nback,2),p2pvalues(nback,2)] = perform_permutation_test(delay1(:,8),delay1(:,10));
[pvalues(nback,3),p2pvalues(nback,3)] = perform_permutation_test(delay3(:,8),delay3(:,10));
[pvalues(nback,4),p2pvalues(nback,4)] = perform_permutation_test(delay6(:,8),delay6(:,10));

    
figure(nback)
subplot 221
hold on
scatter(delay0(:,8),delay0(:,10),'filled','MarkerFaceColor',colors(5,:),'MarkerFaceAlpha',0.2);
x = unique(round(delay0(:,8)*100)/100);
y = grpstats(delay0(:,10),round(delay0(:,8)*100)/100);
scatter(x,y,'MarkerFaceColor',colors(1,:),'MarkerEdgeColor',colors(1,:));
beta = fit_DoG(delay0(:,8),delay0(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
plot(theta,DoG_y,'-','color',colors(1,:),'linewidth',2);
xlim([-0.6 0.6])
ylim([-0.06 0.06])
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
xlabel('difference between previous and current stimuli')
ylabel('deviation')
title('delay 0s')
set(gca,'fontsize',16)
strings={"p ="+num2str(pvalues(4,1))};
text(0.1,.05,strings,'FontSize',20)


subplot 222
hold on
scatter(delay1(:,8),delay1(:,10),'filled','MarkerFaceColor',colors(5,:),'MarkerFaceAlpha',0.2);
x = unique(round(delay1(:,8)*100)/100);
y = grpstats(delay1(:,10),round(delay1(:,8)*100)/100);
scatter(x,y,'MarkerFaceColor',colors(2,:),'MarkerEdgeColor',colors(2,:));
beta = fit_DoG(delay1(:,8),delay1(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
plot(theta,DoG_y,'-','color',colors(2,:),'linewidth',2);
xlim([-0.6 0.6])
ylim([-0.06 0.06])
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
xlabel('difference between previous and current stimuli')
ylabel('deviation')
title('delay 1s')
set(gca,'fontsize',16)
strings={"p ="+num2str(pvalues(4,2))};
text(0.1,.05,strings,'FontSize',20)

subplot 223
hold on
scatter(delay3(:,8),delay3(:,10),'filled','MarkerFaceColor',colors(5,:),'MarkerFaceAlpha',0.2);
x = unique(round(delay1(:,8)*100)/100);
y = grpstats(delay3(:,10),round(delay3(:,8)*100)/100);
scatter(x,y,'MarkerFaceColor',colors(3,:),'MarkerEdgeColor',colors(3,:));
beta = fit_DoG(delay3(:,8),delay3(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
plot(theta,DoG_y,'-','color',colors(3,:),'linewidth',2);
xlim([-0.6 0.6])
ylim([-0.06 0.06])
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
xlabel('difference between previous and current stimuli')
ylabel('deviation')
title('delay 3s')
set(gca,'fontsize',16)
strings={"p ="+num2str(pvalues(4,3))};
text(0.1,.05,strings,'FontSize',20)

subplot 224
hold on
scatter(delay6(:,8),delay6(:,10),'filled','MarkerFaceColor',colors(5,:),'MarkerFaceAlpha',0.2);
x = unique(round(delay6(:,8)*100)/100);
y = grpstats(delay6(:,10),round(delay6(:,8)*100)/100);
scatter(x,y,'MarkerFaceColor',colors(4,:),'MarkerEdgeColor',colors(4,:));
beta = fit_DoG(delay6(:,8),delay6(:,10));
theta = -1:0.001:1;
DoG_y = dog(theta,beta(1),beta(2));
plot(theta,DoG_y,'-','color',colors(4,:),'linewidth',2);
xlim([-0.6 0.6])
ylim([-0.06 0.06])
ax = gca;
plot(ax.XLim,[0 0],'-k','linewidth',1);
plot([0 0],ax.YLim,'-k','linewidth',1);
xlabel('difference between previous and current stimuli')
ylabel('deviation')
title('delay 6s')
set(gca,'fontsize',16)
strings={"p ="+num2str(pvalues(4,4))};
text(0.1,.05,strings,'FontSize',20)

end
save nbackresults p2pvalues pvalues
%
load nbackresults.mat
figure
barplot = bar(p2pvalues);
colormap(cool(8));
legend({'0s','1s','3s','6s'})
xticklabels(2:10)
ylim([-0.04 0.04])
% text(3.85,-0.028,'*','fontsize',16)
text(5,0.03,'n.s.','fontsize',16)
xlabel('n-back trial')
ylabel('p2p values(s)')
set(gca,'fontsize',16)
