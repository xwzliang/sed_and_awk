#!/usr/bin/env bats

@test "expressions" {
	# Variables are not declared; you do not have to tell awk what type of value will be stored in a variable. Each variable has a string value and a numeric value, and awk uses the appropriate value based on the context of the expression. (Strings that do not consist of numbers have a numeric value of 0.) Variables do not have to be initialized, awk automatically initializes them to the empty string, which acts like 0 if used as a number.
	
	# A space is the string concatenation operator.
	run awk ' 
	BEGIN { 
		z = "hello " "world" 
		print z
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	hello world
	EOF
	)
	[ "$output" == "$expect" ]


	test_string=$(cat <<-EOF 
	John Robinson		666-555-1111


	John Robinson		666-555-1111

	John Robinson		666-555-1111
	EOF
	)
	# Count blank lines
	run awk ' 
	/^$/	{ count++ }
	END		{ print count }
	' <<< "$test_string"
	[ "$output" == 3 ]


	test_string=$(cat <<-EOF 
	john 85 92 78 94 88
	andrea 89 90 75 90 86
	jasper 84 88 80 92 84
	EOF
	)
	# Averaging student grades
	run awk ' 
	{
		total = $2 + $3 + $4 + $5 + $6
		avg = total / 5
		print $1, avg
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	john 87.4
	andrea 86
	jasper 85.6
	EOF
	)
	[ "$output" == "$expect" ]
}
