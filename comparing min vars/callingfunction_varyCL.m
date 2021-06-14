%uncertainty in mu and V defined - no uncertainty in D and F
clear all
clc

%---------generating synthetic factor model-------------------------------

n_assets=5; %number of assets - set as 500 in the paper
m_factors=3; %number of factors
p=30; %number of periods

%factor covar matrix - known and fixed
cond_f =21;

while cond_f>=20
    F=generateSPDmatrix(m_factors);
    cond_f=cond(F);
    cond_f=vpa(cond_f);
end

%factor return vector 
for i=1:p
    f(:,i)=mvnrnd(zeros(m_factors,1),F,1)';
end

%factor loading matrix m*n
V=randn(m_factors,n_assets);

%error vector and error covariance matrix - known and fixed
D_diag=0.1*diag(V'*F*V);
D=diag(D_diag);
for i=1:p
    epsilon(:,i)=mvnrnd(zeros(n_assets,1),D,1)';    
end


%rf=3, and mu_i->U[rf+/-2]
rf=3;
sz=[n_assets, 1];
for i=1:p
    mu(:,i)=unifrnd(rf-2,rf+2,sz);
end

% asset_ret
asset_ret=mu+V'*f+epsilon;

%alpha - min ret
alpha =0;
%confidence level
%omega=0.95;

%--------sharpe ratio comparison as a function of CL---------------
omega_vec=0.01:0.05:0.99;
sz_omega=size(omega_vec);
sz_omega=sz_omega(2);

sharpe_comp=zeros(size(omega_vec));
ret_comp=zeros(size(omega_vec));
risk_comp=zeros(size(omega_vec));

clas_policy=zeros(n_assets,sz_omega);
rob_policy=zeros(n_assets,sz_omega);

for i=1:sz_omega
    omega=omega_vec(i);
    %--------classical optimisation---------
    [w,risk,ret,sharpe]= classical_minvar(n_assets,p,V,F,f,asset_ret,alpha);
    %[w,risk,ret,sharpe]= classical_minvar(n_assets,mu,asset_ret,alpha);
    clas_policy(:,i)=w;
    
    %--------robust optimisation---------
    [w2,risk2,ret2,sharpe2]= robust(n_assets, m_factors,p,F,f,D,asset_ret,omega,alpha);
    rob_policy(:,i)=w2;
    
    sharpe_comp(i)=sharpe2/sharpe;
    ret_comp(i)=ret2/ret;
    risk_comp(i)=risk2/risk;
    i=i+1;

end

subplot(3,1,1)
plot(omega_vec,sharpe_comp)
title('Robust/Classical Worst-case Sharpe Ratio')
xlabel('Confidence Level')
ylabel('Ratio of Sharpe ratios')

subplot(3,1,2)
plot(omega_vec,ret_comp)
title('Robust/Classical Worst-case Returns')
xlabel('Confidence Level')
ylabel('Ratio of Returns')

subplot(3,1,3)
plot(omega_vec,risk_comp)
title('Robust/Classical Worst-case Risk')
xlabel('Confidence Level')
ylabel('Ratio of Risk')
% risk-risk2
% ret-ret2
% sharpe-sharpe2