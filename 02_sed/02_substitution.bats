#!/usr/bin/env bats

@test "sed substitution" {
	# The syntax of sed substitution command
		# [address]s/pattern/replacement/flags
	# where the flags that modify the substitution are:
		# n A number (1 to 512) indicating that a replacement should be made for only the nth occurrence of the patter n.
		# g Make changes globally on all occurrences in the pattern space. Normally only the first occurrence is replaced.
		# p Print the contents of the pattern space.
		# w file
		# Write the contents of the pattern space to file.
	test_string=$(cat <<-EOF 
	a b c b
	b c d c
	EOF
	)

	run sed 's/b/d/2' <<< $test_string		# Change the second b of the line to d
	expect=$(cat <<-EOF 
	a b c d
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]

	run sed 's/b/d/g' <<< $test_string		# Change all b of the line to d
	expect=$(cat <<-EOF 
	a d c d
	d c d c
	EOF
	)
	[ "$output" == "$expect" ]

	run sed -n 's/a/d/p' <<< $test_string		# Change a of the line to d and print to stdout
	expect=$(cat <<-EOF 
	d b c b
	EOF
	)
	[ "$output" == "$expect" ]

	sed 's/a/d/w sample.tmp' <<< $test_string		# Change a of the line to d and write to file
	run cat sample.tmp
	expect=$(cat <<-EOF 
	d b c b
	EOF
	)
	[ "$output" == "$expect" ]


	# In the replacement section, use & to refer to the whole string that matches the pattern, use \number to refer to the nth substring group specified using "\(" and "\)"
	run sed 's/d/@&@/' <<< $test_string		# Change d of the line to @d@
	expect=$(cat <<-EOF 
	a b c b
	b c @d@ c
	EOF
	)
	[ "$output" == "$expect" ]

	run sed 's/b c \(b\)/@\1@/' <<< $test_string		# Change "b c b" of the line to @b@
	expect=$(cat <<-EOF 
	a @b@
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]


	# Unlike addresses, which requir e a slash (/) as a delimiter, the regular expression can be delimited by any character except a newline. Thus, if the pattern contained slashes, you could choose another character, such as an exclamation mark, as the delimiter.
	# Note that the delimiter appears three times and is requir ed after the replacement. Regardless of which delimiter you use, if it does appear in the regular expression, or in the replacement text, use a backslash (\) to escape it.
	run sed 's!b c \(b\)!@\1@!' <<< $test_string		# Use ! as delimiter
	[ "$output" == "$expect" ]
}
