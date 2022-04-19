function CI = bootstr_p2p(x,y,n_perm)
if nargin == 2
    n_perm = 10000;
end
index = 1:length(x);
for i = 1:n_perm
    s_index = randsample(index,length(x),true);
    sample(:,1) = x(s_index);
    sample(:,2) = y(s_index);
    sample = sortrows(sample,1);
%     sample(:,2) = smooth(sample(:,2),200);
    p2p_values(i) = p2p(sample(:,1),sample(:,2)); %beta是ix2的matrix
end
    p2p_lower = prctile(p2p_values,5);
    p2p_upper = prctile(p2p_values,95);
    p2p_mean  = mean(p2p_values);
    CI = [p2p_mean,p2p_lower,p2p_upper];
end