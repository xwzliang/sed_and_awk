#!/usr/bin/env bats

@test "system variables" {
	test_string=$(cat <<-EOF 
	John Robinson, 696-0987
	Phyllis Chapman, 879-0900
	EOF
	)

	# FS -- field separator
	# OFS -- output field separator
	run awk ' 
	BEGIN { FS = ", *"; OFS = "\t" }
	{ print $1, $2 }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John Robinson	696-0987
	Phyllis Chapman	879-0900
	EOF
	)
	[ "$output" == "$expect" ]


	# NF -- number of fields
	run awk ' 
	{ print "This line has " NF " fields. The last one is " $NF }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	This line has 3 fields. The last one is 696-0987
	This line has 3 fields. The last one is 879-0900
	EOF
	)
	[ "$output" == "$expect" ]


	# NR -- number of records
	run awk ' 
	{ print NR ".", $1 }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	1. John
	2. Phyllis
	EOF
	)
	[ "$output" == "$expect" ]


	test_string=$(cat <<-EOF 
	John Robinson, 696-0987
	Boston

	Phyllis Chapman, 879-0900
	New York
	EOF
	)

	# RS -- record separator
	# ORS -- output record separator
	run awk ' 
	# FS is comma (with or without spaces) or newline
	# RS is empty string "", this will set RS to blank line
	# ORS needs to be two newlines in order to preserve the blank line between records
	BEGIN	{ 
		FS = ", *|\n"; OFS = "\n"
		RS = ""; ORS = "\n\n"
	}
	{ print $1, $2, $NF }
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John Robinson
	696-0987
	Boston

	Phyllis Chapman
	879-0900
	New York
	EOF
	)
	[ "$output" == "$expect" ]


	# FILENAME -- the file name of the current input file
	touch test.tmp
	run awk ' END	{ print FILENAME } ' test.tmp
	expect=$(cat <<-EOF 
	test.tmp
	EOF
	)
	[ "$output" == "$expect" ]


	# FNR -- the number of the current record relative to the current input file 
	echo John > 1.tmp
	echo Phyllis > 2.tmp
	run awk ' { print "line number " FNR " of " FILENAME ":", $1 } ' {1,2}.tmp
	expect=$(cat <<-EOF 
	line number 1 of 1.tmp: John
	line number 1 of 2.tmp: Phyllis
	EOF
	)
	[ "$output" == "$expect" ]

	# NR will count all records in all input files instead of current file
	run awk ' { print "line number " NR " of all files:", $1 } ' {1,2}.tmp
	expect=$(cat <<-EOF 
	line number 1 of all files: John
	line number 2 of all files: Phyllis
	EOF
	)
	[ "$output" == "$expect" ]

}
