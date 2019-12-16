#!/usr/bin/env bats

@test "environ" {
	# ENVIRON: An array of environment variables. Each element of the array is the value in the current environment and the index is the name of the environment variable.

	test_string=$(cat <<-EOF 
	AWKLIBPATH
	AWKPATH
	BATS_PREFIX
	LANG
	EOF
	)

	run awk '
	{
		if ($1 in ENVIRON)
			print $1 "=" ENVIRON[$1]
	}
	' <<< $test_string

	expect=$(cat <<-EOF 
	AWKLIBPATH=/usr/lib/x86_64-linux-gnu/gawk
	AWKPATH=.:/usr/share/awk
	BATS_PREFIX=/usr/lib
	LANG=en_US.UTF-8
	EOF
	)
	# Gawk allows you to specify an environment variable named AWKPATH that defines a search path for awk program files. Thus, when a filename is specified with the -f option, the two default directories will be searched, beginning with the current directory, then AWKPATH.

	[ "$output" == "$expect" ]
}
