#!/usr/bin/env bats

@test "test list print and print line number" {
	test_string=$(cat <<-EOF 
	a	b c b
	b	c d c
	EOF
	)

	# List l: display the contents of the pattern space, showing also the non-printing characters
	run sed -n '/b c b/l' <<< $test_string		# list line containing the pattern
	expect=$(cat <<-EOF 
	a\tb c b$
	EOF
	)
	[ "$output" == "$expect" ]

	# Print p: print line (only printable characters)
	run sed -n '/b c b/p' <<< $test_string		# print line containing the pattern
	expect=$(cat <<-EOF 
	a	b c b
	EOF
	)
	[ "$output" == "$expect" ]

	# Print line number = (this command cannot operate on a range of lines)
	run sed -n '/b c b/=' <<< $test_string		# print line number of the line containing the pattern
	expect=$(cat <<-EOF 
	1
	EOF
	)
	[ "$output" == "$expect" ]

	# Print line number and line itself
	run sed -n '/c/{
		=
		p
	}' <<< $test_string	
	expect=$(cat <<-EOF 
	1
	a	b c b
	2
	b	c d c
	EOF
	)
	[ "$output" == "$expect" ]
}
