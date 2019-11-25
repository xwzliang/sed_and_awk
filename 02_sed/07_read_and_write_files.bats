#!/usr/bin/env bats

@test "test read and write files" {
	test_string=$(cat <<-EOF 
	a b c b
	b c d c
	EOF
	)

	echo -e "This is new text.\nMultiline text." > for_read.tmp

	# Read r: read the content of the file after the addressed line
	run sed '/b c b/r for_read.tmp' <<< $test_string		# Read for_read.tmp after the line containing 'b c b'
	expect=$(cat <<-EOF 
	a b c b
	This is new text.
	Multiline text.
	b c d c
	EOF
	)
	[ "$output" == "$expect" ]

	# Suppressing the automatic output, using the -n option or #n script syntax, prevents the original line in the pattern space from being output, but the result of a read command still goes to standard output.
	run sed -n '/b c b/r for_read.tmp' <<< $test_string	
	expect=$(cat <<-EOF 
	This is new text.
	Multiline text.
	EOF
	)
	[ "$output" == "$expect" ]


	# Write w: writes the contents of the pattern space to the file.
	sed '
		/b c b/w for_write_1.tmp
		/b c d/{
				s///	# delete the pattern "b c d" from the line and then write to file
				w for_write_2.tmp
		}
	' <<< $test_string		# write to different files
	run cat for_write_1.tmp
	[ "$output" == "a b c b" ]
	run cat for_write_2.tmp
	[ "$output" == " c" ]
}
