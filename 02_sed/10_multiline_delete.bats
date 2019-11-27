#!/usr/bin/env bats

@test "test multiline delete" {
	test_string=$(cat <<-EOF 
	This line is followed by 1 blank line.

	This line is followed by 2 blank lines.


	This line is followed by 3 blank lines.



	This line is followed by 4 blank lines.




	This is the end.
	EOF
	)

	# Multiline Delete D: it deletes a portion of the pattern space, up to the first embedded newline. It does not cause a new line of input to be read; instead, it returns to the top of the script, applying these instructions to what remains in the pattern space.
	run sed '/^$/{
		N
		/^\n$/D
	}' <<< $test_string		# reduce multiple blank lines to one
	# when we encounter two blank lines, the Delete command removes only the first of the two. The next time through the script, the blank line will cause another line to be read into the pattern space. If that line is not blank, then both lines are output, thus ensuring that a single blank line will be output. In other words, when there are two blank lines in the pattern space, only the first one is deleted. When there is a blank line followed by text, the pattern space is output normally.
	expect=$(cat <<-EOF 
	This line is followed by 1 blank line.

	This line is followed by 2 blank lines.

	This line is followed by 3 blank lines.

	This line is followed by 4 blank lines.

	This is the end.
	EOF
	)
	[ "$output" == "$expect" ]

	# If we use normal d, d will delete the whole multiline pattern space. Where there was an even number of blank lines, all the blank lines were removed. Only when there was an odd number was a single blank line preserved. That is because the delete command clears the entire pattern space. Once the first blank line is encountered, the next line is read in, and both are deleted. If a third blank line is encountered, and the next line is not blank, the delete command is not applied, and thus a blank line is output.
	run sed '/^$/{
		N
		/^\n$/d
	}' <<< $test_string		
	expect=$(cat <<-EOF 
	This line is followed by 1 blank line.

	This line is followed by 2 blank lines.
	This line is followed by 3 blank lines.

	This line is followed by 4 blank lines.
	This is the end.
	EOF
	)
	[ "$output" == "$expect" ]
}
