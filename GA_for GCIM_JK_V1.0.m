clc
clear

Database=NGAdatabase_IMintensities
% The database file was downloaded from website of Professor Brendon A Bradely 
% https://sites.google.com/site/brendonabradley/research/ground-motion-selection
Bradresult=ReadGCIMoutputv3('GCIM_exapmple3.0_500_2%_2.txt')
% The function reading standard output file from the OpenSHA implementation file was downloaded and modified from website of Professor Brendon A Bradely 
% https://sites.google.com/site/brendonabradley/research/ground-motion-selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PeriodTgt=[0.05 0.1 0.2 0.3 0.5 1 2 3 5 10 20 30 40 50 60 80 90 100];
% Conditional period is Sa(3.0s)=0.137g (50yr2%)
% IMs considered are Sa(0.05s) Sa(0.1s) Sa(0.2s) Sa(0.3s) Sa(0.5s) Sa(1.0s)
% Sa(2.0s) Sa(3.0s) Sa(5.0s) Sa(10.0s) PGA, PGV, ASI, SI, DSI, CAV, Ds575, Ds595
% For the convenience of plotting and calculating, 
% 20 30 40 50 60 80 90 100 represnts PGA, PGV, ASI, SI, DSI, CAV, Ds575,Ds595 respectively 

Periodnum=[7 9 11 13 15 17 19 20 22 24 1 2 29 30 31 28 27 26] % location of IMinames.
TargetCDF=Bradresult.GCIM_IMiValues;
Periods=PeriodTgt
for i=1:17
CDF2=TargetCDF(:,:,i);
lgmean(i)=log(CDF2(16,1))
logstd(i)=log(CDF2(21,1))-log(CDF2(16,1))
end
lgmean=[lgmean(1:7),log(0.1371),lgmean(8:end)]
logstd=[logstd(1:7),0.00001,logstd(8:end)] 
jk1=Database.IMiValues;
jk1(:,12)=jk1(:,12)./980

for i=1:length(PeriodTgt) 
     A1(:,i)=jk1(:,Periodnum(i));
end

Periods=PeriodTgt
for i=1:3225
for j=1:18
if j==17 || j==18
    A2(i,j)=A1(i,j)*1;
else
A2(i,j)=(0.1371)/(A1(i,8))*A1(i,j);
scale(i)=(0.1371)/(A1(i,8));
end
end
end

A2=real(log(A2))
A1=A2;
%%prepick the 
plusbound= lgmean+2.5*logstd;
minusbound= lgmean-2.5*logstd;
  
for i=1:3225
    for j=1:length(A1(1,:))
   if A1(i,j)>=plusbound(j) || A1(i,j)<=minusbound(j)||A1(i,1)==A1(i,2)==A1(i,3)
       jtemp(i,j)=-1;
   else
       jtemp(i,j)=i;
   end
    end
   location=find(jtemp(i,:)==-1);
   a=isempty(location)
   if a==1
       jjtemp(i)=1;
   else
       jjtemp(i)=999;
   end
end

A=1:1:3225;
A(A(jjtemp==999))=[]

%%Paramters for GA algorithm
N = 600; %population size
N_chrom = 30; %number of chromosome£¨30 ground motions as an individual£©
iter = 2000; %Maximum generations
mut = 0.01;  %Mutation probability
acr = 0.6; %Cross over probability
%  mutmax=0.01;
%  mutmin=0.01;
%  acrmax=0.3;
%  acrmin=0.3;
chrom = zeros(N, N_chrom);
fitness = zeros(N, 1);
fitness_best = zeros(1, iter);% best fitness value
chrom_best = zeros(1, N_chrom+1);% best individual

% Initialization
[chrom,location]  = Initialize(N, N_chrom,A);
fitness= CalFitness(chrom, N,A1,lgmean,logstd); %Calculate the fitness value£»
chrom_best = FindBest(chrom, fitness, N_chrom); %Find best individual
fitness_best(1) = chrom_best(end);

% Start GA process 
for t = 1:iter

    t    
fitness= CalFitness(chrom, N,A1,lgmean,logstd); 
aa=(fitness)/sum(fitness);
bb=cumsum(aa); 

for i=1:N
cs=rand;
b1=find(bb>=cs);
b=b1(1);
newchrom(i,:)=chrom(b,:);
locationnew(i,:)=location(b,:);
end
chrom=newchrom;
location=locationnew;
   
 [chrom,location]= MutChrom(chrom, mut, N, N_chrom,location,A); %Mutation
 [chrom,location] = AcrChrom2(chrom, acr, N, N_chrom,location); %Crossover  

fitness= CalFitness(chrom, N,A1,lgmean,logstd);
    chrom_best_temp = FindBest(chrom, fitness, N_chrom); 
    if chrom_best_temp(end)>chrom_best(end); 
        chrom_best = chrom_best_temp;
    else
    end
    if chrom_best(end)==0;
        break
    else
    end
  
    fitness_best(t) = chrom_best(end);
    fitness_ave(t) = CalAveFitness(fitness); 

  [D P H]= CalFitnessDvalue1(chrom_best(1:end-1), 1,A1,lgmean,logstd);
  Hy(t)=sum(D);
  Finalchrom{t,1}=chrom_best
if t>400 && fitness_best(t)-fitness_best(t-400)<0.001
break
end
end

location1=find(Hy==2)
TT=location1(end)
chrom_best=Finalchrom{TT,1}
for i=1:30
    recordselect(i,:)=A1(chrom_best(i),:);
end
%% scale factor calculation
Sadata=Database.IMiValues;
for i=1:length(chrom_best)-1
    num=chrom_best(i)
    scale1(i,1)= 0.1371/Sadata(num,20)
end
% Plot fitness fuction curve
plot( 1:2000, fitness_best, 'b','LineWidth',2)
grid on
set(gca, 'LineWidth',1.5,'FontName','Times New Roman')
title('')
xlabel('GA generation number','FontName','Times New Roman')
hold on
resultFitness=[1:iter;fitness_best./max(fitness_best)]';
hold on
plot(TT,fitness_best(TT),'r+','LineWidth',3);
string_legend=strcat('Fitness value=',num2str(fitness_best(TT)));
legend( string_legend)


%% Mean and Std values matching result
subplot(2,1,1)
semilogx(Periods,mean(recordselect),'b*');
set(gca, 'LineWidth',1.5,'FontName','Times New Roman')
title('')
ylabel('Mean','FontName','Times New Roman')
hold on
semilogx(Periods,lgmean,'linewidth',2);
hold off
 
subplot(2,1,2)
semilogx(Periods,std(recordselect),'b*');
hold on
set(gca, 'LineWidth',1.5,'FontName','Times New Roman')
title('')
ylabel('STD','FontName','Times New Roman')
semilogx(Periods,logstd,'linewidth',2);
hold off

result=[mean(recordselect);std(recordselect);lgmean;logstd]'


%% CDF matching reuslt plot
% X12=data
for i=1:18
a=   recordselect(:,i);
p1 = normcdf(a, lgmean(i), logstd(i));
[H(i),P(i),Ds(i,1),CV(i)] = kstest(a,[a p1],0.1);
subplot(5,4,i)
cdfplot(recordselect(:,i))
hold on
b=[a p1]
c=sortrows(b,2)
plot(c(:,1),c(:,2))
plot(c(:,1),c(:,2)+CV(i))
plot(c(:,1),c(:,2)-CV(i))
axis([-inf inf 0 1])
set(gca, 'LineWidth',1.5,'FontName','Times New Roman')
title('')
ylabel('CDF','FontName','Times New Roman')
xlabel(Database.IMiNames(Periodnum(i)))
hold off

end

