#!/usr/bin/env bats

@test "relational boolean operators and formatted printing" {
	# relational boolean operators and formatted printing in awk is very similar to C

	rm -f *.tmp
	for file in file{1..3}.tmp; do
		echo "hello world" > $file
	done

	# list files and total size in bytes
	output=$(ls -l *.tmp | awk ' 
	# output column headers
	BEGIN { printf("%-15s\t%10s\n", "FILES", "BYTES") }

	# test for 9 fields and files begin with "-" (indicating files not folders)
	NF == 9 && /^-/ {
		sum += $5	# accumulate size of file
		++num_files	# count number of files
		printf("%-15s\t%10d\n", $9, $5)	# print filename and size (filename left-justified in a field 15 characters wide and size right-justified in a field 10 characters wide)
	}

	END {
		# print total file size and number of files
		printf("Total: %d bytes (%d files)\n", sum, num_files)
	}
	')
	# unlike print, printf does not automatically supply a newline. You must specify it explicitly as “\n”.
	expect=$(cat <<-EOF 
	FILES          	     BYTES
	file1.tmp      	        12
	file2.tmp      	        12
	file3.tmp      	        12
	Total: 36 bytes (3 files)
	EOF
	)
	[ "$output" == "$expect" ]
}
