#!/bin/bash
# Requires bash, as it uses the [[ ]] syntax.
#
# If it's puppet code, lint it up.
 
# I we don't have puppet-lint, so just exit and leave them be.
which puppet-lint >/dev/null 2>&1 || exit
 
# Variables goes hither
declare -a FILES
IFS="
"
FILES=$(git diff --cached --name-only --diff-filter=ACM )
 
for file in ${FILES[@]}
do
  if [[ $file =~ \.*.pp$ ]]
  then
    puppet-lint --with-filename "$file"
    RC=$?
    if [ $RC -ne 0 ]
    then
      exit $RC
    fi
  fi
done
 
exit 0
