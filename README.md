MyRex is a record monitor and notifier for MySQL databases that run under Linux operating systems

# Description

Please see myrex.sh and the accompanied example for a detailed description.


# Resources

  - [Shell programming](http://www.shelldorado.com/)


# Ideas for improvement

  - Add the possibility for more variables inside the message files (i.e. %MYREX_SUBJECT%, %MYREX_TO%, %MYREX_CC%, asf.)
  - Different return values on error, see [Advanced Bash Scripting Guide](http://tldp.org/LDP/abs/html/exitcodes.html)


# MyRex Pseudocode

The inner workings of MyRex can be expressed with this pseudocode:

	Query the database
	If the query returned a result
		Save result of query in file myrex.monitor-ID.new
		If the file myrex.monitor-ID.old does exist
			Compare the new and the old file using cmp
			If files differ
				Compile message
				Send message
			Delete old-file
		Rename new-file to old-file


# License

MyRex is free to use for everyone without any restrictions.
