#! /bin/bash

# Install database:
mysql -u root -proot < examples.install.sql

# Run MyRex two times on the examples;
# the second time after record-updates
for i in 1 2
do
	# Example call of myrex.sh, with password on the commandline:
	../myrex.sh -a mail@domain.com -D myrex_example -u root -p root -r example1

	# Example call of myrex.sh, with no password (MySQL takes care about that):
	../myrex.sh -a mail@domain.com -D myrex_example -u root -r example1

	# Example call of myrex.sh, with password inside protected file:
	../myrex.sh -a mail@domain.com -D myrex_example -u root -d ./.my.personal.cnf -r example1

	# Example call of myrex.sh. mailx should be used but no receiver is passed:
	../myrex.sh -D myrex_example -u root -p root -r example1

	# Example call of myrex.sh, with HTML output and triggering sendmail:
	../myrex.sh -S -f example2.sql -D myrex_example -u root -p root -H example2

	# Example call of myrex.sh, with HTML output as UTF-8 and triggering sendmail:
	../myrex.sh -S -f example3.sql -D myrex_example -u root -p root -H -C utf8 example3

	# Update database:
	mysql -u root -proot -D myrex_example < examples.update.sql
done

# Remove database:
mysql -u root -proot -e "DROP DATABASE myrex_example;"
