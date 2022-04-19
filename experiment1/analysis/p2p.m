function p2p_actual = p2p(x,y)
t = -1:0.001:1;
beta = fit_DoG(x,y);
actual_a = beta(1);
actual_w = beta(2);
fit = dog(t,actual_a,actual_w);
p2p_actual = sign(actual_a)*(max(fit)-min(fit));
end