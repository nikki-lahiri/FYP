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
omega=0.95;

%--------classical optimisation---------
%[w,risk,ret,sharpe]= classical_minvar(n_assets,p,V,F,f,asset_ret,alpha);
[w,risk,ret,sharpe]= classical_minvar(n_assets,mu,asset_ret,alpha);

%--------robust optimisation---------
[w2,risk2,ret2,sharpe2]= robust(n_assets, m_factors,p,F,f,D,asset_ret,omega,alpha);

% risk-risk2
% ret-ret2
% sharpe-sharpe2
sharpe2/sharpe