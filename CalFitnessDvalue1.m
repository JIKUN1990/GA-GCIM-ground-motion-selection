 function [H,P,Ds] = CalFitnessDvalue1(chrom,N,A1,lgmean,logstd)

fitness = zeros(N, 1);
%开始计算适应度
%  a=   recordselect(:,i);
%  [mu, sigma] = MSTD;
%  p1 = normcdf(a, MSTD(i,1), MSTD(i,2));
%  [H,P,Ds,CV] = kstest(a,[a p1]);
[mm,nn]=size(chrom);


for i = 1:N
    for j=1:nn
     record(j,:)= A1(chrom(i,j),:);      
    end
    for k=1:length(lgmean)
    a=   record(:,k);
    p1 = normcdf(a, lgmean(k), logstd(k));
   [H(k),P(k),Ds(k),CV] = kstest(a,[a p1],0.1);
    end

    
end

end
