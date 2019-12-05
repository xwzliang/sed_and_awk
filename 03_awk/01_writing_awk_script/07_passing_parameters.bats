#!/usr/bin/env bats

@test "passing parameters" {
	rm -f *.tmp
	for file in file{1..2}.tmp; do
		echo "hello world" > $file
	done

	# The variable can be set on the command line, after the script and before the filename.
		# awk 'script' var=value inputfile
	# Each parameter must be interpreted as a single argument. Therefore, spaces are not permitted on either side of the equal sign. Multiple parameters can be passed this way.

	# An important restriction on command-line parameters is that they are not available in the BEGIN procedure. That is, they are not available until after the first line of input is read. Why? Well, here's the confusing part. A parameter passed from the command line is treated as though it were a filename. The assignment does not occur until the parameter, if it were a filename, is actually evaluated.
	run awk ' 
	BEGIN { print n }
	{
		if (n == 1) print "Reading the first file"
		if (n == 2) print "Reading the second file"
	}
	' n=1 file1.tmp n=2 file2.tmp
	expect=$(cat <<-EOF 

	Reading the first file
	Reading the second file
	EOF
	)
	[ "$output" == "$expect" ]

	# POSIX awk provides a solution to the problem of defining parameters before any input is read. The -v option* specifies variable assignments that you want to take place before executing the BEGIN procedure (i.e., before the first line of input is read.) The -v option must be specified before a command-line script. For instance, the following command uses the -v option to set the record separator for multiline records.
		# awk -F"\n" -v RS="" '{ print }' phones.block
	# A separate -v option is requir ed for each variable assignment that is passed to the program.
	run awk -v n=1 -v m=2 ' 
	BEGIN { print n }
	{
		if (n == 1) print "Reading the first file"
		if (m == 2) print "Multiple parameters work"
	}
	' file1.tmp
	expect=$(cat <<-EOF 
	1
	Reading the first file
	Multiple parameters work
	EOF
	)
	[ "$output" == "$expect" ]
}
