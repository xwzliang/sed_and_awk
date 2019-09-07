#!/usr/bin/env  bats

@test "using sed" {

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

	expect=$(cat <<- _EOF_
	John Daggett, 341 King Road, Plymouth Massachusetts
	Alice Ford, 22 East Broadway, Richmond VA
	Orville Thomas, 11345 Oak Bridge Road, Tulsa OK
	Terry Kalkas, 402 Lans Road, Beaver Falls PA
	Eric Adams, 20 Post Road, Sudbury Massachusetts
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View CA
	Sal Carpenter, 73 6th Street, Boston Massachusetts
	_EOF_
	)
	# Single quotes are always recommended to prevent the shell from interpreting special characters or spaces
	run sed 's/MA/Massachusetts/' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John Daggett, 341 King Road, Plymouth Massachusetts
	Eric Adams, 20 Post Road, Sudbury Massachusetts
	Sal Carpenter, 73 6th Street, Boston Massachusetts
	_EOF_
	)
	# The default operation of sed is to output every input line. The -n option suppresses the automatic output. When specifying this option, each instruction intended to produce output must contain a print command, p.
	run sed -n 's/MA/Massachusetts/p' sample.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	John Daggett, 341 King Road, Plymouth, Massachusetts
	Alice Ford, 22 East Broadway, Richmond VA
	Orville Thomas, 11345 Oak Bridge Road, Tulsa OK
	Terry Kalkas, 402 Lans Road, Beaver Falls, Pennsylvania
	Eric Adams, 20 Post Road, Sudbury, Massachusetts
	Hubert Sims, 328A Brook Road, Roanoke VA
	Amy Wilde, 334 Bayshore Pkwy, Mountain View, California
	Sal Carpenter, 73 6th Street, Boston, Massachusetts
	_EOF_
	)
	# Multiple instructions can be constructed by seperating instructions with semicolon or preceding each instruction with -e option
	run sed 's/ MA/, Massachusetts/; s/ PA/, Pennsylvania/; s/ CA/, California/' sample.tmp
	[ "$output" == "$expect" ]
	run sed -e 's/ MA/, Massachusetts/' -e 's/ PA/, Pennsylvania/' -e 's/ CA/, California/' sample.tmp
	[ "$output" == "$expect" ]

	cat <<- _EOF_ > sed_script.tmp
	s/ MA/, Massachusetts/
	s/ PA/, Pennsylvania/
	s/ CA/, California/
	s/ VA/, Virginia/
	s/ OK/, Oklahoma/
	_EOF_

	expect=$(cat <<- _EOF_
	John Daggett, 341 King Road, Plymouth, Massachusetts
	Alice Ford, 22 East Broadway, Richmond, Virginia
	Orville Thomas, 11345 Oak Bridge Road, Tulsa, Oklahoma
	Terry Kalkas, 402 Lans Road, Beaver Falls, Pennsylvania
	Eric Adams, 20 Post Road, Sudbury, Massachusetts
	Hubert Sims, 328A Brook Road, Roanoke, Virginia
	Amy Wilde, 334 Bayshore Pkwy, Mountain View, California
	Sal Carpenter, 73 6th Street, Boston, Massachusetts
	_EOF_
	)
	# Specify sed script to execute using -f option
	run sed -f sed_script.tmp sample.tmp
	[ "$output" == "$expect" ]
}
