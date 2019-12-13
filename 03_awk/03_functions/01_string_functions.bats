#!/usr/bin/env bats

@test "string functions" {
	# gsub(regular_expression, replacement_string, target_string)	replace all match of regular_expression in target_string with replacement_string. If target_string is not supplied, defaults to $0
	# sub(regular_expression, replacement_string, target_string)	replace first match of regular_expression in target_string with replacement_string. If target_string is not supplied, defaults to $0
	# index(target_string, substring)	returns the position of substring in target_string or zero if not present
	# substr(target_string, position, length)	returns substring of target_string at beginning position up to a maximum length. If length is not supplied, the rest of the string from position is used.
	# length(target_string)	returns the length of target_string or length of $0 if target_string is not supplied
	# match(target_string, regular_expression)	returns the position in target_string where the regular_expression begins, or zero if no occurrences are found. Sets the values of RSTART and RLENGTH. RSTART contains the same value retur ned by the function, the starting position of the substring. RLENGTH contains the length of the string in characters (not the ending position of the substring). When the pattern does not match, RSTART is set to 0 and RLENGTH is set to -1. (Adding them together gives you the position of the first character after the match.)
	# n = split(string,array,separator)
	# tolower(target_string)	translates all uppercase characters in target_string to lowercase and returns the new string. target_string must be supplied.
	# toupper(target_string)	translates all lowercase characters in target_string to uppercase and returns the new string. target_string must be supplied.
	# new_variable = sprintf("format", expression_or_variable)	Use printf format specification for expression_or_variable

	# The regular expression can be supplied by a variable, in which case the slashes are omitted.

	test_string=$(cat <<-EOF 
	Every NOW and then, a WORD I type appears in CAPS.
	EOF
	)

	# Convert uppercase to lowercase 
	run awk '
	BEGIN {
		alphabet_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		alphabet_lower = "abcdefghijklmnopqrstuvwxyz"
	}

	{
		# See if there is a match for all capitals.
		while (match($0, /[A-Z]+/))
			for (x = RSTART; x < RSTART+RLENGTH; ++x) {
				cap_char = substr($0, x, 1)
				char_location_alphabet = index(alphabet_upper, cap_char)
				# substitute uppercase with lowercase
				gsub(cap_char, substr(alphabet_lower, char_location_alphabet, 1))
			}
		print $0
	}
	' <<< $test_string

	expect=$(cat <<-EOF 
	every now and then, a word i type appears in caps.
	EOF
	)
	[ "$output" == "$expect" ]

	# or we can use tolower
	run awk '{ print tolower($0) }' <<< $test_string
	[ "$output" == "$expect" ]


	# Convert number to char using sprintf
	run awk '
	BEGIN {
		for (i = 97; i < 100; i++) {
			char = sprintf("%c", i)
			print char
		}
	}
	'
	expect=$(cat <<-EOF 
	a
	b
	c
	EOF
	)
	[ "$output" == "$expect" ]
}
