%DoG fitting
%x 和前一个试次标准时长的差值
%y 当前试次的deviation=current reprodution-average
function beta = fit_DoG(x,y)
%return  a beta(1) w beta(2)
% input previous-current deviation
% min_a = -1;
% max_a = 1;
% min_w = 0.1;
% max_w = 10;
min_a = -1;
max_a = 1;
min_w = 1/(sqrt(2));
max_w = 10;
x0 = [rand() * (max_a - min_a) + min_a,rand() * (max_w - min_w) + min_w];
cc=sqrt(2)/exp(-0.5);
fun = @(p,x)p(1).*p(2).*cc.*x.*exp(-(p(2).*x).^2) ;
[beta nse]= lsqcurvefit(fun,x0,x,y,[min_a;min_w],[max_a;max_w]);
end
