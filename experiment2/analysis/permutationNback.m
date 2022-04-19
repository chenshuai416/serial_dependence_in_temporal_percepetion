function  [pvalue_c, pvalue_z] = permutationNback(X,nperms)
%input X experiment data; nperms 
%for previous nback trial
if  nargin == 1
    nperms = 10000;
end
%compute delta PSE

X_short = X(X(:,8)<X(:,4),:);
[~,PSE1,~] = fitpsy(X_short(:,5:6));

X_long = X(X(:,8)>X(:,4),:);
[~,PSE2,~] = fitpsy(X_long(:,5:6));

X_same  = X(X(:,8)==X(:,4),:);
[~,PSE3,~] = fitpsy(X_same(:,5:6));

long_short = PSE2-PSE1;
long_same  = PSE2-PSE3;
short_same = PSE3-PSE1;

trials = length(X);
for i_perm = 1:nperms

test = X;
test(:,9) = Shuffle([zeros(length(X_same),1);ones(length(X_short),1);2*ones(length(X_long),1)]);
[~,PSE_same,~]=fitpsy(test(test(:,9)==0,5:6));
[~,PSE_short,~]=fitpsy(test(test(:,9)==1,5:6)); %short=1
[~,PSE_long,~]=fitpsy(test(test(:,9)==2,5:6));  %long=2
perm_long_short = PSE_long - PSE_short;
perm_long_same  = PSE_long - PSE_same;
perm_short_same = PSE_same - PSE_short;
PermPSE(:,i_perm) = [perm_long_short;perm_long_same;perm_short_same];
if mod(i_perm,10)==0
    i_perm
end

end
pvalue_c = [sum(long_short < PermPSE(1,:))/nperms;...
            sum(long_same  < PermPSE(2,:) )/nperms;...
            sum(short_same < PermPSE(3,:))/nperms];
z_score = [(long_short - nanmean(PermPSE(1,:))) /nanstd(PermPSE(1,:));...
           (long_same  - nanmean(PermPSE(2,:) ))/nanstd(PermPSE(2,:));...
           (short_same - nanmean(PermPSE(3,:))) /nanstd(PermPSE(3,:))];

pvalue_z = 1 - [normcdf(z_score(1)),normcdf(z_score(2)),normcdf(z_score(3))];
end