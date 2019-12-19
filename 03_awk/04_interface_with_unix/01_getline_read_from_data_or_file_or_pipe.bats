#!/usr/bin/env bats

@test "getline" {
	# The getline function is used to read another line of input. Not only can getline read from the regular input data stream, it can also handle input from files and pipes.
	# The getline function is similar to awk's next statement. While both cause the next input line to be read, the next statement passes control back to the top of the script. The getline function gets the next line without changing control in the script. Possible return values are:
	# 	1 If it was able to read a line.
	# 	0 If it encounters the end-of-file.
	# 	-1 If it encounters an error.

	# Although getline is called a function and it does return a value, its syntax resembles a statement. Do not write getline(); its syntax does not permit parentheses.

	test_string=$(cat <<-EOF 
	Pattern
	This line is needed
	Another line
	Another line
	EOF
	)

	run awk '
	/Pattern/ { 
		getline
		print $0
		print "The line number is " NR
	}
	' <<< $test_string
	# When the new line is read, getline assigns it $0 and parses it into fields. The system variables NF, NR, and FNR are also set. Thus, the new line becomes the current line, and we are able to refer to “$1” and retrieve the first field. Note that the previous line is no longer available as $0. However, if necessary, you can assign the line read by getline to a variable and avoid changing $0

	expect=$(cat <<-'EOF' 
	This line is needed
	The line number is 2
	EOF
	)
	[ "$output" == "$expect" ]

	run awk '
	/Pattern/ { 
		while (getline > 0)
			print $0
	}
	' <<< $test_string
	# The expression “getline > 0” will be true as long as getline successfully reads an input line. When it gets to the end-of-file, getline returns 0 and the loop is exited.

	expect=$(cat <<-'EOF' 
	This line is needed
	Another line
	Another line
	EOF
	)
	[ "$output" == "$expect" ]


	# Besides reading from the regular input stream, the getline function allows you to read input from a file or a pipe. For instance, the following statement reads the next line from the file datafile:
	# 	getline < "datafile"
	echo "$test_string" > testfile.tmp
	run awk '
	{ 
		while ((getline < "testfile.tmp") > 0) {
			print $1
			print NR
		}
	}
	' <<< "hello, world"
	# We parenthesize to avoid confusion; the “<” is a redirection, while the “>” is a comparison of the return value. "> 0" actually can be emitted.

	expect=$(cat <<-'EOF' 
	Pattern
	1
	This
	1
	Another
	1
	Another
	1
	EOF
	)
	# $1 is set, but NR is not set
	[ "$output" == "$expect" ]


	# getline can also read from stdin
	run awk '
	BEGIN { 
		getline < "-"
		print
	}
	' testfile.tmp <<< "hello, world"
	# We parenthesize to avoid confusion; the “<” is a redirection, while the “>” is a comparison of the return value.

	expect=$(cat <<-'EOF' 
	hello, world
	EOF
	)
	[ "$output" == "$expect" ]


	# You can execute a command and pipe the output into getline. For example, look at the following expression:
	# 	"who am i" | getline
	# That expression sets “$0” to the output of the who am i command.
	run awk '
	BEGIN { 
		"bash -c \"echo {a..e}\" | tr -d \" \"" | getline
		print
	}
	'
	# Because a plain double quote ends the string, you must use ‘\"’ to represent an actual double-quote character as a part of the string.

	expect=$(cat <<-'EOF' 
	abcde
	EOF
	)
	[ "$output" == "$expect" ]

	# When the output of a command is piped to getline and it contains multiple lines, getline reads a line at a time. The first time getline is called it reads the first line of output. If you call it again, it reads the second line. To read all the lines of output, you must set up a loop that executes getline until there is no more output.
	run awk '
	BEGIN { 
		while ("cat testfile.tmp" | getline)
			print
	}
	'
	expect=$(cat <<-'EOF' 
	Pattern
	This line is needed
	Another line
	Another line
	EOF
	)
	# Each time the getline function is called, it reads the next line of output. The command, however, is executed only once.
	[ "$output" == "$expect" ]


	# Assigning the Input to a Variable
	# The getline function allows you to assign the input record to a variable. The name of the variable is supplied as an argument. Thus, the following statement reads the next line of input into the variable input_var:
	# 	getline input_var
	# Assigning the input to a variable does not affect the current input line; that is, $0 is not affected. The new input line is not split into fields, and thus the variable NF is also unaffected. It does increment the record counters, NR and FNR.
	run awk '
	/Pattern/ { 
		getline out_str < "-"
		print out_str
		print $0
	}
	' testfile.tmp <<< "hello, world"
	expect=$(cat <<-'EOF' 
	hello, world
	Pattern
	EOF
	)
	[ "$output" == "$expect" ]

	run awk '
	BEGIN { 
		"bash -c \"echo {a..e}\" | tr -d \" \"" | getline a_to_e
		print a_to_e
	}
	'
	expect=$(cat <<-'EOF' 
	abcde
	EOF
	)
	[ "$output" == "$expect" ]

}
