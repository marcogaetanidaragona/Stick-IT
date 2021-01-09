#----------------------------------------------------------------------------------#
# SolutionAlgorithmSubFile
#		This file is called by the CordovaMod solution algorithm that is defined in
#		the functions and procedures file.  This is only put in a seperate file to
#		make the function file not be as long and to call the same solution algorithm,
#		with a relaxed tolerance, ratehr than repreating the code multiple times.
#
# Units: kips, in, sec
#
# This file developed by: Curt Haselton of Stanford University
# Updated: 28 June 2005
# Date: August 2004
#
# Other files used in developing this model:
#		None
#----------------------------------------------------------------------------------#


# Solution algorithm - this is called repetitively by another solution algorithm file.

	# If the initial step didn't work, then alter the time step and the tolerance, and try different solution algorithms
    	if {$ok != 0} {
		puts "that failed - lets try some changes to dt and the solution algorithm"
		test $testType $currentTolerance $testIterations 1
		algorithm NewtonLineSearch 0.6;	# This is probably already what I am using
		set ok [analyze 1 [expr $currentDt]]
#		set ok [analyze 1 [expr $dtForAnalysis]]
		test $testType $testTolerance $testIterations 0
		algorithm $iterAlgo

		# Reset the tolerance output if it got in this loop and if it has gotten to a tolerance larger than it ever did previously
		if {$maxTolUsed < $currentTolerance} {
			set maxTolUsed $currentTolerance
		}

		# Reset the current tolerance used value if it was just increased
		if {$maxTolUsedInCurrentStep < $currentTolerance} {
			set maxTolUsedInCurrentStep $currentTolerance
		}

		# Write a line in the convergence log telling what happened that this step
		set convFileLine "Used tolerance of $currentTolerance , time $currentTime, dT = $currentDt, with NewtonLineSearch"
		#puts $convLogFilename $convFileLine


    	}

	# Try other algorithms
    	if {$ok != 0} {
		puts "that failed - lets try Newton ..."
		test $testType $currentTolerance $testIterations 0
		algorithm Newton
		set ok [analyze 1 $currentDt]
		test $testType $testTolerance $testIterations 0
		algorithm $iterAlgo

		# Write a line in the convergence log telling what happened that this step
		set convFileLine "Used tolerance of $currentTolerance, time $currentTime, dT = $currentDt, with Newton"
		#puts $convLogFilename $convFileLine

		# Reset the current tolerance used value if it was just increased
		if {$maxTolUsedInCurrentStep < $currentTolerance} {
			set maxTolUsedInCurrentStep $currentTolerance
		}

	}
    	if {$ok != 0} {
		puts "that failed - lets try initial stiffness ..."
		test $testType $currentTolerance $testIterations 0
		algorithm ModifiedNewton -initial
		set ok [analyze 1 $currentDt]
		test $testType $testTolerance [expr $testIterations * $ratioForInitialAlgo] 0
		algorithm $iterAlgo

		# Write a line in the convergence log telling what happened that this step
		set convFileLine "Used tolerance of $currentTolerance , time $currentTime, dT = $currentDt, with Newton -initial"
		#puts $convLogFilename $convFileLine

		# Reset the current tolerance used value if it was just increased
		if {$maxTolUsedInCurrentStep < $currentTolerance} {
			set maxTolUsedInCurrentStep $currentTolerance
		}

    	}


## I am commenting out these next algorithms based on RUN-TIME problems and ERRORS that happen with these
##	algorithms.  See hand notes dated 9-16-04 for more detailed information.
#
#    	if {$ok != 0} {
#		puts "that failed - lets try krylov newton ..."
#		algorithm KrylovNewton
#		test $testType $currentTolerance $testIterations 1
#		set ok [analyze 1 $currentDt]
#		test $testType $testTolerance $testIterations 0
#		algorithm $iterAlgo
#
#		# Write a line in the convergence log telling what happened that this step
#		set convFileLine "Used tolerance of $currentTolerance, time $currentTime, dT = $currentDt, with KrylovNewton"
#		puts $convLogFilename $convFileLine
#
#		# Reset the current tolerance used value if it was just increased
#		if {$maxTolUsedInCurrentStep < $currentTolerance} {
#			set maxTolUsedInCurrentStep $currentTolerance
#		}
#
#    	}
#    	if {$ok != 0} {
#		puts "that failed - lets try krylov newton with initial ..."
#		test $testType $currentTolerance $testIterations 1
#		algorithm KrylovNewton -initial
#		set ok [analyze 1 $currentDt]
#		test $testType $testTolerance $testIterations 0
#		algorithm $iterAlgo
#
#		# Write a line in the convergence log telling what happened that this step
#		set convFileLine "Used tolerance of $currentTolerance, time $currentTime, dT = $currentDt, with KrylovNewton -initial"
#		puts $convLogFilename $convFileLine
#
#		# Reset the current tolerance used value if it was just increased
#		if {$maxTolUsedInCurrentStep < $currentTolerance} {
#			set maxTolUsedInCurrentStep $currentTolerance
#		}
#
#	}
#
#
#
#
#
#
