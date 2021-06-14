clear all;clc;

%---------generating synthetic factor model-------------------------------

n_assets=5; %number of assets - set as 500 in the paper
m_factors=3; %number of factors
p=100; %number of periods

%factor covar matrix - known and fixed
cond_f =21;

while cond_f>=20
    F=generateSPDmatrix(m_factors);
    cond_f=cond(F);
    cond_f=vpa(cond_f);
end

%factor return vector 
%what does this acc do
rng(42);
f=randn(m_factors,p)'*chol(F);
f = f * inv(chol(cov(f)));
f = f * chol(F);
f=f';



%factor loading matrix m*n
V=randn(m_factors,n_assets);

%error vector and covariance matrix - known and fixed
D_diag=0.1*diag(V'*F*V);
D=diag(D_diag);
rng(42);
epsilon=randn(n_assets,p)'*chol(D);
epsilon = epsilon * inv(chol(cov(epsilon)));
epsilon = epsilon * chol(D);
epsilon=epsilon';

%rf=3, and mu_i->U[rf+/-2]
rf=3;
sz=[n_assets, 1];
% for i=1:p
%     mu(:,i)=unifrnd(rf-2,rf+2,sz);
% end
mu0=unifrnd(rf-2,rf+2,sz);
for i=1:p
   mu(:,i)=mu0; 
end

% asset_ret
asset_ret=mu+V'*f+epsilon;

% %--------setting uncertainty paramaters-----------------------------------------

%(mu0,V0)-least squares estimate of mu over all periods
y=asset_ret';
B=f;
A=[ones(p,1) B'];% F_ml=F_0- nominal covar matrix
F_0=(1/(p-1))*(B*B'-(1/p)*(B*ones(p,1))*(B*ones(p,1))');

reg_result=(A'*A)^(-1)*A'*y; %[mu0, V0_1, ... ,V0_m]' 
mu0=reg_result(1,:)';
V0=reg_result(2:m_factors+1,:);


%generate distribution of eigenvalues
[Q,L] = qdwheig(F_0^(1/2)*inv(F)*F_0^(1/2));
eig_F=diag(L);
%------------------------------------------------------------------
%confidence level
omega=0.95;
single_omega=omega^(1/m_factors);

% brute force to find value of eta 2 d.p.
x = 0:0.01:2;
y1 = gamcdf(x,(p+1)/2,2/(p-1));

gamval=[x;y1]';
%gamval=array2table(gamval)
x2=0:0.01:1;
y2=zeros(1,101);
for i=1:100
    y2(i+1)=y1(101+i)-y1(101-i);
    if y2(i+1)>=single_omega
        eta=0.01*i;
        break
    end      
end


% etalookup=[x2;y2]';
% etalookup=array2table(etalookup)

% figure;
% plot(x,y1)
% xlabel('Observation')
% ylabel('Probability Density')
