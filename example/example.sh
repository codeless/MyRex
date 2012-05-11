#! /bin/bash

# Install database:
mysql -u root -proot < example.install.sql

# Example call of myrex.sh, with password on the commandline:
../myrex.sh -a mail@domain.com -D myrex_example -u root -p root -r example

# Example call of myrex.sh, with no password (MySQL takes care about that):
../myrex.sh -a mail@domain.com -D myrex_example -u root -r example

# Example call of myrex.sh, with password inside protected file:
../myrex.sh -a mail@domain.com -D myrex_example -u root -d ~/.my.personal.cnf -r example

# Remove database:
mysql -u root -proot -e "DROP DATABASE myrex_example;"
