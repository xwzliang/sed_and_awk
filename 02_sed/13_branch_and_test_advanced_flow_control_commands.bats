#!/usr/bin/env bats

@test "test branch and test" {
	# The branch (b) and test (t) commands transfer control in a script to a line containing a specified label. If no label is specified, control passes to the end of the script. The branch command transfers control unconditionally while the test command is a conditional transfer, occurring only if a substitute command has changed the current line.

	# branch b [label]: The label is optional, and if not supplied, control is transferred to the end of the script. If a label is supplied, execution resumes at the line following the label.

	test_string=$(cat <<-EOF 
	Here are examples of the UNIX
	System. Where UNIX
	text text text
	text text text
	System appears, it should be the UNIX
	text text text
	Operating System.
	text text text
	text text text
	EOF
	)

	run sed -n '
		/UNIX/b
		/Operating System/b
		p
	' <<< $test_string	# Skip lines containing UNIX or Operating System
	expect=$(cat <<-EOF 
	text text text
	text text text
	text text text
	text text text
	text text text
	EOF
	)
	[ "$output" == "$expect" ]

	test_string=$(cat <<-EOF 
	text text pattern_part_1
	text text text
	text text text
	text text text
	pattern_part_2 text text
	EOF
	)
	run sed '/pattern_part_1/{
		:loop
		N
		/pattern_part_2/b jump
		b loop	# If pattern_part_2 not found, continue to append lines to pattern space
		:jump
		s/pattern_part_1\n.*\npattern_part_2/replacement/
	}' <<< $test_string		# replace pattern_part_1, pattern_part_2 and whatever lines between them with replacement
	expect=$(cat <<-EOF 
	text text replacement text text
	EOF
	)
	[ "$output" == "$expect" ]


	# test t [label]: branch to a label (or the end of the script) if a successful substitution has been made on the currently addressed line. If no label is supplied, control falls through to the end of the script. If the label is supplied, then execution resumes at the line following the label.

	run sed '/pattern_part_1/{
		:loop
		N
		s/pattern_part_1\n.*\npattern_part_2/replacement/
		t
		b loop	# If substitution is not sucessfull, continue to append lines to pattern space
	}' <<< $test_string		# replace pattern_part_1, pattern_part_2 and whatever lines between them with replacement
	[ "$output" == "$expect" ]

	test_string=$(cat <<-EOF 
	text text pattern_part_1
	text text text
	text text text
	text text text
	pattern_part_2 text pattern_part_1
	text text text
	pattern_part_2 text text
	EOF
	)
	run sed '
		/pattern_part_1/{
		:loop
		N
		s/pattern_part_1\n.*\npattern_part_2 /replacement\n/
		t jump
		b loop	# If substitution is not sucessfull, continue to append lines to pattern space
		}
		:jump	# Jump to label jump to output first part of pattern space and continue checking
		P
		D
	' <<< $test_string		# replace pattern_part_1, pattern_part_2 and whatever lines between them with replacement
	expect=$(cat <<-EOF 
	text text replacement
	text replacement
	text text
	EOF
	)
	[ "$output" == "$expect" ]

}
