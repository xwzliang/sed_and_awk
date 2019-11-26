#!/usr/bin/env bats

@test "test multiline next" {
	test_string=$(cat <<-EOF 
	text text pattern_part_1
	pattern_part_2 text text
	EOF
	)

	# Multiline Next N: The multiline Next (N) command creates a multiline pattern space by reading a new line of input and appending it to the contents of the pattern space. The original contents of pattern space and the new input line are separated by a newline.
	# In a multiline pattern space, the metacharacter “^” matches the very first character of the pattern space, and not the character(s) following any embed-ded newline(s). Similarly, “$” matches only the final newline in the pattern space, and not any embedded newline(s).
	run sed '/pattern_part_1/{
		N
		s/pattern_part_1\npattern_part_2/replacement/
	}' <<< $test_string		# Replace pattern_part_1 in line 1 and pattern_part_2 in line 2 with replacement
	expect=$(cat <<-EOF 
	text text replacement text text
	EOF
	)
	[ "$output" == "$expect" ]

	test_string=$(cat <<-EOF 
	text text pattern_part_1
	text text text
	pattern_part_2 text text
	EOF
	)
	run sed '/pattern_part_1/{
		N
		N
		s/pattern_part_1\n.*\npattern_part_2/replacement/
	}' <<< $test_string		# N will only append next line to pattern space, if pattern_part_2 is at third line, two N are needed
	[ "$output" == "$expect" ]


	run sed '/pattern_part/{
		N
		cThis is new replacement.
	}' <<< $test_string		# If the pattern matches the last line, N will cause sed to quit without executing followed commands
	expect=$(cat <<-EOF 
	This is new replacement.
	pattern_part_2 text text
	EOF
	)
	[ "$output" == "$expect" ]

	run sed '/pattern_part/{
		$!N
		cThis is new replacement.
	}' <<< $test_string		# $!N tells sed don't execute N on the last line
	expect=$(cat <<-EOF 
	This is new replacement.
	This is new replacement.
	EOF
	)
	[ "$output" == "$expect" ]
}
