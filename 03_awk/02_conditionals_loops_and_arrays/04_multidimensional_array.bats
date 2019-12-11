#!/usr/bin/env bats

@test "multidimensional array" {
	# Awk does not support multidimensional arrays but instead offers a syntax for subscripts that simulate a reference to a multidimensional array.
	# For example, array[2, 4] would produce the value of the fourth field of the second record.
	# This syntax does not create a multidimensional array. It is converted into a string that uniquely identifies the element in a linear array. The components of a multidi-mensional subscript are interpreted as individual strings (“2” and “4,” for instance) and concatenated together separated by the value of the system variable SUBSEP. The subscript-component separator is defined as "\034" by default, an unprintable character rarely found in ASCII text. Thus, awk maintains a one-dimensional array and the subscript for our previous example would actually be "2\0344" (the con-catenation of “2,” the value of SUBSEP, and “4”).

	test_string=$(cat <<-EOF 
	1,1
	2,2
	3,3
	4,4
	5,5
	6,6
	7,7
	8,8
	9,9
	10,10
	11,11
	12,12
	1,12
	2,11
	3,10
	4,9
	5,8
	6,7
	7,6
	8,5
	9,4
	10,3
	11,2
	12,1
	EOF
	)

	# Here is a sample awk script that shows how to load and output the elements of a multidimensional array. This array represents a two-dimensional bitmap that is 12 characters in width and height.
	run awk ' 
	BEGIN { 
		FS = ","
		BITMAP_WIDTH = 12
		BITMAP_HEIGHT = 12
		# loop to load entire array with "O"
		for (i = 1; i <= BITMAP_WIDTH; i++)
			for (j = 1; j <= BITMAP_HEIGHT; j++)
				bitmap[i, j] = "O"
	}

	# Read input of coordinates and assign "X" to that position
	{
		bitmap[$1, $2] = "X"
	}

	END {
		# Output the multidimensional array
		for (i = 1; i <= BITMAP_WIDTH; i++) {
			for (j = 1; j <= BITMAP_HEIGHT; j++)
				printf("%s", bitmap[i, j])
			printf("\n")
		}
	}
	' <<< $test_string

	expect=$(cat <<-EOF 
	XOOOOOOOOOOX
	OXOOOOOOOOXO
	OOXOOOOOOXOO
	OOOXOOOOXOOO
	OOOOXOOXOOOO
	OOOOOXXOOOOO
	OOOOOXXOOOOO
	OOOOXOOXOOOO
	OOOXOOOOXOOO
	OOXOOOOOOXOO
	OXOOOOOOOOXO
	XOOOOOOOOOOX
	EOF
	)
	[ "$output" == "$expect" ]


	# The multidimensional array syntax is also supported in testing for array membership. The subscripts must be placed inside parentheses. 
	# 	if ((i, j) in array) 
	# This tests whether the subscript i,j (actually, i SUBSEP j) exists in the specified array.

	# Looping over a multidimensional array is the same as with one-dimensional arrays.
	# 	for (item in array)
	# You must use the split( ) function to access individual subscript components. Thus:
	# 	split(item, subscr, SUBSEP)
	# creates the array subscr from the subscript item.
}
