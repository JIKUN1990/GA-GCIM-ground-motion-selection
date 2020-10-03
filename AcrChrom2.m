function [chrom,location]= AcrChrom2(chrom, acr, N, N_chrom,location)
for i = 1:N
    acr_rand = rand;

    
    if acr_rand<acr %如果交叉   
        acr_node = floor((N_chrom-1)*rand+1); %要交叉的节点
       for kk=1:N-1
        acr_chrom = floor((N-1)*rand+1); %要交叉的染色体

        %交叉开始
        
       for ii=acr_node:N_chrom
            aa(ii)=ismember(location(acr_chrom,ii),location(i,1:acr_node-1));
       end
       if sum(aa)==0
           break
       end
       
       end
            
        
        
        
        
        
        for ii=acr_node:N_chrom
            a=ismember(location(acr_chrom,ii),location(i,1:acr_node-1));
            if a==0 
           chrom(i, ii) = chrom(acr_chrom,ii);
           location(i, ii)= location(acr_chrom,ii);
            
            else 

                
                
                
            end
        end

        for jj=acr_node:N_chrom
            b=ismember(location(i,jj),location(acr_chrom,1:acr_node-1));
            if b==0
                chrom(acr_chrom, jj) = chrom(i,jj);
                location(acr_chrom, jj)= location(i,jj);
            else
            end
        end
    else
    end
end
    chrom_new = chrom;

