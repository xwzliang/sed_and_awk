#!/usr/bin/env  bats

@test "using awk" {
	cat <<- _EOF_ > sample.tmp
	John Daggett, 341 King Road, Plymouth MA
	Alice Ford, 22 East Broadway, Richmond VA
	Orville Thomas, 11345 Oak Bridge Road, Tulsa OK
	Terry Kalkas, 402 Lans Road, Beaver Falls PA
	Eric Adams, 20 Post Road, Sudbury MA
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	Sal Carpenter, 73 6th Street, Boston MA
	_EOF_

	# awk command is similiar to sed, use: awk 'instructions' files; awk -f script files
	# Awk, in the usual case, interprets each input line as a record and each word on that line, delimited by spaces or tabs, as a field. (These defaults can be changed.) One or more consecutive spaces or tabs count as a single delimiter. Awk allows you to reference these fields, in either patterns or procedures. $0 represents the entire input line. $1, $2, . . . refer to the individual fields on the input line. Awk splits the input record before the script is applied.
	expect=$(cat <<- _EOF_
	John
	Alice
	Orville
	Terry
	Eric
	Hubert
	Amy
	Sal
	_EOF_
	)
	run awk '{ print $1 }' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John Daggett, 341 King Road, Plymouth MA
	Eric Adams, 20 Post Road, Sudbury MA
	Sal Carpenter, 73 6th Street, Boston MA
	_EOF_
	)
	# The default action of awk is to print each line that matches the pattern, this is different to sed, which will print all lines by default
	run awk '/MA/' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John
	Eric
	Sal
	_EOF_
	)
	# Print the first word of each line containing the string “MA”.
	run awk '/MA/ {print $1}' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John Daggett
	Eric Adams
	Sal Carpenter
	_EOF_
	)
	# Use the -F option to change the field separator to a comma.
	run awk -F , '/MA/ {print $1}' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John Daggett
	 341 King Road
	 Plymouth MA
	Alice Ford
	 22 East Broadway
	 Richmond VA
	Orville Thomas
	 11345 Oak Bridge Road
	 Tulsa OK
	Terry Kalkas
	 402 Lans Road
	 Beaver Falls PA
	Eric Adams
	 20 Post Road
	 Sudbury MA
	Hubert Sims
	 328A Brook Road
	 Roanoke VA
	Amy Wilde
	 334 Bayshore Pkwy
	 Mountain View CA
	Sal Carpenter
	 73 6th Street
	 Boston MA
	_EOF_
	)
	# Note how the leading blank is now considered part of the second and third fields.
	run awk -F , '{ print $1; print $2; print $3 }' sample.tmp
	[ "$output" == "$expect" ]
}
