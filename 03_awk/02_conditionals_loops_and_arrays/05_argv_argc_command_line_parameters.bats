#!/usr/bin/env bats

@test "argv argc" {
	# ARGV: An array of command-line arguments, excluding the script itself and any options specified with the invocation of awk. The number of elements in this array is available in ARGC. The index of the first element of the array is 0 (unlike all other arrays in awk but consistent with C) and the last is ARGC-1.

	run awk -v a=3 '
	BEGIN {
		for (x = 0; x < ARGC; x++)
			print ARGV[x]
		print ARGC
	}
	' 1234 "John Wayne" Westerns n=44 -

	expect=$(cat <<-EOF 
	awk
	1234
	John Wayne
	Westerns
	n=44
	-
	6
	EOF
	)
	# The first element is the name of the command that invoked the script.
	# Note the "-v a=3" does not appear in the parameter list.
	[ "$output" == "$expect" ]



	cat <<-EOF >phone_data.tmp
	John Robinson, 696-0987
	Phyllis Chapman, 879-0900
	EOF

	# Here is a sample awk script that return phone numbers from database
	cat <<-'EOF' >get_phone.tmp
	awk ' 
	# Supply name of person on command line or at prompt
	BEGIN { 
		FS = ", "
		if (ARGC > 2) {
			name_of_person = ARGV[1]
			delete ARGV[1]
			# that parameter is deleted from the array. This is very important if the parameter that is supplied on the command line is not of the form “var=value”; otherwise, it will later be interpreted as a filename.
		} else {
			while (! name_of_person) {
				printf("Enter a name? ")
				getline name_of_person < "-"
				printf("\n")
			}
		}
	}

	$1 ~ name_of_person {
		print $1, $NF
	}
	' $@ phone_data.tmp
	EOF
	chmod +x get_phone.tmp

	run ./get_phone.tmp John
	expect=$(cat <<-EOF 
	John Robinson 696-0987
	EOF
	)
	[ "$output" == "$expect" ]

	run ./get_phone.tmp <<< "Phyllis"
	expect=$(cat <<-EOF 
	Enter a name? 
	Phyllis Chapman 879-0900
	EOF
	)
	[ "$output" == "$expect" ]

	cat <<-EOF >new_phone_data.tmp
	John Robinson, 696-0987
	Alice Watson, (617) 555-0000
	Alice Gold, (707) 724-0000
	EOF
	# Supply both name and database file in command line
	run ./get_phone.tmp Alice new_phone_data.tmp
	expect=$(cat <<-EOF 
	Alice Watson (617) 555-0000
	Alice Gold (707) 724-0000
	EOF
	)
	[ "$output" == "$expect" ]

	# Because you can add to and delete from the ARGV array, there is the potential for doing a lot of interesting manipulation. You can place a filename at the end of the ARGV array, for instance, and it will be opened as though it were specified on the command line. Similarly, you can delete a filename from the array and it will never be opened. Note that if you add new elements to ARGV, you should also increment ARGC; awk uses the value of ARGC to know how many elements in ARGV it should process. Thus, simply decrementing ARGC will keep awk from examining the final element in ARGV.
	# As a special case, if the value of an ARGV element is the empty string (""), awk will skip over it and continue on to the next element.


	# ARGIND is set automatically by gawk to be the index in ARGV of the current input file name. This variable gives you a way to track how far along you are in the list of filenames.
	echo John > 1.tmp
	echo Phyllis > 2.tmp
	run awk ' { print "ARGIND: " ARGIND " FILENAME: " FILENAME } ' {1,2}.tmp
	expect=$(cat <<-EOF 
	ARGIND: 1 FILENAME: 1.tmp
	ARGIND: 2 FILENAME: 2.tmp
	EOF
	)
	[ "$output" == "$expect" ]

}
