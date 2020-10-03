function [Nmin,Nmax]=POP_erfen(min,max,fun,tal)
if tal<fun(1)
    Nmin=0;
    Nmax=1;
else        
    a=min;
    b=max;
    if (b-a)<=1
        Nmin=a;
        Nmax=b;
    else
        c=round((a+b)/2);
        if tal>=fun(c)
            a=c;
            b=b;
            [Nmin,Nmax]=POP_erfen(a,b,fun,tal);
        else
            a=a;
            b=c;
            [Nmin,Nmax]=POP_erfen(a,b,fun,tal);
        end
    end
end
end


