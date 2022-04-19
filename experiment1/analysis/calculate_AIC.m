function [AICc_DoG, AICc_cliford,AICc_Gabor,AICc_Linear,AICc_non] = calculate_AIC(x,y)
total_n = length(x);
%get clifford fit
clif_params = fit_clifford(x,y);
%compute Cliford AICc
clif_rss = sum((y - clifford(x,clif_params(1),clif_params(2),clif_params(3))).^2);
clif_k = length(clif_params);
clif_aic = 2 * clif_k +total_n * log(clif_rss/total_n);
AICc_cliford = clif_aic + 2 * clif_k * (clif_k+1) / (total_n - clif_k - 1 );
%get Gabor fit
Gabor_params = fit_Gabor(x,y);
%compute Gabor AICc
Gabor_rss = sum ((y - Gabor(x,Gabor_params(1),Gabor_params(2))).^2);
Gabor_k = length(Gabor_params);
Gabor_aic = 2 * Gabor_k +total_n * log(Gabor_rss/total_n);
AICc_Gabor = Gabor_aic +2 * Gabor_k * (Gabor_k+1) / (total_n - Gabor_k - 1);
%get DoG fit
dog_params = fit_DoG(x,y);
cc=sqrt(2)/exp(-0.5);
% compute DOG AICc
DoG_rss = sum((y - dog(x,dog_params(1),dog_params(2))).^2);
DoG_k = length(dog_params);
DoG_aic = 2 * DoG_k + total_n * log(DoG_rss/total_n);
AICc_DoG = DoG_aic + 2 * DoG_k * (DoG_k + 1) / (total_n - DoG_k - 1);
%get non-model y=0
non_rss = sum(y.^2);
non_aic = total_n * log(non_rss/total_n);
AICc_non = non_aic;
%get linear regression
linear_fun = @(p,x)p(1).*x;
linear_params = lsqcurvefit(linear_fun,0.1,x,y,-1,1);
% compute AICc
Linear_rss = sum((y - linear_params(1).*x).^2);
Linear_k = length(linear_params);
Linear_aic = 2 * Linear_k + total_n * log(Linear_rss/total_n);
AICc_Linear = Linear_aic + 2 * Linear_k * (Linear_k +1) / (total_n - DoG_k - 1);
end