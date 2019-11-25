#!/usr/bin/env bats

@test "test next" {
	test_string=$(cat <<-EOF 
	a b c b
	a b c b
	b c d c
	EOF
	)

	# Next n: reads the next line of input without returning to the top of the script
	run sed '/b c b/{
		n
		y/abc/ABC/
	}' <<< $test_string		# Transform the next of the line containing 'b c b'
	expect=$(cat <<-EOF 
	a b c b
	A B C B
	b c d c
	EOF
	)
	# Notice that only the second line is transformed, the third line is intact, this is because the second line has already been read and transformed
	[ "$output" == "$expect" ]
}
