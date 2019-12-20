#!/usr/bin/env bats

@test "close" {
	# The close() function allows you to close open files and pipes. There are a number of reasons you should use it.
	# You can only have so many pipes open at a time. In order to open as many pipes in a program as you wish, you must use the close() function to close a pipe when you are done with it (ordinarily, when getline retur ns 0 or -1). It takes a single argument, the same expression used to create the pipe. Here's an example:
	# 	close("who")
	# Closing a pipe allows you to run the same command twice. For example, you can use date twice to time a command.
	# Using close() may be necessary in order to get an output pipe to finish its work. 
	# Closing open files is necessary to keep you from exceeding your system's limit on simultaneously open files.
	
	test_string=$(cat <<-EOF 
	This is a line
	Another line
	Another line
	EOF
	)

	run awk '
	{ 
		print | "wc -w"		# get word count
		close("wc -w")
	}
	' <<< "$test_string"

	expect=$(cat <<-'EOF' 
	4
	2
	2
	EOF
	)
	[ "$output" == "$expect" ]

}
