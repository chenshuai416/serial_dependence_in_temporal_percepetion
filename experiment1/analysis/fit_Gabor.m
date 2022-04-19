function params = fit_Gabor(x,y)
% h params(1) w params(2)
% min_a = -10;
% max_a = 10;
% min_w = 0.4;
% max_w = 10;
min_h = -1;
max_h = 1;
min_w = 0.1;
max_w = 10;
x0 = [rand() * (max_h - min_h) + min_h,rand() * (max_w - min_w) + min_w];
fun = @(p,x)p(1).*exp(-(p(2).*x).^2) .* sin(p(2).*x) ;
[params nse]= lsqcurvefit(fun,x0,x,y,[min_h;min_w],[max_h;max_w]);
end