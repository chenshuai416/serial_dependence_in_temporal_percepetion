function [bias_vari]=cal_bias_var2(logg)
 %1:standard; 2:reproduced; 3:group mean; 4:feedback
n_dura = unique(logg(:,1));
n = length(n_dura);
trials = round(length(logg)/n);
logg=sortrows(logg,1);

for i = 1:n %对于每一个时长
    bias_vari(i,1) = logg(trials*i-19,1);
    bias_vari(i,2) = logg(trials*i-19,3) - logg(trials*i-19,1);
%     bias(2,i)=mean(logg(ks:ke,2))-bias(1,i); %reproduced mean - standard
    bias_vari(i,3) = var(logg(logg(:,1)==n_dura(i),2));
end
end
 
 