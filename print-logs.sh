#!/bin/bash

LOG_DIR=/Users/travis/Library/Logs/Homebrew/qtdatasync/
for file in $(ls $LOG_DIR); do
	echo "===> Logs of file: $file"
	if [ -e "$LOG_DIR/$file" ]; then
		cat "$LOG_DIR/$file"
	else
		echo "    --- file does not exist ---"
	fi
done

exit 1
