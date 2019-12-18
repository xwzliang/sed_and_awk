#!/usr/bin/env bats

@test "gensub function" {
	# gawk provides gensub function (general substitution)
	# 	gensub(regular_expression, replacement_string, flag, target_string)
	# The flag is either a string beginning with g or G, in which case the substitution happens globally, or it is a number indicating that the nth occurrence should be replaced.
	# The pattern can have subpatterns delimited by parentheses. For example, it can have “/(part) (one|two|three)/”. Within the replacement string, a backslash followed by a digit represents the text that matched the nth subpattern.
	# If target_string is not provided, $0 is used.

	test_string=$(cat <<-EOF 
	part two part three
	a b c a b c
	EOF
	)

	run awk '{ print gensub(/(part) (one|two|three)/, "\\2", "g") }' <<< $test_string
	# awk requires arguments for functions to be string, so "\" ifself needs to be backslashed as "\\"

	expect=$(cat <<-'EOF' 
	two three
	a b c a b c
	EOF
	)
	[ "$output" == "$expect" ]


	run awk '{ print gensub(/a/, "AA", 2) }' <<< $test_string

	expect=$(cat <<-'EOF' 
	part two pAArt three
	a b c AA b c
	EOF
	)
	[ "$output" == "$expect" ]


	# Unlike sub() and gsub(), the target_string is not changed. Instead, the new string is the return value from gensub().
	run awk '
	BEGIN { 
		old_string = "hello, world"
		new_string = gensub(/hello/, "hey", 1, old_string)
		printf("<%s>, <%s>\n", old_string, new_string)
	}
	'
	expect=$(cat <<-'EOF' 
	<hello, world>, <hey, world>
	EOF
	)
	[ "$output" == "$expect" ]
}
