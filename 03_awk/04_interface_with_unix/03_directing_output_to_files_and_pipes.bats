#!/usr/bin/env bats

@test "getline" {
	# The output of any print or printf statement can be directed to a file, using the output redirection operators “>” or “>>”.
	# The filename can be any expression that evaluates to a valid filename. A file is opened by the first use of the redirection operator, and subsequent uses append data to the file. The difference between “>” and “>>” is the same as between the shell redirection operators. A right-angle bracket (“>”) truncates the file when opening it while “>>” preserves whatever the file contains and appends data to it.

	awk '
	BEGIN { 
		a = 2
		b = 3
		print "a =", a, "b =", b, "max =", (a > b ? a : b) > "test.tmp"
		a = 5
		b = 4
		print "a =", a, "b =", b, "max =", (a > b ? a : b) > "test.tmp"
	}
	' 
	run cat test.tmp

	expect=$(cat <<-'EOF' 
	a = 2 b = 3 max = 3
	a = 5 b = 4 max = 5
	EOF
	)
	[ "$output" == "$expect" ]


	# Append to file
	awk '
	BEGIN { 
		filename = "test.tmp"
		print "New appended line" >> filename
	}
	' 
	run cat test.tmp

	expect=$(cat <<-'EOF' 
	a = 2 b = 3 max = 3
	a = 5 b = 4 max = 5
	New appended line
	EOF
	)
	[ "$output" == "$expect" ]


	# You can also direct output to a pipe. The command
	# 	print | command
	# opens a pipe the first time it is executed and sends the current record as input to that command. In other words, the command is only invoked once, but each execution of the print command supplies another line of input.

	test_string=$(cat <<-EOF 
	This is a line
	Another line
	Another line
	EOF
	)

	run awk '
	{ 
		print | "wc -w"		# get word count
	}
	' <<< "$test_string"

	expect=$(cat <<-'EOF' 
	8
	EOF
	)
	[ "$output" == "$expect" ]

}
