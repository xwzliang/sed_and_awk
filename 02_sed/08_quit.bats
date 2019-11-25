#!/usr/bin/env bats

@test "test quit" {
	test_string=$(cat <<-EOF 
	a b c b
	b c d c
	EOF
	)

	# Quit q: stop reading new input lines and stop sending them to the output
	run sed '/b c b/q' <<< $test_string		# Quit after finding the line containing pattern "b c b"
	expect=$(cat <<-EOF 
	a b c b
	EOF
	)
	[ "$output" == "$expect" ]


	run sed '1q' <<< $test_string		# Quit after printing the first line
	expect=$(cat <<-EOF 
	a b c b
	EOF
	)
	[ "$output" == "$expect" ]
	# "sed '10q'" generates the same result as "sed -n '1,10p'", but using 10q is better than 1,10p, especially with large files, or complex script. Because q will stop running instead of going through the whole file and script, this could be a significant time-saver.
}
