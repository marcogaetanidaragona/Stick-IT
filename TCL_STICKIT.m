function [] = TCL_STICKIT(n_storeys,StoryMass,H_int,Backbone_val,Pinching4_val,Title)


%%%%%%%%%%%%%%%%%%   DEFINITION OF THE GEOMETRICAL MODEL 1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    filename=['StickIT_model.tcl'];
    file = fopen(filename, 'w');
    % Mass Definition
    fprintf(file,'# Storey Masses\n');
    for i=1:n_storeys
    fprintf(file,['set M' num2str(i) ' [expr ' sprintf('%0.2f',StoryMass(i)) '] \n']);
    end
    % Nodes Definition
    fprintf(file,'# Nodes\n');    
    fprintf(file,'node 1 0.0 0.0 \n');
    for i=1:n_storeys
    fprintf(file,['node ' num2str(i+1) ' 0.0 0.0 -mass $M' num2str(i) ' [expr pow(16,-9)] [expr pow(16,-9)]; \n']);
    end
    fprintf(file,'# Restraints\n');
    % Ground story restraint
    fprintf(file,'fix 1 1 1 1; \n');
    % other storeys restraints
    for i=1:n_storeys
    fprintf(file,['fix ' num2str(i+1) ' 0 1 1; \n']);
    end

    % reference to number of storeys+1
    fprintf(file,['set imax ' num2str(n_storeys+1) ';\n']);

    %add dummy mass to allow the calculation of first three vibration modes 
    fprintf(file,'# In case only three sto\n');
    if n_storeys==3
        fprintf(file,['node 5 0.0 0.0 -mass 0.1 0.1 0.1;\n' ]);
        fprintf(file,['uniaxialMaterial Elastic   500   9.9e12;\n']);
        fprintf(file,['element	zeroLength	1000	4	5	-mat	500	-dir    1;\n']);
        fprintf(file,['fix 5 0 1 1 \n']);
    end
    fclose(file);
 
    filename=['ShearLink.tcl'];
    file = fopen(filename, 'w');
    % Generation of zero-length elements
    fprintf(file,'# Zero-lenght element definition\n');
    for i=1:n_storeys
    fprintf(file,['element zeroLength ' num2str(i) ' '  num2str(i) ' '  num2str(i+1) ' -mat ' num2str(i+1) ' -dir 1 -doRayleigh; \n']);
    end

    fclose(file);     
    
%%%%%%%%%%%%%%%%%%   DEFINITION OF THE MECHANICAL MODEL   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    filename=['SpringParameters_' Title '.tcl'];
    file = fopen(filename, 'w');
    fprintf(file,'set	SpringParameters	{');
        for i=1:n_storeys
            % Horizontal branches in Pinching4 Material should be avoided to eliminate convergency issues:
            % Thus a small increase in third point force value is adopted
            Backbone_val(i,3)=Backbone_val(i,3)+1.0;
            fprintf(file,['{ ' sprintf('%0.5f %0.5f %0.5f %0.5f %0.8f %0.8f %0.8f %0.8f ',Backbone_val(i,:)) '} \n']);
        end
    fprintf(file,'};');
    fclose(file);       
             
%%%%%%%%%%%%%%%%  DEFINITION OF HYSTERETIC PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    filename=['Hysteretic_parameters.tcl'];
    file = fopen(filename, 'w');

    rDisp=[Pinching4_val(1) Pinching4_val(1)];
    rForce=[Pinching4_val(2) Pinching4_val(2)];
    uForce=[Pinching4_val(3) Pinching4_val(3)];
    gammaK=[0.0 Pinching4_val(4) 0.0 Pinching4_val(5) 3.0];
    gammaD=[0.0 Pinching4_val(6) 0.0 Pinching4_val(7) 3.0];
    gammaF=[0.0 0.0 0.0 0.0 0.0];

    fprintf(file,['set rDisp  [list ' sprintf('%0.5f %0.5f',rDisp) '] \n']);
    fprintf(file,['set rForce [list ' sprintf('%0.5f %0.5f',rForce) '] \n']);
    fprintf(file,['set uForce [list ' sprintf('%0.5f %0.5f',uForce) '] \n']);
    fprintf(file,['set gammaK [list ' sprintf('%0.5f %0.5f %0.5f %0.5f %0.5f',gammaK) '] \n']);
    fprintf(file,['set gammaD [list ' sprintf('%0.5f %0.5f %0.5f %0.5f %0.5f',gammaD) '] \n']);
    fprintf(file,['set gammaF [list ' sprintf('%0.5f %0.5f %0.5f %0.5f %0.5f',gammaF) '] \n']);
    fclose(file);        
    
       
end


