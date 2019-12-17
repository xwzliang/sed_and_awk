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

	# If the value of FS is the empty string, then each character of the input record becomes a separate field.
	run awk '
	BEGIN { FS = "" }
	{
		for (i = 1; i <= NF; ++i)
			print $i
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

	# gawk has a special variable FIELDWIDTHS can be used to split out data that occurs in fixed-width columns. Such data may or may not have whitespace separating the values of the fields.
	run awk '
	BEGIN { FIELDWIDTHS = "3" }
	{
		for (i = 1; i <= NF; ++i)
			print $i
	}
	' <<< "hello world"
	expect=$(cat <<-EOF 
	hel
	EOF
	)
	[ "$output" == "$expect" ]

	run awk '
	BEGIN { FIELDWIDTHS = "3 4 5" }
	{
		for (i = 1; i <= NF; ++i)
			print $i
	}
	' <<< "hello world"
	expect=$(cat <<-EOF 
	hel
	lo w
	orld
	EOF
	)
	[ "$output" == "$expect" ]
	# Assigning a value to FIELDWIDTHS causes gawk to start using it for field splitting. Assigning a value to FS causes gawk to return to the regular field splitting mechanism. Use FS = FS to make this happen without having to save the value of FS in an extra variable.


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

	test_string=$(cat <<-EOF 
	John Robinson, 696-0987
	Phyllis Chapman, 879-0900
	EOF
	)
	# gawk sets the variable RT (record terminator) to the actual input text that matched the value of RS.
	run awk '
	BEGIN { 
		RS = "Robinson|Chapman" 
	}
	{
		print "$0 is " $0
		print "RT is " RT
	}
	' <<< "$test_string"
	expect=$(cat <<-'EOF' 
	$0 is John 
	RT is Robinson
	$0 is , 696-0987
	Phyllis 
	RT is Chapman
	$0 is , 879-0900

	RT is 
	EOF
	)
	# at end of file, RT will be empty
	[ "$output" == "$expect" ]

	# One of the most common uses of sed is its substitute command (s/old/new/g). By setting RS to the pattern to match, and ORS to the replacement text, a simple print statement can print the unchanged text followed by the replacement text.
	run awk '
	BEGIN { 
		RS = "Robinson|Chapman" 
		ORS = "Replacement"
	}
	{
		print 
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John Replacement, 696-0987
	Phyllis Replacement, 879-0900
	Replacement
	EOF
	)
	# OFS will cause not corrent result at the end of file
	[ "$output" == "$expect" ]

	run awk '
	BEGIN { 
		RS = "Robinson|Chapman" 
		ORS = "Replacement"
	}
	{
		if (RT == "")
			printf "%s", $0
		else
			print
	}
	' <<< "$test_string"
	expect=$(cat <<-EOF 
	John Replacement, 696-0987
	Phyllis Replacement, 879-0900
	EOF
	)
	# Use printf when RT is empty (at the end of file) to print $0, this will give us correct result as sed 's///g'
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
