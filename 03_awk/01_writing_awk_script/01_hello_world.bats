#!/usr/bin/env bats

@test "hello world" {

	run awk '{ print }' <<< "hello world"
	[ "$output" == "hello world" ]

	test_string=$(cat <<-EOF 
	text text text
	text text text
	EOF
	)
	run awk '{ print "hello world" }' <<< "$test_string"
	expect=$(cat <<-EOF 
	hello world
	hello world
	EOF
	)
	[ "$output" == "$expect" ]

	# Both of these examples illustrate that awk is usually input-driven. That is, nothing happens unless there are lines of input on which to act. When you invoke the awk program, it reads the script that you supply, checking the syntax of your instructions. Then awk attempts to execute the instructions for each line of input. Thus, the print statement will not be executed unless there is input from the file.


	# The BEGIN pattern specifies actions that are performed before the first line of input is read. If a program has only a BEGIN pattern, and no other statements, awk will not process any input files.
	run awk 'BEGIN { print "hello world" }'
	[ "$output" == "hello world" ]

	# The END pattern specifies actions that are performed after all input is read.
	run awk 'END { print "hello world" }' <<< "$test_string"
	[ "$output" == "hello world" ]
}
