function [chrom_new, fitness_new,location_new] = ReplaceWorse(chrom, chrom_best, fitness,location)

min_num = min(fitness);
max_num = max(fitness);
limit = min_num;

replace_corr = fitness<=limit;
ll=find(fitness==min_num)
la=find(fitness==max_num)
replace_num = sum(replace_corr);
chrom(replace_corr, :) = ones(replace_num, 1)*chrom_best(1:end-1);
location(replace_corr, :) = ones(replace_num, 1)*location(la(1),:);
fitness(replace_corr) = ones(replace_num, 1)*chrom_best(end);
chrom_new = chrom;
fitness_new = fitness;
location_new=location;

