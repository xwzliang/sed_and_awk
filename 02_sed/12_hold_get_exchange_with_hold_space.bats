#!/usr/bin/env bats

@test "test hold get exchange" {
	# Hold: h or H: Copy or append contents of pattern space to hold space.
	# Get: g or G: Copy or append contents of hold space to pattern space.
	# Exchange: x: Swap contents of hold space and pattern space.

	# Each of these commands can take an address that specifies a single line or a range of lines. The hold (h,H) commands move data into the hold space and the get (g,G) commands move data from the hold space back into the pattern space. The difference between the lowercase and uppercase versions of the same command is that the lowercase command overwrites the contents of the target buffer, while the uppercase command appends to the buffer's existing contents.

	# The Hold command puts a newline followed by the contents of the pattern space after the contents of the hold space. (The newline is appended to the hold space even if the hold space is empty.) The Get command puts a newline followed by the contents of the hold space after the contents of the pattern space.


	# reverse the order of the lines beginning with 1 and the lines beginning with 2
	test_string=$(cat <<-EOF 
	1
	2
	11
	22
	111
	222
	EOF
	)

	run sed '
		/1/{
		h	# Put the line to the hold space
		d	# Delete the contents of pattern space, so no output yet
		}
		/2/{
		G	# Append the contents of hold space to pattern space
		}
	' <<< $test_string	
	expect=$(cat <<-EOF 
	2
	1
	22
	11
	222
	111
	EOF
	)
	[ "$output" == "$expect" ]


	# Capitalize part of the line
	test_string=$(cat <<-EOF 
	find the Match statement
	Consult the Get statement.
	using the Read statement to retrieve data
	EOF
	)

	run sed '
		/the .* statement/{
		h
		s/.*the \(.*\) statement.*/\1/
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
		G
		s/\(.*\)\n\(.*the \).*\( statement.*\)/\2\1\3/
		}
	' <<< $test_string	
	expect=$(cat <<-EOF 
	find the MATCH statement
	Consult the GET statement.
	using the READ statement to retrieve data
	EOF
	)
	[ "$output" == "$expect" ]


	# Place HTML-style paragraph tags for blocks of text
	test_string=$(cat <<-EOF 
	text text text
	text text text

	text text text
	text text text
	text text text

	text text text
	text text text
	text text text
	text text text
	EOF
	)

	run sed '
		${
			# If last line is not blank line, append to hold space and then remove everything in pattern space to make it a blank line, then the blank line will match the last section of the script
			/^$/!{
				H
				s/.*//
			}
		}
		/^$/!{
		H	# Append the line to the hold space
		d	# Delete the contents of pattern space, so no output yet
		}
		/^$/{
		x	# Swap the hold space and pattern space
		s/^\n/<p>/
		s/$/<\/p>/
		G
		}
	' <<< $test_string	
	expect=$(cat <<-EOF 
	<p>text text text
	text text text</p>

	<p>text text text
	text text text
	text text text</p>

	<p>text text text
	text text text
	text text text
	text text text</p>
	EOF
	)
	[ "$output" == "$expect" ]
}
