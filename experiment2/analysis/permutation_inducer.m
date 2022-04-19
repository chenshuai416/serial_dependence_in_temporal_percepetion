function  pvalue = permutation_inducer(X,nperms)
%input X experiment data; nperms 
if  nargin == 1
    nperms = 10000;
end
%compute delta PSE
levels = unique(X(:,1));
X_short = X(X(:,1) == levels(1),:);
[~,PSE1,~] = fitpsy(X_short(:,5:6));
X_long = X(X(:,1) == levels(2),:);
[~,PSE2,~] = fitpsy(X_long(:,5:6));
Actualdelta = PSE2-PSE1;
for i_perm = 1:nperms
test = X;
test(:,8) = Shuffle([ones(round(length(X)/2),1);zeros(length(X)-round(length(X)/2),1)]);
[~,PSE_short,~]=fitpsy(test(test(:,8)==0,5:6));
[~,PSE_long,~]=fitpsy(test(test(:,8)==1,5:6));
deltaPSE = PSE_long - PSE_short;
PermPSE(i_perm) = deltaPSE;
if mod(i_perm,10)==0
    i_perm
end
pvalue = sum(Actualdelta < PermPSE)/nperms;
end
end