#! /bin/bash

# MySQL Record Monitor
#
# Author: Manuel Hiptmair
# Created in: April - May 2012

PROGRAM_VERSION="0.91"
PROGRAM_DESCRIPTION="
NAME

	MyRex - MySQL Record Monitor

USAGE

	myrex [options] -a email-address -D database -u user
		-p password monitor-id

DESCRIPTION

	MyRex sends queries to a MySQL database and compares the result
	with the result of a previous run. If the results differ, MyRex
	will send an e-mail notification to a user-defined email
	address.

	MyRex is optimally executed periodically through a cronjob.

OPTIONS

	-f sql-file

		Executes the passed sql-file.
		Default: ./{monitor-id}.sql

 	-s email-subject

		Subject of the e-mail notification.
		Default: {monitor-id}

	-a email-address

		Receiver of e-mail notification.

	-c email-address

		Send carbon copies of e-mail notification to list
		of users.
		Default: empty

	-e message-file

		The e-mail notification can get customized by
		passing a message-file. This file gets parsed by MyRex,
		whereas the keyword %MYREX_LISTING% will get replaced by
		the results of the sql-queries from the passed sql-file.
		Default: ./{monitor-id}.msg

 	-D database

		The MySQL-database to use.

	-u user

		The MySQL user name to use when connecting to the
		MySQL-server.

	-p password

		The password to use when connecting to the MySQL-server.

	-r

		Enables the --raw option for MySQL.
		This option disables the character escaping and allows
		the 'injection' of newlines and other special characters
		into the MySQL output.
		Default: disabled

	-h

		Displays this helpfile.

ENVIRONMENT VARIABLES

	TMPDIR

		Used as directory for temporary files instead of /tmp,
		if set.

BUGS

	Please e-mail bug reports to more@codeless.at.

AUTHOR

	MyRex was written by Manuel Hiptmair in April - May 2012.

"


usage () {
	echo "$PROGRAM_DESCRIPTION" | more
	exit 1
}

quit () {
	echo "Failure: $1" >&2
	echo "Quitting..." >&2
	exit 1
}


# Initialize variables:
SQL_FILE= 		# -f
EMAIL_SUBJECT= 		# -s
EMAIL_TO= 		# -a
EMAIL_CC= 		# -c
EMAIL_FILE= 		# -e
MYSQL_DATABASE= 	# -D
MYSQL_USER= 		# -u
MYSQL_PASSWORD= 	# -p
MYSQL_OPTION_RAW= 	# -r
MONITOR_ID=
TEMPORARY_DIR=$TMPDIR


# Query commandline arguments:
while getopts f:s:a:e:D:u:p:r opt
do
	case "$opt" in
		f) 	SQL_FILE="$OPTARG";;
		s) 	EMAIL_SUBJECT="$OPTARG";;
		a) 	EMAIL_TO="$OPTARG";;
		c) 	EMAIL_CC="$OPTARG";;
		e) 	EMAIL_FILE="$OPTARG";;
		D) 	MYSQL_DATABASE=$OPTARG;;
		u) 	MYSQL_USER="$OPTARG";;
		p) 	MYSQL_PASSWORD="$OPTARG";;
		r) 	MYSQL_OPTION_RAW="--raw";;
		h) 	usage;;
		\?) 	usage;;
	esac
done
shift `expr $OPTIND - 1`

MONITOR_ID=$@


# Check for have-to parameters:

# monitor-id given?
if [ "$MONITOR_ID" = "" ]
then
	quit "No monitor-id passed"
fi

# E-Mail receiver given?
if [ "$EMAIL_TO" = "" ]
then
	quit "No email receiver passed"
fi

# MySQL database given?
if [ "$MYSQL_DATABASE" = "" ]
then
	quit "No MySQL database passed"
fi

# MySQL user given?
if [ "$MYSQL_USER" = "" ]
then
	quit "No MySQL user passed"
fi

# MySQL password given?
if [ "$MYSQL_PASSWORD" = "" ]
then
	quit "No MySQL password passed"
fi


# Set defaults

# SQL-file passed?
if [ "$SQL_FILE" = "" ]
then
	SQL_FILE="`pwd`/$MONITOR_ID.sql"
fi

# SQL-file valid?
if [ -s $SQL_FILE ]
then
	echo "The sql-file $SQL_FILE does exist"
else
	quit "The sql-file $SQL_FILE does not exist or is empty"
fi

# Message-file passed?
if [ "$EMAIL_FILE" = "" ]
then
	EMAIL_FILE="`pwd`/$MONITOR_ID.msg"
fi

# Message-file valid?
if [ -s $EMAIL_FILE ]
then
	echo "The message-file $EMAIL_FILE does exist"
else
	quit "The message-file $EMAIL_FILE does not exist or is empty"
fi

# Temporary directory given?
if [ "$TEMPORARY_DIR" = "" ]
then
	TEMPORARY_DIR="/tmp"
fi

# Temporary directory valid?
if [ -d $TEMPORARY_DIR ]
then
	echo "Temporary directory $TEMPORARY_DIR exists"
else
	quit "Temporary directory $TEMPORARY_DIR does not exist"
fi

# E-Mail subject given?
if [ "$EMAIL_SUBJECT" = "" ]
then
	EMAIL_SUBJECT="$MONITOR_ID"
fi

# Create a unique ID for the current monitor:
#MONITOR_ID=`openssl dgst $SQL_FILE | awk -F" " '{ print $2 }'`
#echo "Your monitor-ID for $SQL_FILE is: $MONITOR_ID"

# Query the database
RESULTFILE="$TEMPORARY_DIR/myrex.$MONITOR_ID.new"
mysql -D $MYSQL_DATABASE -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_OPTION_RAW < $SQL_FILE > $RESULTFILE

# If the query returned a result
if [ -s $RESULTFILE ]
then
	# If the file /tmp/myrex.UniqueID.old does exist
	OLD_RESULTFILE="$TEMPORARY_DIR/myrex.$MONITOR_ID.old"
	if [ -e $OLD_RESULTFILE ]
	then
		# Compare the new and the old file using cmp
		DIFFERENCE=1
		cmp $RESULTFILE $OLD_RESULTFILE && DIFFERENCE=0

		# If files differ
		if [ $DIFFERENCE -eq 0 ]
		then
			echo "Results do not differ"
		else
			echo "Results differ"

			# Compile message
			MYREX_MESSAGE="$TEMPORARY_DIR/myrex.$MONITOR_ID.msg"
			sed -e "/%MYREX_LISTING%/ r $RESULTFILE" < $EMAIL_FILE | sed -e "s/%MYREX_LISTING%//" > $MYREX_MESSAGE

			# Send message
			mailx -s "$EMAIL_SUBJECT" -c "$EMAIL_CC" $EMAIL_TO < $MYREX_MESSAGE
		fi

		# Delete old-file
		rm $OLD_RESULTFILE
	fi

	# Rename new-file to old-file
	mv $RESULTFILE $OLD_RESULTFILE
fi

# vim: set tw=72
