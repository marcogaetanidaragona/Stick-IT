% EDIFICIO
npiani=3;
hinterp=3000;

% DATI EDIFICIO
% disp('edificio girato per avere dir Y')
Lx_nx=17.0;%4.9*5;%
Ly_ny=10.0;%4.08*3;%
% Gw_sym=1296;
Gw_sym=1620;%%1944; %ottenuta come 1296*30/24
Percentuale_foratura_0=0.80;

RanVar={ 1 1  0.98	17.6;
         1 1  1.03	20.1;
         1 1  1.07	18.5;
         1 1  0.98	29.1;
         1 1  1.04	17.1;
         1 1  0.98	27.9;
         1 1  0.96	62.7 };


for piano=1:npiani
% Predizione K1
a=[-3.6*10^5 920 0.95 0.69 1.47 -0.08];
x=[Lx_nx,Gw_sym,Percentuale_foratura_0,piano/npiani]; 
K1(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=1;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K1_LB(piano)=norminv(0.16,mu,sigma).*K1(piano);
        K1_UB(piano)=norminv(0.84,mu,sigma).*K1(piano);

% Predizione Fcr
a=[-310 0.74 0.96 0.69 1.47 -0.08];
Fcr(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=5;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fcr_LB(piano)=norminv(0.16,mu,sigma).*Fcr(piano);
        Fcr_UB(piano)=norminv(0.84,mu,sigma).*Fcr(piano);
% Predizione Fy
a=[-730 8.6 1.07 0.39 1.13 -0.23];
Fmax(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=6;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmax_LB(piano)=norminv(0.16,mu,sigma).*Fmax(piano);
        Fmax_UB(piano)=norminv(0.84,mu,sigma).*Fmax(piano);
% Predizione K2
a=[-8.85*10^4 1.25*10^3 0.97 0.44 1.49 -0.05];
K2(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=2;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K2_LB(piano)=norminv(0.16,mu,sigma).*K2(piano);
        K2_UB(piano)=norminv(0.84,mu,sigma).*K2(piano);
% Predizione K3
a=[-1.18*10^4 27 0.82 0.76 1.68 0.04];
K3(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=3;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K3_LB(piano)=norminv(0.16,mu,sigma).*K3(piano);
        K3_UB(piano)=norminv(0.84,mu,sigma).*K3(piano);
% Predizione K4
a=[-4.60*10^4 87 0.68 0.92 2.0 0.16];
K4(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=4;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K4_LB(piano)=norminv(0.16,mu,sigma).*K4(piano);
        K4_UB(piano)=norminv(0.84,mu,sigma).*K4(piano);
%  Predizione Fmin
x1=[Lx_nx,piano/npiani]; 
a=[-0.12 2.35 0.31 -0.11];
Fmin(piano)=exp(a(1)+a(2).*x1(:,1).^a(3).*x1(:,2).^a(4));
i=7;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmin_LB(piano)=norminv(0.16,mu,sigma).*Fmin(piano);
        Fmin_UB(piano)=norminv(0.84,mu,sigma).*Fmin(piano);

P(1,piano)=Fcr(piano)/K1(piano);
P(2,piano)=(Fmax(piano)-Fcr(piano))/K2(piano)+P(1,piano);
P(3,piano)=Fmax(piano)/K4(piano);
P(4,piano)=P(3,piano)+(Fmax(piano)-Fmin(piano))/K3(piano);


P_LB(1,piano)=Fcr_LB(piano)/K1_LB(piano);
P_LB(2,piano)=(Fmax_LB(piano)-Fcr_LB(piano))/K2_LB(piano)+P_LB(1,piano);
P_LB(3,piano)=Fmax_LB(piano)/K4_LB(piano);
P_LB(4,piano)=P_LB(3,piano)+(Fmax_LB(piano)-Fmin_LB(piano))/K3_LB(piano);

P_UB(1,piano)=Fcr_UB(piano)/K1_UB(piano);
P_UB(2,piano)=(Fmax_UB(piano)-Fcr_UB(piano))/K2_UB(piano)+P_UB(1,piano);
P_UB(3,piano)=Fmax_UB(piano)/K4_UB(piano);
P_UB(4,piano)=P_UB(3,piano)+(Fmax_UB(piano)-Fmin_UB(piano))/K3_UB(piano);
% hold on
% plot([0; P(:,piano)],[0 Fcr(piano) Fmax(piano) Fmax(piano) Fmin(piano)])

if piano<npiani
  MassaPiano(piano)=Lx_nx*Ly_ny*1.1;
else
  MassaPiano(piano)=Lx_nx*Ly_ny*0.9;  
end

h_i(piano)=hinterp*piano;

Pinch4_2(piano,:)=[Fcr(piano) Fmax(piano) Fmax(piano) Fmin(piano) P(:,piano)'].*1000;

Pinch4_2_UB(piano,:)=[Fcr_UB(piano) Fmax_UB(piano) Fmax_UB(piano) Fmin_UB(piano) P_UB(:,piano)'].*1000;
Pinch4_2_LB(piano,:)=[Fcr_LB(piano) Fmax_LB(piano) Fmax_LB(piano) Fmin_LB(piano) P_LB(:,piano)'].*1000;
end




%Parametri isteretici
% P(1,:) = lognrnd(mu,sigma,[1,10000]);
% hist(init_samp)

%P1
sigma = 0.1;
mu = -0.79;
P1=exp(mu);
LB_P1=logninv(0.16,mu,sigma);
UB_P1=logninv(0.84,mu,sigma);
%P2
sigma = 0.1;
mu = -1.02;
P2=exp(mu);
LB_P2=logninv(0.16,mu,sigma);
UB_P2=logninv(0.84,mu,sigma);
%P3
sigma = 0.25;
mu = -1.84;
P3=exp(mu)-0.25;
LB_P3=logninv(0.16,mu,sigma)-0.25;
UB_P3=logninv(0.84,mu,sigma)-0.25;

%gk2
sigma = 0.21;
mu = -2.63;
gk2=exp(mu);
LB_gk2=logninv(0.16,mu,sigma);
UB_gk2=logninv(0.84,mu,sigma);
%gk4
sigma = 0.09;
mu = -0.49;
gk4=exp(mu);
LB_gk4=logninv(0.16,mu,sigma);
UB_gk4=logninv(0.84,mu,sigma);
%gD2
sigma = 0.09;
mu = -1.1;
gD2=exp(mu);
LB_gD2=logninv(0.16,mu,sigma);
UB_gD2=logninv(0.84,mu,sigma);
%gD4
sigma = 0.42;
mu = -2.37;
gD4=0.25-exp(mu);
% gD4=logninv(0.5,mu,sigma);
LB_gD4=0.25-logninv(0.16,mu,sigma);
UB_gD4=0.25-logninv(0.84,mu,sigma);




HYS_LB=[LB_P1 LB_P2 LB_P3 LB_gk2 LB_gk4 LB_gD2 LB_gD4];
HYS_UB=[UB_P1 UB_P2 UB_P3 UB_gk2 UB_gk4 UB_gD2 UB_gD4];
HYS=[P1 P2 P3 gk2 gk4 gD2 gD4];

% % GeneraTCL_STICKI(npiani,MassaPiano,h_i,0,Pinch4_2,0,0,HYS);
% % Se voglio il LOWER BOUND
Title='median';
GeneraTCL_STICKI(npiani,MassaPiano,h_i,0,Pinch4_2,0,0,HYS,Title);
Title='LB';
GeneraTCL_STICKI(npiani,MassaPiano,h_i,0,Pinch4_2_LB,0,0,HYS,Title);
Title='UB';
GeneraTCL_STICKI(npiani,MassaPiano,h_i,0,Pinch4_2_UB,0,0,HYS,Title);




%% GENERAZIONE IN DIREZION Y

for piano=1:npiani
% Predizione K1
a=[-3.6*10^5 920 0.95 0.69 1.47 -0.08];
x=[Ly_ny,Gw_sym,Percentuale_foratura_0,piano/npiani]; 
K1(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=1;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K1_LB(piano)=norminv(0.16,mu,sigma).*K1(piano);
        K1_UB(piano)=norminv(0.84,mu,sigma).*K1(piano);

% Predizione Fcr
a=[-310 0.74 0.96 0.69 1.47 -0.08];
Fcr(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=5;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fcr_LB(piano)=norminv(0.16,mu,sigma).*Fcr(piano);
        Fcr_UB(piano)=norminv(0.84,mu,sigma).*Fcr(piano);
% Predizione Fy
a=[-730 8.6 1.07 0.39 1.13 -0.23];
Fmax(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=6;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmax_LB(piano)=norminv(0.16,mu,sigma).*Fmax(piano);
        Fmax_UB(piano)=norminv(0.84,mu,sigma).*Fmax(piano);
% Predizione K2
a=[-8.85*10^4 1.25*10^3 0.97 0.44 1.49 -0.05];
K2(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=2;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K2_LB(piano)=norminv(0.16,mu,sigma).*K2(piano);
        K2_UB(piano)=norminv(0.84,mu,sigma).*K2(piano);
% Predizione K3
a=[-1.18*10^4 27 0.82 0.76 1.68 0.04];
K3(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=3;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K3_LB(piano)=norminv(0.16,mu,sigma).*K3(piano);
        K3_UB(piano)=norminv(0.84,mu,sigma).*K3(piano);
% Predizione K4
a=[-4.60*10^4 87 0.68 0.92 2.0 0.16];
K4(piano)=a(1)+a(2).*x(:,1).^a(3).*x(:,2).^a(4).*x(:,3).^a(5).*x(:,4).^a(6);
i=4;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        K4_LB(piano)=norminv(0.16,mu,sigma).*K4(piano);
        K4_UB(piano)=norminv(0.84,mu,sigma).*K4(piano);
%  Predizione Fmin
x1=[Ly_ny,piano/npiani]; 
a=[-0.12 2.35 0.31 -0.11];
Fmin(piano)=exp(a(1)+a(2).*x1(:,1).^a(3).*x1(:,2).^a(4));
i=7;
        mu=RanVar{i,3};
        sigma=RanVar{i,4}/100*RanVar{i,3};
        Fmin_LB(piano)=norminv(0.16,mu,sigma).*Fmin(piano);
        Fmin_UB(piano)=norminv(0.84,mu,sigma).*Fmin(piano);

P(1,piano)=Fcr(piano)/K1(piano);
P(2,piano)=(Fmax(piano)-Fcr(piano))/K2(piano)+P(1,piano);
P(3,piano)=Fmax(piano)/K4(piano);
P(4,piano)=P(3,piano)+(Fmax(piano)-Fmin(piano))/K3(piano);


P_LB(1,piano)=Fcr_LB(piano)/K1_LB(piano);
P_LB(2,piano)=(Fmax_LB(piano)-Fcr_LB(piano))/K2_LB(piano)+P_LB(1,piano);
P_LB(3,piano)=Fmax_LB(piano)/K4_LB(piano);
P_LB(4,piano)=P_LB(3,piano)+(Fmax_LB(piano)-Fmin_LB(piano))/K3_LB(piano);

P_UB(1,piano)=Fcr_UB(piano)/K1_UB(piano);
P_UB(2,piano)=(Fmax_UB(piano)-Fcr_UB(piano))/K2_UB(piano)+P_UB(1,piano);
P_UB(3,piano)=Fmax_UB(piano)/K4_UB(piano);
P_UB(4,piano)=P_UB(3,piano)+(Fmax_UB(piano)-Fmin_UB(piano))/K3_UB(piano);
% hold on
% plot([0; P(:,piano)],[0 Fcr(piano) Fmax(piano) Fmax(piano) Fmin(piano)])

if piano<npiani
  MassaPiano(piano)=Lx_nx*Ly_ny*1.1;
else
  MassaPiano(piano)=Lx_nx*Ly_ny*0.9;  
end

h_i(piano)=hinterp*piano;

Pinch4_2(piano,:)=[Fcr(piano) Fmax(piano) Fmax(piano) Fmin(piano) P(:,piano)'].*1000;

Pinch4_2_UB(piano,:)=[Fcr_UB(piano) Fmax_UB(piano) Fmax_UB(piano) Fmin_UB(piano) P_UB(:,piano)'].*1000;
Pinch4_2_LB(piano,:)=[Fcr_LB(piano) Fmax_LB(piano) Fmax_LB(piano) Fmin_LB(piano) P_LB(:,piano)'].*1000;
end

Title='median';
GeneraTCL_STICKI2(npiani,MassaPiano,h_i,0,Pinch4_2,0,0,HYS,Title);
Title='LB';
GeneraTCL_STICKI2(npiani,MassaPiano,h_i,0,Pinch4_2_LB,0,0,HYS,Title);
Title='UB';
GeneraTCL_STICKI2(npiani,MassaPiano,h_i,0,Pinch4_2_UB,0,0,HYS,Title);




