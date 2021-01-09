function [Backbone_val] = BackboneParameters(n_storeys,Li_ni,Gw_sym,alphaOP_sym,Perctile)
% This function calculates the Backbone parameters for the Stick-IT model proposed in Gaetani d'Aragona et al. 2020.
% The parameters K1, K2, K3, Fcr, Fmax, Fu (Figure 6(b)) are defined based on Eq.7 and coefficients reported in Table 2 
% and transformed in the corresponding points (units in kN and m)

% Please cite as:
% Gaetani d'Aragona,M., Polese, M., & Prota, A. (2020). Stick-IT: A simplified model for rapid estimation of IDR 
% and PFA for existing low-rise symmetric infilled RC building typologies. Engineering Structures, 223, 111182.
% DOI: https://doi.org/10.1016/j.engstruct.2020.111182

% RanVar={1 1 effective-to-predicted median CoV(%)} in Table 3
RanVar={ 1 1  0.98	17.6;
         1 1  1.03	20.1;
         1 1  1.07	18.5;
         1 1  0.98	29.1;
         1 1  1.04	17.1;
         1 1  0.98	27.9;
         1 1  0.96	62.7 };
     
alpha_CL=1-alphaOP_sym;


% Calculation of storey backbone parameters
for story=1:n_storeys
%  K1
a=[-3.6*10^5 920 0.95 0.69 1.47 -0.08];
x=[Li_ni,Gw_sym,alpha_CL,story/n_storeys]; 
% formulation for median values
K1(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=1;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        % simulation for i-th Percentile
        K1_val(story)=norminv(Perctile,mu,sigma).*K1(story);

%  Fcr
a=[-310 0.74 0.96 0.69 1.47 -0.08];
Fcr(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=5;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fcr_val(story)=norminv(Perctile,mu,sigma).*Fcr(story);

%  Fy
a=[-730 8.6 1.07 0.39 1.13 -0.23];
Fmax(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=6;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmax_val(story)=norminv(Perctile,mu,sigma).*Fmax(story);

%  K2
a=[-8.85*10^4 1.25*10^3 0.97 0.44 1.49 -0.05];
K2(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=2;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K2_val(story)=norminv(Perctile,mu,sigma).*K2(story);

%  K3
a=[-1.18*10^4 27 0.82 0.76 1.68 0.04];
K3(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=3;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K3_val(story)=norminv(Perctile,mu,sigma).*K3(story);

%  K4
a=[-4.60*10^4 87 0.68 0.92 2.0 Perctile];
K4(story)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=4;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K4_val(story)=norminv(Perctile,mu,sigma).*K4(story);

%  Fmin
x1=[Li_ni,story/n_storeys]; 
a=[-0.12 2.35 0.31 -0.11];
Fmin(story)=exp(a(1)+a(2).*x1(:,1).^a(3).*x1(:,2).^a(4));
i=7;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmin_val(story)=norminv(Perctile,mu,sigma).*Fmin(story);


P_val(1,story)=Fcr_val(story)/K1_val(story);
P_val(2,story)=(Fmax_val(story)-Fcr_val(story))/K2_val(story)+P_val(1,story);
P_val(3,story)=Fmax_val(story)/K4_val(story);
P_val(4,story)=P_val(3,story)+(Fmax_val(story)-Fmin_val(story))/K3_val(story);


Backbone_val(story,:)=[Fcr_val(story) Fmax_val(story) Fmax_val(story) Fmin_val(story) P_val(:,story)'];
end

end

