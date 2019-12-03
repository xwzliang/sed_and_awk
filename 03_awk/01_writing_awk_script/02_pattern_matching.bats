#!/usr/bin/env bats

@test "pattern matching" {
	# When awk reads an input line, it attempts to match each pattern-matching rule in a script. Only the lines matching the particular pattern are the object of an action. If no action is specified, the line that matches the pattern is printed (executing the print statement is the default action).

	test_string=$(cat <<-EOF 
	4
	t
	4T

	44
	test print default
	EOF
	)
	run awk ' 
		/[0-9]+/	{ print "That is an integer" }
		/[A-Za-z]+/	{ print "This is a string" }
		/^$/		{ print "This is a blank line" }
		/print/		# This will execute the default print action
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	That is an integer
	This is a string
	That is an integer
	This is a string
	This is a blank line
	That is an integer
	This is a string
	test print default
	EOF
	)
	[ "$output" == "$expect" ]
	# Note that input “4T” was identified as both an integer and a string. A line can match more than one rule. The last line of input "test print default" also matches string and "print" pattern.
}
