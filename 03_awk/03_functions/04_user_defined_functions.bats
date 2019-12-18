#!/usr/bin/env bats

@test "user-defined functions" {
	# A function definition can be placed anywhere in a script that a pattern-action rule can appear. Typically, we put the function definitions at the top of the script before the pattern-action rules. A function is defined using the following syntax:
	# function name (parameter-list) {
	# 	statements
	# }

	# All the variables in the function definition's parameter list are local variables. However, the variables defined in the body of the function are global variables. Awk provides what its developers call an “inelegant” means of declaring variables local to a function, and that is by specifying those variables in the parameter list. The local temporary variables are put at the end of the parameter list. By convention, the local variables are separated from the “real” parameters by several spaces.

	test_string=$(cat <<-EOF 
	Hello
	EOF
	)

	# Convert uppercase to lowercase 
	awk_insert_function='
	function insert(target_string, position, insert_string,		str_before_position) {
		str_before_position = substr(target_string, 1, position)
		str_after_position = substr(target_string, position+1)
		return str_before_position insert_string str_after_position
	}'
	awk_script='
	{
		print "Function returns", insert($1, 4, "XX")
		print "The value of $1 after insertion is:", $1
		print "The value of target_string after insertion is:", target_string
		print "The value of str_before_position after insertion is:", str_before_position
		print "The value of str_after_position after insertion is:", str_after_position
	}
	'
	run awk "$awk_insert_function$awk_script" <<< $test_string

	expect=$(cat <<-'EOF' 
	Function returns HellXXo
	The value of $1 after insertion is: Hello
	The value of target_string after insertion is: 
	The value of str_before_position after insertion is: 
	The value of str_after_position after insertion is: o
	EOF
	)
	
	[ "$output" == "$expect" ]


	# You can define awk function in file and import it as library, but all other scripts are needed to be in file as well, and -f must be used for each script. (gawk can use --source, as discussed later)
	echo "$awk_insert_function" >awk_insert_function.tmp
	echo "$awk_script" >awk_script.tmp
	run awk -f awk_script.tmp -f awk_insert_function.tmp <<< $test_string
	[ "$output" == "$expect" ]

	# gawk can use --source for script in command line, and -f for library files
	run gawk --source "$awk_script" -f awk_insert_function.tmp <<< $test_string
	[ "$output" == "$expect" ]
	run gawk -f awk_insert_function.tmp --source "$awk_script" <<< $test_string
	[ "$output" == "$expect" ]
}
