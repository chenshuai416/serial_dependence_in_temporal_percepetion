function c_p = perform_permutation_test(x,y,n_permutations)
% x Stimulus difference y response error
% Permute Stimulus difference
if  nargin == 2
    n_permutations = 10000;
end
for i_perm = 1:n_permutations
    perm_x = Shuffle(x);
    beta = fit_DoG(perm_x,y);
    a_permuted(i_perm) = beta(1);
    w_permuted(i_perm) = beta(2);
end
% Compute the peak-to-peak
t = -1:0.001:1;
beta = fit_DoG(x,y);
actual_a = beta(1);
actual_w = beta(2);
fit = dog(t,actual_a,actual_w);
p2p_actual = sign(actual_a)*(max(fit)-min(fit));
%compute the permuted peak to peak

for i = 1:n_permutations
    fit=dog(t,a_permuted(i),w_permuted(i));
    peak_to_peak = sign(a_permuted(i)) * (max(fit)-min(fit));
    p2p_permuted(i) = peak_to_peak;
end
if actual_a < 0
    c_p = sum(p2p_actual > p2p_permuted)/n_permutations;
elseif actual_a > 0
    c_p = sum(p2p_permuted > p2p_actual)/n_permutations;
else
    disp('a is zero')
end
end