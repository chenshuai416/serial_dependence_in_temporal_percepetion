function [CI]=bootstrap_slope(x,y,n_perm)
c = sqrt(2) / exp(-0.5);
if nargin == 2
    n_perm = 10000;
end
for index = 1:n_perm
    s_index = randsample(index,length(x),true);
    sample(:,1) = x(s_index);
    sample(:,2) = y(s_index);
    sample = sortrows(sample,1);
%     sample(:,2) = smooth(sample(:,2),200);
    beta = fit_DoG(x,y);
    actual_a = beta(1);
    actual_w = beta(2);
    slope(index) = actual_a*actual_w*c; 
end
    slope_lower = prctile(slope,5);
    slope_upper = prctile(slope,95);
    slope_mean  = mean(slope);
    CI = [slope_mean,slope_lower,slope_upper];
end