#!/usr/bin/env bats

@test "split delete" {
	# The built-in function split() can parse any string into elements of an array. This function can be useful to extract “subfields” from a field. The syntax of the split() function is: 
		# n = split(string,array,separator)
	# n is the size of the array. String is the input string to be parsed into elements of the named array. The array's indices start at 1 and go to n, the number of elements in the array. The elements will be split based on the specified separator character. If a separator is not specified, then the field separator (FS) is used. The separator can be a full regular expression, not just a single character. Array splitting behaves identically to field splitting

	# Awk provides a statement for deleting an element of an array. The syntax is: 
		# delete array[subscript]
	# The brackets are required. This statement removes the element indexed by subscript from array. In particular, the in test for subscript will now return false.
	# Use "delete array" to delete all the elements of an array.

	test_string=$(cat <<-EOF 
	5/11/15
	EOF
	)

	# a scipt that converts dates in the form “mm-dd-yy” or “mm/dd/yy” to “month day, year.”
	run awk ' 
	BEGIN { 
		list_months =  "January,February,March,April,May,June,"
		list_months =  list_months "July,August,September,"
		list_months =  list_months "October,November,December"
		split(list_months, month_arr, ",")
	}

	# Check that input is not empty
	$1 != "" {
		# split on "/" the first input field into elements of array
		size_date_arr = split($1, date_arr, "/")

		# check that only one field is returned
		if (size_date_arr == 1)
			# try to split on "-"
				size_date_arr = split($1, date_arr, "-")

		# must be invalid
		if (size_date_arr == 1)
			exit

		# add 0 to number of month to cast to numeric type
		date_arr[1] += 0

		# print month day, year
		print month_arr[date_arr[1]], (date_arr[2] ", 20" date_arr[3])
	}
	' <<< $test_string

	expect=$(cat <<-EOF 
	May 11, 2015
	EOF
	)
	[ "$output" == "$expect" ]


	# expand acronyms when encountered for the first time

	cat <<-EOF > acronyms.tmp
	USGCRP	U.S. Global Change Research Program
	NASA	National Aeronautic and Space Administration
	EOF

	test_string=$(cat <<-EOF 
	text text USGCRP text
	text NASA, text text
	USGCRP text
	EOF
	)

	cat <<-'EOF' > awk_acro.tmp		# Quote EOF from bash expanding dollar sign
	awk ' 
	# load acronyms file into array
	FILENAME ~ /acronyms.*/ {
		split($0, entry_arr, "\t")
		acro_arr[entry_arr[1]] = entry_arr[2]
		next
	}

	# process input line containing at least two consecutive capital chars
	/[A-Z]{2,}/ {
		# see if any field is an acronym
		for (i = 1; i <= NF; i++)
			if ($i in acro_arr) {
				acronym_backup = $i
				# if it matches, add description
				$i = acro_arr[$i] " (" $i ")"	# (Fields can be assigned new values, just like regular variables.)
				# use delete to expand the acronym only once
				delete acro_arr[acronym_backup]
			}
	}

	# print all lines
	{
		print $0
	}
	' acronyms.tmp -
	EOF
	chmod +x awk_acro.tmp

	run ./awk_acro.tmp <<< $test_string
	expect=$(cat <<-EOF 
	text text U.S. Global Change Research Program (USGCRP) text
	text NASA, text text
	USGCRP text
	EOF
	)
	[ "$output" == "$expect" ]

	# The acronym NASA won't be expanded because it is followed by a punctutation mark
	# We can use sed to handle this. A sed script, run prior to invoking awk, could simply insert a space before any punctuation mark, causing it to be interpreted as a separate field. A string of garbage characters (@@@) was also added so we'd be able to easily identify and restore the punctuation mark.
	output=$(
		sed 's/\([^.,;:!]\)\([.,;:!]\)/\1 @@@\2/g' <<<$test_string |
		./awk_acro.tmp |
		sed 's/ @@@\([.,;:!]\)/\1/g'
	)

	expect=$(cat <<-EOF 
	text text U.S. Global Change Research Program (USGCRP) text
	text National Aeronautic and Space Administration (NASA), text text
	USGCRP text
	EOF
	)

	[ "$output" == "$expect" ]


	# If the value of separator is empty string, each character in the original string will become a separate element of the target array.
	run awk '
	{
		arr_size = split($0, char_arr, "")
		for (i = 1; i <= arr_size; ++i)
			print char_arr[i]
		# split array is not an associative array, cannot use following loop
		# for (index in char_arr)
		# 	print index
	}
	' <<< "hello"
	expect=$(cat <<-EOF 
	h
	e
	l
	l
	o
	EOF
	)

	[ "$output" == "$expect" ]
}
