#!/usr/bin/env bats

@test "records and fields" {
	# Awk makes the assumption that its input is structured and not just an endless string of characters. In the simplest case, it takes each input line as a record and each word, separated by spaces or tabs, as a field. (The characters separating the fields are often referred to as delimiters.)

	# The default delimiter is a space, but will be referred to as whitespace, which is one or more spaces or tabs
	test_string=$(cat <<-EOF 
	John Robinson		666-555-1111
	EOF
	)
	run awk '{ print $2, $1, $3 }' <<< "$test_string"
	# By default, the commas that separate each argument in the print statement cause a space to be output between the values. (output field separator OFS is a space by default)
	expect=$(cat <<-EOF 
	Robinson John 666-555-1111
	EOF
	)
	[ "$output" == "$expect" ]

	# You can use any expression that evaluates to an integer to refer to a field, not just numbers and variables
	run awk ' 
		BEGIN { a = 1; b = 2 }
		{ print $(a + b) }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	666-555-1111
	EOF
	)
	[ "$output" == "$expect" ]

	# You can change the delimiter by awk option -F
	run awk -F "\t" '
	{ 
		print $1
		print $2
		print $3
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John Robinson

	666-555-1111
	EOF
	)
	# When FS is any single character, each occurrence of that character separates another field. If there are two successive occurrences, the field between them simply has the empty string as its value.
	# There are two tabs between "John Robinson" and "666-555-1111", so the second field is a null string
	[ "$output" == "$expect" ]

	# It is usually a better practice, and more convenient, to specify the field separator in the script itself. The system variable FS can be defined to change the field separator. Because this must be done before the first input line is read, we must assign this variable in an action controlled by the BEGIN rule.
	run awk '
	BEGIN { FS = "\t" }
	{ 
		print $1
		print $2
		print $3
	}
	' <<< "$test_string"
	[ "$output" == "$expect" ]

	# if you specify more than a single character as the field separator, it will be interpr eted as a regular expression.
	run awk '
	BEGIN { FS = "\t+" }
	{ 
		print $1
		print $2
		print $3
	}
	' <<< "$test_string"
	# There is no $3 when the FS is "\t+", awk will output blank line
	expect=$(cat <<-EOF 
	John Robinson
	666-555-1111

	EOF
	)
	[ "$output" == "$expect" ]

	# Specify multiple delimiters using regular expression (tab, space and hyphen)
	run awk '
	BEGIN { FS = "[\t -]" }
	{ 
		print $1
		print $2
		print $3
		print $4
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John
	Robinson

	666
	EOF
	)
	[ "$output" == "$expect" ]


	# We can test a specific field for a match. The tilde (~) operator allows you to test a regular expression against a field.
	run awk '
	BEGIN { FS = "[\t -]" }
	$4 ~ /666/ { print $4 }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	666
	EOF
	)
	[ "$output" == "$expect" ]

	# You can reverse the meaning of the rule by using bang-tilde (!~)
	run awk '
	BEGIN { FS = "[\t -]" }
	$4 !~ /555/ { print $4 }
	' <<< "$test_string"
	[ "$output" == "$expect" ]
}
