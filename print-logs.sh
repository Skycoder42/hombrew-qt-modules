#!/bin/bash

for file in $(ls /Users/travis/Library/Logs/Homebrew/qtdatasync/); do
	echo "===> Logs of file: $file"
	if [ -e "$file" ]; then
		cat "$file"
	else
		echo "    --- file does not exist ---"
	fi
done
