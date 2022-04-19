function params = fit_clifford(x,y)
%fit clifford's model to observed data.
%     def _solver(params):
%         c, s, m = params
%         m = np.sign(m)
%         return y - m * clifford(x, c, s)
% 
%     min_c = 0.0
%     max_c = 1.0
%     
%     min_s = 0.0
%     max_s = 1.0
% 
%     min_m = -1.0
%     max_m = 1.0
%     
%     min_cost = np.inf
%     for _ in range(200):
%         params_0 = [np.random.rand() * (max_c - min_c) + min_c,
%                     np.random.rand() * (max_s - min_s) + min_s,
%                     np.random.rand() * (max_m - min_m) + min_m]
%         try:
%             result = least_squares(_solver, params_0,
%                                    bounds=([min_c, min_s, min_m],
%                                            [max_c, max_s, max_m]))
%         except ValueError:
%             continue
%         if result['cost'] < min_cost:
%             best_params, min_cost = result['x'], result['cost']
%     try:
%         return best_params[0], best_params[1], np.sign(best_params[2]), min_cost
%     except UnboundLocalError:
%         return np.nan, np.nan, np.nan, min_cost
min_c = 0.0;
max_c = 1.0;
min_s = 0.0;
max_s = 1.0;
min_m = -1.0;
max_m = 1.0;
x0 = [rand() * (max_c - min_c) + min_c,
      rand() * (max_s - min_s) + min_s,
      rand() * (max_m - min_m) + min_m];
cc=sqrt(2)/exp(-0.5);
fun = @(p,x)p(3) .* asin((sin(x)) ./ sqrt(((p(2) .* cos(x) - p(1))) .^2 + (sin(x)).^ 2))-x;
[params nse]= lsqcurvefit(fun,x0,x,y,[min_c;min_s;min_m],[max_c;max_s;max_m]);
%params(1) c params(2)s params(3)m
end