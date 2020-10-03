function fitness = CalFitness(chrom, N,A1,lgmean,logstd)

fitness = zeros(N, 1);
%开始计算适应度
[mm,nn]=size(chrom);
for i = 1:N
    for j=1:nn
     record(j,:)= A1(chrom(i,j),:);     
    end

   atemp=1*(lgmean-mean(record)).^2+1*(logstd-std(record)).^2;
%     atemp=((lgmean-mean(record))./(logstd)).^2;
%     fitnesstemp(i)=1/(sum(atemp));
%     if 1/(sum(atemp))<10
%    fitness(i)=1/(sum(atemp));
%     else
     fitness(i)=1/(sum(atemp)+1);    
%     end
end

end
