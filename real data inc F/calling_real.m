clear;clc;

asset_ret=readtable('dataset2_monthlyreturns.xlsx','Sheet','%ret');
asset_ret=table2array(asset_ret);
[p, n_assets]=size(asset_ret);
f=readtable('dataset2_monthlyreturns.xlsx','Sheet','f%ret');
f=table2array(f);
[p,m_factors]=size(f);


%---------remove later, for sake of generating F and D -----------
% y=asset_ret;
% B=f';
% A=[ones(p,1) B'];
% reg_result=(A'*A)^(-1)*A'*y; %[mu0, V0_1, ... ,V0_m]' 
% mu0=reg_result(1,:)'*10;
% V0=reg_result(2:m_factors+1,:);
% 
% D=cov(y-A*reg_result);
% F=cov(f);
% alpha=0;
%-----------------------------------------------------------------



%--------sharpe ratio comparison as a function of CL---------------
%omega_vec=0.001:0.005:0.999;
omega_vec=0.01:0.05:0.99;
sz_omega=size(omega_vec);
sz_omega=sz_omega(2);

sharpe_comp=zeros(size(omega_vec));
ret_comp=zeros(size(omega_vec));
risk_comp=zeros(size(omega_vec));

clas_policy=zeros(n_assets,sz_omega);
rob_policy=zeros(n_assets,sz_omega);

alpha=0;

for i=1:sz_omega

    %--------classical optimisation---------
    [w,risk,ret,sharpe]= classical_minvar(n_assets,p,f,asset_ret,alpha);

  
    %--------robust optimisation---------
    [w2,risk2,ret2,sharpe2]= robust2(n_assets,m_factors,p,f,asset_ret,alpha,omega_vec(i));
    
    sharpe_comp(i)=sharpe2/sharpe;
    %ret_comp=[ret; ret2]
    %risk_comp=[risk; risk2]
    ret_comp(i)=ret2/ret;
    risk_comp(i)=risk2/risk;
   
end

subplot(3,1,1)
plot(omega_vec,sharpe_comp)
title('Robust/Classical Mean Sharpe Ratio')
xlabel('Confidence Level')
ylabel('Ratio of Sharpe ratios')

subplot(3,1,2)
plot(omega_vec,ret_comp)
title('Robust/Classical Mean Returns')
xlabel('Confidence Level')
ylabel('Ratio of Returns')

subplot(3,1,3)
plot(omega_vec,risk_comp)
title('Robust/Classical Mean Risk')
xlabel('Confidence Level')
ylabel('Ratio of Risk')
% risk-risk2
% ret-ret2
% sharpe-sharpe2

