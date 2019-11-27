#!/usr/bin/env bats

@test "test multiline delete" {
	test_string=$(cat <<-EOF 
	Here are examples of the UNIX
	System. Where UNIX
	System appears, it should be the UNIX
	Operating System.
	EOF
	)

	# Multiline Print P: outputs the first portion of a multiline pattern space, up to the first embed-ded newline.
	# The Print command frequently appears after the Next command and before the Delete command. These three commands can set up an input/output loop that maintains a two-line pattern space yet outputs only one line at a time. The purpose of this loop is to output only the first line in the pattern space, then return to the top of the script to apply all commands to what had been the second line in the pattern space. Without this loop, when the last command in the script was executed, both lines in the pattern space would be output.
	run sed '/UNIX$/{
		N
		/\nSystem/{
		s// Operating&/
		P
		D
		}
	}' <<< $test_string		# replace UNIX with UNIX Operating when the line contains UNIX at the end and next line contains System
	# The input/output loop lets us match the occurrence of UNIX at the end of the sec-ond line. It would be missed if the two-line pattern space was output normally.
	expect=$(cat <<-EOF 
	Here are examples of the UNIX Operating
	System. Where UNIX Operating
	System appears, it should be the UNIX
	Operating System.
	EOF
	)
	[ "$output" == "$expect" ]
}
