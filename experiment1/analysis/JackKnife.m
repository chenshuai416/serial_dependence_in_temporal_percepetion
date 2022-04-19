function [Pa,Li,t] = JackKnife(x,y)
%计算刀切法置信区间
if nargin == 2
    n_perm = 10000;
end
index = 1:length(x);
for i = 1:n_perm
    s_index = randsample(index,length(x),true);
    sample(:,1) = x(s_index);
    sample(:,2) = y(s_index);
    sample = sortrows(sample,1);
    sample(:,2) = smooth(sample(:,2),200);
    beta(i,:) = fit_DoG(sample(:,1),sample(:,2)); %beta是ix2的matrix
end
    a_lower = prctile(beta(:,1),5);
    a_upper = prctile(beta(:,1),95);
    w_lower = prctile(beta(:,2),5);
    w_upper = prctile(beta(:,2),95);
    CI = [a_lower,a_upper,w_lower,w_upper];
end

Xcoords = [x x(end:-1:1)];
Ycoords = [U L(end:-1:1)];

Pa = patch(Xcoords,Ycoords,PatchColor);
set(Pa,'linestyle','none','linewidth',2);
hold on;
Li = plot(x,y,'color',LineColor,'linewidth',2);
hold on;
t = toc;






