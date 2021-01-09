
% Matlab code implementation for the generation of the Stick-IT model

% Please cite as:
% Gaetani d'Aragona,M., Polese, M., & Prota, A. (2020). Stick-IT: A simplified model for rapid estimation of IDR 
% and PFA for existing low-rise symmetric infilled RC building typologies. Engineering Structures, 223, 111182.
% DOI: https://doi.org/10.1016/j.engstruct.2020.111182


% This script shows example calculations to demonstrate the use of Stick-IT model with reference to 
% a case-study building, which is reported in the following paper:
% Gaetani d'Aragona, M., Polese, M., Di Ludovico, M., Prota, A. (2021). “The Use of Stick-IT Model for 
% the Prediction of Direct Economic Losses". Earthquake Engineering and Structural Dynamics


% Created by Marco Gaetani d'Aragona
% 07/01/2021


% -------------------------------------------------------------------
% Inputs:
% n_storeys:    Number of storeys
% H_int:        Interstorey height                      (in meters)
% Lx_nx:        In plan dimension along X axis          (in meters)
% Ly_ny:        In plan dimension along Y axis          (in meters)
% Gw_sym:       Shear modulus for infill panels         (in MPa)
% alphaOP_sym:  Opening percentage for infill panels	
% Perctile_B:   Percentile adopted while generating Backbone parameters
% Percentile_P: Percentile adopted while generating Pinching4 parameters

% Functions:
% BackboneParameters: Generates the backbone curve for STICK-IT according to Eq.7 in Gaetani d'Aragona et al. 2020
% PinchingParameters: Generates the Pinching4 hysteretic parameters according to Table 3 in Gaetani d'Aragona et al. 2020


clear all;clc
%% ------------------- OpenSees.exe path ----------------------------
OSpath='C:\Users\mgaet\Desktop\OS\bin\OpenSees.exe';
%creates a .bat file to run OpenSees
file = fopen('RunEQ.bat', 'w+');
fprintf(file,'"%s"  Stick_analysis_EQ.tcl',OSpath);
fclose(file);
%%--------------------------  INPUT --------------------------------------
n_storeys=3; 
H_int=3;                        % in m
Lx_nx=17.0;                     % in m
Ly_ny=10.0;                     % in m
Gw_sym=1620;                    % in MPa
alphaOP_sym=0.20;               % Opening percentage
Perctile_B=[0.5 0.16 0.84];     % Three values are adopted: 0.5, 0.16 and 0.84
Perctile_P=0.5;                 % Only median values of Pinching4 parameters are adopted



%% -----------------  DEFINITION OF MODEL PARAMETERS ----------------------
% Calulation of Stick-IT BACKBONE (Fig. 6(a)) adopting median, 16th percentile (LB), and 84th percentile (UB) values.
% Note: The model is generated only in the X direction (to analyze the Y direction Lx_nx needs to be substituted by Ly_ny)
cont=1;
for Perctile_Bi=Perctile_B
    % Perctile are the percentiles adopted during the generation of the backbone parameters.
    [Backbone_val{cont}] = BackboneParameters(n_storeys,Lx_nx,Gw_sym,alphaOP_sym,Perctile_Bi);
    % output is in N and mm
    cont=cont+1;
end

% Calculation of PINCHING4 Parameters for the Stick-IT model, only median
% values are adopted in this example
Perctile_Pi=Perctile_P;
Pinching4_val=PinchingParameters(Perctile_Pi);

%% -------------------- GENERATION OF OPENSEES MODEL ----------------------
% For comparison purposes, storey masses are assumed equal to 238ton for
% first and second storey, and 200ton for the third storey, according to
% calculation for the case-study building. If masses are not known, it
% can be assumed 1.1-1.2 ton/m2 for any story except for top
% storey where a value of 0.9-1.0ton/m2 should be adopted.
for story=1:n_storeys
    if story<n_storeys
      StoryMass(story)=238.0;
%       StoryMass(story)=Lx_nx*Ly_ny*1.1;
    else
      StoryMass(story)=200.0;  
%       StoryMass(story)=Lx_nx*Ly_ny*0.9;  
    end
end

% Two ground motions are considered (in GMfiles folder)
EQ_name={'AQK_HNE_rot','AQU_HLE_rot'};
EQ_duration=[90.0 90.0]; % EQ duration
dt=[0.005 0.005];        %
% in this example 3 models were considered, consisting in Stick-IT median, LB and UB realizations
ModelName={'median','LB','UB'};
for Modeln=1:3  
    Title=ModelName{Modeln};
    TCL_STICKIT(n_storeys,StoryMass,H_int,Backbone_val{Modeln},Pinching4_val,Title)
    for EQs=1:2
        Analysis_parameters(n_storeys,ModelName{EQs},EQ_name{EQs},EQ_duration(EQs),dt(EQs))
        eval('!RunEQ.bat');
    end
end

PLOT_IDR_PFA_STICK(n_storeys,EQ_name)
