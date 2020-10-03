function [chrom_new,location] = Initialize(N, N_chrom,A)
chrom_new = rand(N, N_chrom);
location = rand(N, N_chrom);
for i = 1:N %每一列乘上范围
    B=1:N;s=N;
    for j=1:N_chrom
        b=ceil(rand(1,1)*s);
        chrom_new(i, j)=A(B(b));
        location(i,j)=B(b);
        B(b)=[];
        s=s-1;
    end
end
