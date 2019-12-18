#!/usr/bin/env bats

@test "systime strftime" {
	# systime(): Returns the current time of day in seconds since the Epoch (00:00 a.m., January 1, 1970 UTC). For example: 831322007
	
	# strftime(format, timestamp): Formats timestamp (of the same form returned by systime()) according to format. If no timestamp, use current time. If no format either, use a default format whose output is similar to the date command.

	run awk 'BEGIN { print systime() }'
	[[ "$output" =~ ^[0-9]+$ ]]
	

	run awk 'BEGIN { print strftime("Today is %A, %B %d, %Y") }'
	patter="^.*, [0-9]{2}, [0-9]{4}$"
	[[ "$output" =~ $pattern ]]
	# Today is Sunday, May 05, 1996
	# Today is 星期三, 十二月 18, 2019
}
