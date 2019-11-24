#!/usr/bin/env bats

@test "test transform" {
	test_string=$(cat <<-EOF 
	a b c b
	b c d c
	EOF
	)

	# Transform y: This command "y/abc/xyz" transforms each character by position in string abc to its equivalent in string xyz
	run sed '/b c b/y/abc/ABC/' <<< $test_string		# Delete the whole line containing 'b c b'
	expect=$(cat <<-EOF 
	A B C B
	b c d c
	EOF
	)
	echo "$output"
	[ "$output" == "$expect" ]
}
