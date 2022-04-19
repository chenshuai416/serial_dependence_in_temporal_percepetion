function c_p = perform_slope_permutation(x,y,n_permutations)
% x Stimulus difference y response error
% Permute Stimulus difference
c = sqrt(2) / exp(-0.5);
if  nargin == 2
    n_permutations = 10000;
end
%compute the permuted slope
for i_perm = 1:n_permutations
    perm_x = Shuffle(x);
    beta = fit_DoG(perm_x,y);
    permuted_slope(i_perm) = beta(1)* beta(2) * c;
end
% Compute the peak-to-peak
beta = fit_DoG(x,y);
actual_a = beta(1);
actual_w = beta(2);
slope_actual = actual_a * actual_w * c;

c_p = sum(slope_actual>permuted_slope)/n_permutations;
end