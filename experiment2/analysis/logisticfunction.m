%% with approach avoidance parameters for acc task
function tLH=logisticfunction(params,data)
% global data;
tLH=0;
a=params(1);
b=params(2);
nTrial=size(data,1);
for i=1:nTrial
    cduration=data(i,1);%%比较刺激
    Y=data(i,2);%反应
    Pd=1/(1+exp(-1*a*(cduration-b)));
    sLH=Pd^Y*(1-Pd)^(1-Y);
    sLH=log(sLH);
    tLH=tLH-sLH;%total log likelihood
end