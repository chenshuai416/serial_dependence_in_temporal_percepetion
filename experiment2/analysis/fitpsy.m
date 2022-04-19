function [a,PSE,JND,choice]=fitpsy(data)
%this function takes in experiment data
%returns b PSE result percetage answer on each standard duration
%data contains col1 compare duration
%col2 response 1 or 0
for i=1:20
    aa=rand;
    bb=rand;%³õÊ¼Öµ
    opt = optimset('Display', 'off', 'MaxFunEvals', 100000, 'MaxIter', 100000, 'Algorithm', 'active-set');
    [x,y]=fmincon(@(X)logisticfunction(X,data),[aa,bb],[],[],[],[],[0 -inf],[inf inf],[], opt);
    if i == 1 || (y < ll_min1 && sum(x ~= xBest1) > 0)
        xBest1=x;
        ll_min1=y;
    end
end
a=xBest1(1);
b=xBest1(2);
PSE=b;
probability=0.25;
t25=(-1/a)*(log(1-probability)-log(probability))+b;
probability=0.75;
t75=(-1/a)*(log(1-probability)-log(probability))+b;
JND=0.5*(t75-t25);

conditions=unique(data(:,1));

for i=1:length(conditions)
    data0=data(data(:,1)==conditions(i),:); %该比较时长的所有试次
    choice(i)=sum(data0(:,1))/size(data0,1);
end
end