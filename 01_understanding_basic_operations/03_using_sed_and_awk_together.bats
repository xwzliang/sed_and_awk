#!/usr/bin/env  bats

@test "using sed and awk together" {

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
	
	cat <<- _EOF_ > nameState.tmp
	s/ CA/, California/
	s/ MA/, Massachusetts/
	s/ OK/, Oklahoma/
	s/ PA/, Pennsylvania/
	s/ VA/, Virginia/
	_EOF_

	expect=$(cat <<- _EOF_
	 Massachusetts
	 Virginia
	 Oklahoma
	 Pennsylvania
	 Massachusetts
	 Virginia
	 California
	 Massachusetts
	_EOF_
	)	# Notice the space at the beginning of each line!!!
	output=$( sed -f nameState.tmp sample.tmp | awk -F, '{ print $4 }' )
	# In bats, run command is just like any other Unix command, when used in pipe, that run (which has no output) is in fact being piped to other command, so this won't work. The solution is to encapsulate the entire command being tested as a bash -c inline string:
	# And because there's another string encapsulation in bash, so we need to escape dollar sign $ or escape single quotes (by \' and a $ in front of whole string, without $ the escape won't work)
	run bash -c "sed -f nameState.tmp sample.tmp | awk -F , '{ print \$4 }'"
	run bash -c $'sed -f nameState.tmp sample.tmp | awk -F , \'{ print $4 }\''
	# Above three commands solution all work fine

	# Run following command to see difference between two string
	# diff <(echo -e "$output") <(echo -e "$expect") >diff.tmp
	[ "$output" == "$expect" ]

	expect=$(cat <<- _EOF_
	 Massachusetts, John Daggett, 341 King Road, Plymouth, Massachusetts
	 Virginia, Alice Ford, 22 East Broadway, Richmond, Virginia
	 Oklahoma, Orville Thomas, 11345 Oak Bridge Road, Tulsa, Oklahoma
	 Pennsylvania, Terry Kalkas, 402 Lans Road, Beaver Falls, Pennsylvania
	 Massachusetts, Eric Adams, 20 Post Road, Sudbury, Massachusetts
	 Virginia, Hubert Sims, 328A Brook Road, Roanoke, Virginia
	 California, Amy Wilde, 334 Bayshore Pkwy, Mountain View, California
	 Massachusetts, Sal Carpenter, 73 6th Street, Boston, Massachusetts
	_EOF_
	)	# Notice the space at the beginning of each line!!!
	# Put the 4th column in front of the orignal line
	output=$( sed -f nameState.tmp sample.tmp | awk -F, '{ print $4 ", " $0 }' )
	[ "$output" == "$expect" ]

	# Dollar sign need to be escaped in here document
	# Note that we don't have to assign to a variable before using it (because awk variables are initialized to the empty string).
	cat <<- _EOF_ > byState.tmp
	#!/usr/bin/env bash
	awk -F , '{
		print \$4 ", " \$0
	}' \$* |
	sort |
	awk -F, '
	\$1 == LastState {
		print "\t" \$2
	}
	\$1 != LastState {
		LastState = \$1
		print \$1
		print "\t" \$2
	}
	'
	_EOF_
	chmod +x byState.tmp

	# expect=$(cat << _EOF_ > output.tmp
	expect=$(cat << _EOF_
 California
	 Amy Wilde
 Massachusetts
	 Eric Adams
	 John Daggett
	 Sal Carpenter
 Oklahoma
	 Orville Thomas
 Pennsylvania
	 Terry Kalkas
 Virginia
	 Alice Ford
	 Hubert Sims
_EOF_
	)	# Notice the space at the beginning of each line!!! And we need to put tab in the string, so <<- cannot be used to ignore tab
	# output=$( sed -f nameState.tmp sample.tmp | $PWD/byState.tmp )
	run bash -c " sed -f nameState.tmp sample.tmp | $PWD/byState.tmp "
	[ "$output" == "$expect" ]
}
