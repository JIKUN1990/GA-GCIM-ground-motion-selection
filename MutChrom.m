function [chrom,location] = MutChrom(chrom, mut, N, N_chrom,location,A)
% ȥ����chrom��ͬ������


for i = 1:N
   s=N-N_chrom;

    for j = 1:N_chrom
        mut_rand = rand; %�Ƿ����
        if mut_rand <=mut %%�������mut
        ss=1:N;
        ss(location(i,:))=[];
           b=randi([1 s]);
           chrom(i, j)=A(ss(b));
           location(i,j)=ss(b) ; % 
        else
        end
    end
end
chrom_new = chrom;