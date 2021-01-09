function [] = Analysis_parameters(n_storeys,ModelName,EQ_name,EQ_duration,dt)
filename=['runEQ.tcl'];
file = fopen(filename, 'w');
% Define the number of storeys to allow the definition of recorders
fprintf(file,['set Nstorey ' num2str(n_storeys) '\n']);
% Set Ground motion parameters
fprintf(file,['set	dTMax1 ' num2str(EQ_duration) '	\n']);
fprintf(file,['set	dt1 ' num2str(dt) '	\n']);
fprintf(file,['set	GMfile1 "' EQ_name '"	\n']);

fprintf(file,['source SpringParameters_' ModelName '.tcl\n']);
fprintf(file,['set LEV "' ModelName '"\n']);
end