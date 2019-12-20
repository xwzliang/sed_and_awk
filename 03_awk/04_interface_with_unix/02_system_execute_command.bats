#!/usr/bin/env bats

@test "system" {
	# The system() function executes a command supplied as an expression.It does not, however, make the output of the command available within the program for processing. It returns the exit status of the command that was executed. The script waits for the command to finish before continuing execution.

	run awk '
	BEGIN { 
		system("rm -rf tmp")
		if (system("mkdir tmp") != 0)
			print "Command failed"
	}
	'
	[ "$output" == "" ]
	[ -d tmp ]

	run awk '
	BEGIN { 
		if (system("mkdir tmp") != 0)
			print "Command failed"
	}
	'
	expect=$(cat <<-'EOF' 
	mkdir: cannot create directory ‘tmp’: File exists
	Command failed
	EOF
	)
	[ "$output" == "$expect" ]


	run awk '
	BEGIN { 
		str = "Hello, world"
		system("echo " str)		# concatenate strings for system command
	}
	'
	expect=$(cat <<-'EOF' 
	Hello, world
	EOF
	)
	[ "$output" == "$expect" ]

}
