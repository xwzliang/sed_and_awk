#!/usr/bin/env bats

@test "addressing in sed" {
	test_string=$(cat <<- EOF 
	John Daggett, 341 King Road, Plymouth MA
	Alice Ford, 22 East Broadway, Richmond VA
	Eric Adams, 20 Post Road, Sudbury MA
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	EOF
	)

	# If no address is specified, then the command is applied to each line
	run sed 'd' <<< $test_string
	[ "$output" == "" ]

	# If ther e is only one address, the command is applied to any line matching the address.
	# When a line number is supplied as an address, the command affects only that line. For instance, the following example deletes only the first line:
	run sed '1d' <<< $test_string
	expect=$(cat <<- EOF 
	Alice Ford, 22 East Broadway, Richmond VA
	Eric Adams, 20 Post Road, Sudbury MA
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	EOF
	)
	[ "$output" == "$expect" ]

	# To delete the last line
	run sed '$d' <<< $test_string
	expect=$(cat <<- EOF 
	John Daggett, 341 King Road, Plymouth MA
	Alice Ford, 22 East Broadway, Richmond VA
	Eric Adams, 20 Post Road, Sudbury MA
	Hubert Sims, 328A Brook Road, Roanoke VA
	EOF
	)
	[ "$output" == "$expect" ]

	# If two comma-separated addresses are specified, the command is performed on the first line matching the first address and all succeeding lines up to and including a line matching the second address.
	run sed '3,$d' <<< $test_string		# Delete from 3rd line to the end
	expect=$(cat <<- EOF 
	John Daggett, 341 King Road, Plymouth MA
	Alice Ford, 22 East Broadway, Richmond VA
	EOF
	)
	[ "$output" == "$expect" ]

	# An address can be a regular expression describing a pattern
	run sed '/MA/d' <<< $test_string	# Delete all lines containing 'MA'
	expect=$(cat <<- EOF 
	Alice Ford, 22 East Broadway, Richmond VA
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	EOF
	)
	[ "$output" == "$expect" ]
	run sed '/MA/,/VA/d' <<< $test_string	# Delete lines from containing 'MA' to 'VA'
	expect=$(cat <<- EOF 
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	EOF
	)
	[ "$output" == "$expect" ]

	# Line number and pattern address can be mixed
	run sed '1,/Eric/d' <<< $test_string	# Delete from first line to line containing 'Eric'
	expect=$(cat <<- EOF 
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	EOF
	)
	[ "$output" == "$expect" ]

	# If address is followed by an exclamation mark (!), the command is applied to all lines that do not match the address.
	run sed '/MA/!d' <<< $test_string	# Delete all lines except lines containing 'MA'
	expect=$(cat <<- EOF 
	John Daggett, 341 King Road, Plymouth MA
	Eric Adams, 20 Post Road, Sudbury MA
	EOF
	)
	[ "$output" == "$expect" ]

	run sed '1,/Eric/!d' <<< $test_string	# Delete all lines except from first line to line containing 'Eric'
	expect=$(cat <<- EOF 
	John Daggett, 341 King Road, Plymouth MA
	Alice Ford, 22 East Broadway, Richmond VA
	Eric Adams, 20 Post Road, Sudbury MA
	EOF
	)
	[ "$output" == "$expect" ]


	# Use braces for grouping multiple commands
	run sed -n '/Eric/{
		s/Adams/Daggett/
		s/MA/VA/
		p
	}' <<< $test_string	# Print the lines containing 'Eric' after several replacement
	expect=$(cat <<- EOF 
	Eric Daggett, 20 Post Road, Sudbury VA
	EOF
	)
	[ "$output" == "$expect" ]
}
