function [Pinch4_val] = PinchingParameters(Perctile)
% This function calculates the Pinching4 parameters for the Stick-IT model proposed in Gaetani d'Aragona et al. 2020.
% The parameters P1, P2, P3, gK2, gK4, gD2 and gD4 are defined based on Table 3 .


% Please cite as:
% Gaetani d'Aragona,M., Polese, M., & Prota, A. (2020). Stick-IT: A simplified model for rapid estimation of IDR 
% and PFA for existing low-rise symmetric infilled RC building typologies. Engineering Structures, 223, 111182.
% DOI: https://doi.org/10.1016/j.engstruct.2020.111182

%P1
sigma = 0.1;
mu = -0.79;
P1=logninv(Perctile,mu,sigma);
%P2
sigma = 0.1;
mu = -1.02;
P2=logninv(Perctile,mu,sigma);
%P3
sigma = 0.25;
mu = -1.84;
P3=logninv(Perctile,mu,sigma)-0.25;
%gk2
sigma = 0.21;
mu = -2.63;
gk2=logninv(Perctile,mu,sigma);
%gk4
sigma = 0.09;
mu = -0.49;
gk4=logninv(Perctile,mu,sigma);
%gD2
sigma = 0.09;
mu = -1.1;
gD2=logninv(Perctile,mu,sigma);
%gD4
sigma = 0.42;
mu = -2.37;
gD4=0.25-logninv(Perctile,mu,sigma);

Pinch4_val=[P1 P2 P3 gk2 gk4 gD2 gD4];
end