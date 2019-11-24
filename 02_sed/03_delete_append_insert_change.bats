#!/usr/bin/env bats

@test "test delete append insert change" {
	test_string=$(cat <<-EOF 
	a b c b
	b c d c
	EOF
	)

	# Delete d: if the line matches the address, the entire line is deleted
	run sed '/b c b/d' <<< $test_string		# Delete the whole line containing 'b c b'
	expect=$(cat <<-EOF 
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]

	# Insert i
	run sed '/b c b/iThis is new text.' <<< $test_string		# Insert one line before the matching line
	expect=$(cat <<-EOF 
	This is new text.
	a b c b
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]
	# To input multiple lines of text, each successive line must end with a backslash, with the exception of the very last line.
	run sed '/b c b/i\
This is new text.\
Multiline text like this.' <<< $test_string		# Insert multiple lines before the matching line
	expect=$(cat <<-EOF 
	This is new text.
	Multiline text like this.
	a b c b
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]

	# Append a
	run sed '$aThis is new text.' <<< $test_string		# Append one line after the last line
	expect=$(cat <<-EOF 
	a b c b
	b c d c
	This is new text.
	EOF
	)
	[ "$output" == "$expect" ]

	# Change c
	run sed '/b c b/cThis is new text.' <<< $test_string		# Change the matching line
	expect=$(cat <<-EOF 
	This is new text.
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]
	# The append and insert commands can be applied only to a single line address, not a range of lines. The change command, however, can address a range of lines. In this case, it replaces all addressed lines with a single copy of the text.
	run sed '/b c b/,/b c d/c\
This is new text.\
Multiline text like this.' <<< $test_string		# Change the matching line ranges
	expect=$(cat <<-EOF 
	This is new text.
	Multiline text like this.
	EOF
	)
	[ "$output" == "$expect" ]
	# Note that you will see the opposite behavior when the change command is one of a group of commands, enclosed in braces, that act on a range of lines. The change command will execute on every line of the line range, so we will get multiple copies of the text.
	run sed '/b c b/,/b c d/{
		s/b c b/replacement/
		cThis is new text.
	}' <<< $test_string	
	expect=$(cat <<-EOF 
	This is new text.
	This is new text.
	EOF
	)
	[ "$output" == "$expect" ]
}
