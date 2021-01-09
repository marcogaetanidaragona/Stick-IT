set dataDir Data;				# set up name of data directory (you can remove this)
file mkdir $dataDir; 			# create data directory
set GMdir "../GMfiles/";		# ground-motion file directory


wipe;				# clear memory of all past model definitions
model basic -ndm 2 -ndf 3
set PI [expr 2*asin(1.0)]; 		# define constants
set g 9.81;


source runEQ.tcl; #load GM parameters and
source StickIT_model.tcl;#load the model
source Hysteretic_parameters.tcl;#load hysteretic parameters

uniaxialMaterial Elastic   1   9.9e12;

set gammaE 10; 
set damage "cycle"
set i 1;
while {$i<$imax} {
# load Backbone curve 
set pEnvelopeStress [list [lindex $SpringParameters [expr $i-1] 0] [lindex $SpringParameters [expr $i-1] 1] [lindex $SpringParameters [expr $i-1] 2] [lindex $SpringParameters [expr $i-1] 3] ]
set pEnvelopeStrain [list [lindex $SpringParameters [expr $i-1] 4] [lindex $SpringParameters [expr $i-1] 5] [lindex $SpringParameters [expr $i-1] 6] [lindex $SpringParameters [expr $i-1] 7] ]
set materialTag [expr $i+1]
#defines pinching4 material
uniaxialMaterial Pinching4 $materialTag [lindex $pEnvelopeStress 0] [lindex $pEnvelopeStrain 0] [lindex $pEnvelopeStress 1] [lindex $pEnvelopeStrain 1] [lindex $pEnvelopeStress 2] [lindex $pEnvelopeStrain 2] [lindex $pEnvelopeStress 3] [lindex $pEnvelopeStrain 3] -[lindex $pEnvelopeStress 0] -[lindex $pEnvelopeStrain 0] -[lindex $pEnvelopeStress 1] -[lindex $pEnvelopeStrain 1] -[lindex $pEnvelopeStress 2] -[lindex $pEnvelopeStrain 2] -[lindex $pEnvelopeStress 3] -[lindex $pEnvelopeStrain 3] [lindex $rDisp 0] [lindex $rForce 0] [lindex $uForce 0] [lindex $rDisp 1] [lindex $rForce 1] [lindex $uForce 1] [lindex $gammaK 0] [lindex $gammaK 1] [lindex $gammaK 2] [lindex $gammaK 3] [lindex $gammaK 4] [lindex $gammaD 0] [lindex $gammaD 1] [lindex $gammaD 2] [lindex $gammaD 3] [lindex $gammaD 4] [lindex $gammaF 0] [lindex $gammaF 1] [lindex $gammaF 2] [lindex $gammaF 3] [lindex $gammaF 4] $gammaE $damage
incr i
}
source ShearLink.tcl;


system BandGeneral

loadConst -time 0.0
source LibAnalysisDynamicParameters_stick.tcl;	# constraintsHandler,DOFnumberer,system-ofequations,convergenceTest,solutionAlgorithm,integrator
# ------------ define & apply damping
# RAYLEIGH damping parameters, Where to put M/K-prop damping, switches (http://opensees.berkeley.edu/OpenSees/manuals/usermanual/1099.htm)
#          D=$alphaM*M + $betaKcurr*Kcurrent + $betaKcomm*KlastCommit + $beatKinit*$Kinitial

set NumerModi 3;
set lambdaN [eigen $NumerModi];			# eigenvalue analysis for nEigenJ modes
set NumModi 0
while {$NumModi < [expr $NumerModi]} {
    set lambda($NumModi) [lindex $lambdaN [expr $NumModi]]; 	
    set omega($NumModi) [expr pow($lambda($NumModi),0.5)];
    incr NumModi 1
}

puts "First mode period is: [expr 2*$PI/$omega(0)]"
puts "Second mode period is: [expr 2*$PI/$omega(1)]"
puts "Third mode period is: [expr 2*$PI/$omega(2)]"



set xDamp 0.05;			# damping ratio

set MpropSwitch 1.0;
set KcurrSwitch 0.0;
set KcommSwitch 0.0;
set KinitSwitch 1.0;
set alphaM [expr $MpropSwitch*$xDamp*(2*$omega(0)*$omega(2))/($omega(0)+$omega(2))];	# M-prop. damping; D = alphaM*M
set betaKcurr [expr $KcurrSwitch*2.*$xDamp/($omega(0)+$omega(2))];         		# current-K;      +beatKcurr*KCurrent
set betaKcomm [expr $KcommSwitch*2.*$xDamp/($omega(0)+$omega(2))];   		# last-committed K;   +betaKcomm*KlastCommitt
set betaKinit [expr $KinitSwitch*2.*$xDamp/($omega(0)+$omega(2))];         			# initial-K;     +beatKinit*Kini

rayleigh $alphaM $betaKcurr $betaKinit $betaKcomm; 				# RAYLEIGH damping 


set dt $dt1
set tag1 4500
set tsTag1 4501
set path1 GMfiles/$GMfile1.txt
timeSeries Path $tag1 -dt $dt1 -filePath $path1 -factor $g
pattern UniformExcitation $tsTag1 1 -accel $tag1 -fact 1.00


# recorders for displacements and absolute accelerations
recorder Node -file "Data/$GMfile1-ACCEL_abs_STICK_$LEV.out" -timeSeries $tag1 -time  -nodeRange 1 [expr $Nstorey+1] -dof 1 accel;
recorder Node -file "Data/$GMfile1-DISP_STICK_$LEV.out" -timeSeries $tag1 -time  -nodeRange 1 [expr $Nstorey+1] -dof 1 disp;

		
set DtAnalysis	[expr $dt1];	# time-step Dt for lateral analysis (somma dei due terremoti e di un intertempo di 20 sec)
set TmaxAnalysis	[expr $dTMax1];

set controlTime [getTime];

set convLogFilename 	[open convLogFileOUT.out w]
set convPlotFilename	[open convPlotFileOUT.out w]
set dtForAnalysis $DtAnalysis
set numIncrForFranksAnalysis	1;
set dtFrank			[expr $dtForAnalysis];
set dtMinFrank			[expr $dtForAnalysis / 100.0];
set dtMaxFrank			[expr $dtForAnalysis];
# Define the ranges of tolerances to try for convergence.  Note that the maximum tolerance
#	used in the analsyis will be output in the output files.
	set testTolerance 1.0e-8
	set testMinTolerance1 1.0e-7;
	set testMinTolerance2 1.0e-6;
	set testMinTolerance3 1.0e-5;
	set testMinTolerance4 1.0e-4;
	set testMinTolerance5 1.0e-3;

# Define the iteration information used for difference situations and tests
	set testIterations 100;			# Changed on 1-7-05 for Corotational transformation
	set testInitialIterations 100;
	set testLowIter 10;			# Used to try each test in the loop
	set ratioForInitialAlgo	100;		# This is the ratio of testIterations that is allowed for -initial test
	set testHighIter 500;			# Used to try to make it converge at the very end
	set maxTolUsed $testTolerance;
set ok 0;
set controlTime [getTime];
set driftmax_rif 0;

while {($ok == 0) && ($controlTime < $TmaxAnalysis) } {;					# analysis was not successful.

#puts "tFinal is $TmaxAnalysis; and tCurrent is $controlTime"

		set controlTime [getTime];
		set currentTime $controlTime

		set ok [analyze $numIncrForFranksAnalysis $dtFrank $dtMinFrank $dtMaxFrank]
		set maxTolUsedInCurrentStep 	[expr $testTolerance]
		#### Change things for convergence ###############
		# If it's not ok, try to decrease dT, but keep the toerance the samecall another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testTolerance]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/10];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, try to decrease dT a bit more, but keep the toerance the samecall another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testTolerance]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/20];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, try to decrease dT a bit more, but keep the toerance the samecall another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testTolerance]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/40];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, try to decrease dT a bit more, but keep the toerance the samecall another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testTolerance]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/80];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance1...call another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testMinTolerance1]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/10];	# This was /20, so maybe change back?
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance1...call another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testMinTolerance1]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/20];	# This was /20, so maybe change back?
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance1...call another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testMinTolerance1]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/40];	# This was /20, so maybe change back?
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance1...call another file for this (just to keep this file clean)
		set currentTolerance 		[expr $testMinTolerance1]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt			[expr $dtForAnalysis/80];	# This was /20, so maybe change back?
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance2...call another file for this (just to keep this file clean)
		set currentTolerance 	[expr $testMinTolerance2]
		set currentNumIterations 	[expr $testLowIter]
		set currentDt		[expr $dtForAnalysis/10];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance3...call another file for this (just to keep this file clean)
		# Decrease dT more
		set currentTolerance 	[expr $testMinTolerance3]
		set currentNumIterations 	[expr $testHighIter]
		set currentDt		[expr $dtForAnalysis/20];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance4...call another file for this (just to keep this file clean)
		# Increase the number of iterations
		set currentTolerance 	[expr $testMinTolerance4]
		set currentNumIterations 	[expr $testHighIter]
		set currentDt		[expr $dtForAnalysis/20];
		source SolutionAlgorithmSubFile.tcl

		# If it's not ok, go to a more relaxed tolerance5...call another file for this (just to keep this file clean)
		set currentTolerance 	[expr $testMinTolerance5]
		set currentNumIterations 	[expr $testHighIter]
		set currentDt		[expr $dtForAnalysis/20];
		source SolutionAlgorithmSubFile.tcl

}


wipe;
