%x = quadprog(H,f,A,b,Aeq,beq,lb,ub) 
n=10;
e=ones(n,1);

mu=randn(n,1);
S=randn(n);
S=S*S';
r0=1;

[w,minvar]=quadprog(S,zeros(n,1),-mu',-r0,e',1,zeros(n,1),e);