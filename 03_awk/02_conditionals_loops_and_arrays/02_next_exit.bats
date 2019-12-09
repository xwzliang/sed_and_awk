#!/usr/bin/env bats

@test "next exit" {
	# The next statement causes the next line of input to be read and then resumes execution at the top of the script.
	# The exit statement exits the main input loop and passes control to the END rule, if there is one. If the END rule is not defined, or the exit statement is used in the END rule, then the script terminates.

	cat <<-EOF > glossary.tmp
	GIGO	Garbage in, garbage out
	BASIC	Beginner's All-Purpose Symbolic Instruction Code
	EOF

	test_string=$(cat <<-EOF 
	GIGO
	BASIC
	q
	EOF
	)

	# A glossary lookup script
	run awk ' 
	BEGIN { 
		FS = "\t"; OFS = "\t"
		# Prompt User
		printf("Enter a glossary term: ")
	}

	FILENAME ~ /glossary.*/ {
		# load each glossary entry into an array
		entry[$1] = $2
		next	# next is used to skip other rules in the script and causes a new line of input to be read. So, until all the entries in the glossary file are read, no other rule is evaluated
	}

	# Scan for command to exit program. Must appear before next two rules because these rules will match anything, including the words “quit” and “exit.”
	$0 ~ /^(quit|[qQ]|exit|[xX])$/ { exit }

	# Process any non-empty line
	$0 != "" {
		if ($0 in entry)
			print entry[$0]
		else
			print $0 " not found"
	}

	# Prompt user again for another term
	{
		printf("Enter another glossary term (q to quit): ")
	}
	' glossary.tmp - <<< $test_string	# Use both glossary.tmp and stdin for awk (- for stdin)
	expect=$(cat <<-EOF 
	Enter a glossary term: Garbage in, garbage out
	Enter another glossary term (q to quit): Beginner's All-Purpose Symbolic Instruction Code
	Enter another glossary term (q to quit): 
	EOF
	)
	[ "$output" == "$expect" ]
}
