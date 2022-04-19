function c_p = diff_permutation_test(x,y,n_permutations)
% x y two different conditions(visual angle, loc,...)
if  nargin == 2
    n_permutations = 10000;
end
% calculate the diff between x and y
real_p2p_diff = p2p(x(:,5),x(:,7)) - p2p(y(:,5),y(:,7));
len_x = length(x);
len_y = length(y);
con = [repmat(1,len_x,1); repmat(2,len_y,1)];
data = [x;y];
data(:,8) = con;
for i=1:n_permutations
perm_data = Shuffle(data);
p2p1 = p2p(perm_data(perm_data(:,8)==1,5),perm_data(perm_data(:,8)==1,7));
p2p2 = p2p(perm_data(perm_data(:,8)==2,5),perm_data(perm_data(:,8)==2,7));
p2p_diff(i) = p2p1 - p2p2;
end
c_p = sum(real_p2p_diff < p2p_diff)/n_permutations;
end