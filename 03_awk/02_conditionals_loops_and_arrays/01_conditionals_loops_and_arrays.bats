#!/usr/bin/env bats

@test "conditionals, loops and arrays" {
	# Conditionals and loops are similar to C (break and continue are also available)
	# Arrays are silimar to Python. In awk, all arrays are associative arrays. What makes an associative array unique is that its index can be a string or a number.

	test_string=$(cat <<-EOF 
	mona 70 77 85 83 70 89
	john 85 92 78 94 88 91
	andrea 89 90 85 94 90 95
	jasper 84 88 80 92 84 82
	dunce 64 80 60 60 61 62
	ellis 90 98 89 96 96 92
	EOF
	)

	# Report student grades
	run awk ' 
	BEGIN { OFS = "\t" }
	{
		total = 0
		for (i = 2; i <= NF; ++i)
			total += $i
		avg = total / (NF - 1)
		student_avg[NR] = avg

		if (avg >= 90)	grade = "A"
		else if (avg >= 80)	grade = "B"
		else if (avg >= 70)	grade = "C"
		else if (avg >= 60)	grade = "D"
		else grade = "F"

		++class_grade[grade]	# increment counter for letter grade array
		print $1, avg, grade
	}
	END {
		for (x = 1; x <= NR; x++)
			if (x in student_avg)	# Use in to test for key value membership in an array (This line is not necessary)
				class_avg_total += student_avg[x]
		class_average = class_avg_total / NR

		# Determine how many above/below average
		for (x = 1; x <= NR; x++)
			if (student_avg[x] >= class_average)
				++above_average
			else
				++below_average

		print ""
		print "Class Average:", class_average
		print "At or Above Average:", above_average
		print "Below Average:", below_average
		# print number of student per letter grade
		for (letter_grade in class_grade)	# Get the key of list
			# The output is piped to sort, to make sure the grades come out in the proper order.
			print letter_grade ":", class_grade[letter_grade] | "sort"
	}
	' <<< $test_string
	expect=$(cat <<-EOF 
	mona	79	C
	john	88	B
	andrea	90.5	A
	jasper	85	B
	dunce	64.5	D
	ellis	93.5	A

	Class Average:	83.4167
	At or Above Average:	4
	Below Average:	2
	A:	2
	B:	2
	C:	1
	D:	1
	EOF
	)
	echo "$output"
	[ "$output" == "$expect" ]
}
