function [] = PLOT_IDR_PFA_STICK(n_storeys,EQ_List)

path='Data';  
Hint=ones(1,n_storeys).*3; %interstorey heigth vector
fontSize=12;

for kk=1:2
EQ_name=EQ_List{kk};
for SF=1.0 % EQ scaling factor
for eq_n=1:3
    if eq_n==1
        model='median';
    elseif eq_n==2
        model='LB';    
    else
        model='UB';       
    end
    
    spostX=load([path '\' EQ_name '-DISP_STICK_' model '.out']);
    ttime=spostX(:,1);
    spostX(:,1)=[];

    accXass=load([path '\' EQ_name '-ACCEL_abs_STICK_' model '.out']);
    accXass(:,1)=[];

for ii=1:length(Hint)
    IDRX(:,ii)=(spostX(:,ii+1)-spostX(:,ii))./Hint(ii);
end
% Max IDRs
IDR_maxX(eq_n,:)=max(abs(IDRX)).*100;
% absolute accelerations
acc_maxXX(eq_n,:)=max(abs(accXass));


vect_IDR_maxX(eq_n,:)=reshape([IDR_maxX(eq_n,:);IDR_maxX(eq_n,:)],1,[]);
clear spostX ttime accXass acc_EQ_unscaledX acc_EQX IDRX    
end
% Heights vector for plot
vect_Heigth=reshape([0:size(IDR_maxX,2);0:size(IDR_maxX,2)],1,[]);
vect_Heigth(1)=[];vect_Heigth(end)=[];

vect_Heigth2=reshape([0:size(acc_maxXX,2);0:size(acc_maxXX,2)],1,[]);
vect_Heigth2(1)=[];vect_Heigth2(end)=[];



figure
hold on
%per IDR
plot(vect_IDR_maxX(1,:),vect_Heigth,'r-')
plot(vect_IDR_maxX(2,:),vect_Heigth,'r--')
plot(vect_IDR_maxX(3,:),vect_Heigth,'r:')
set(gca,'Fontname','Times new Roman' ,'Fontsize', 12)
xlabel('IDR_{max} (%)', 'Fontsize', fontSize,'Fontname','Times new Roman');
ylabel('Storey', 'Fontsize', fontSize,'Fontname','Times new Roman');
legend('SIT-M','SIT-LB','SIT-UB')
title(['IDR_X profile - ' EQ_List{kk}])
pbaspect([1 1 1])
box on


figure
hold on

plot(acc_maxXX(1,:),[0 1 2 3],'r-')
plot(acc_maxXX(2,:),[0 1 2 3],'r--')
plot(acc_maxXX(3,:),[0 1 2 3],'r:')
set(gca,'Fontname','Times new Roman' ,'Fontsize', 12)
xlabel('PFA (m/s^2)', 'Fontsize', fontSize,'Fontname','Times new Roman');
ylabel('Storey', 'Fontsize', fontSize,'Fontname','Times new Roman');
legend('SIT-M','SIT-LB','SIT-UB')
title(['PFA_X profile - ' EQ_List{kk}])
xlim([0 8])
pbaspect([1 1 1])
box on


% vect_IDR_maxX
% acc_maxXX
% vect_IDR_maxX
end


end
end