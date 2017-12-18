#!/bin/bash
##Add the script to cron and check that the directories and files needed for the script are present.
##*/30 * * * * /scripts/simplemonitor.sh - run simplemonitor.sh every 30 minutes

#work dir
WORKDIR=/scripts/simplemonitor

#sites to monitor
LISTFILE=$WORKDIR/sites

#admin emails to alert
EMAILLIST=$WORKDIR/emails

#tmp dir
TMPDIR=$WORKDIR/tmp

function simplemonitor {
  answer=$(curl -L --write-out %{http_code} --silent --output /dev/null $1)
  file=$( echo $1 | cut -f1 -d"/" )
  echo -n "$p "

  if [ $answer -eq 200 ] ; then
    # site is ok
    echo -n "$answer "; echo -e "\e[32m[ok]\e[0m"
    
	# remove tmp file if exist 
    if [ -f $TMPDIR/$file ]; then rm -f $TMPDIR/$file; fi
  else
    # site is down
    echo -n "$answer "
	echo -e "\e[31m[DOWN]\e[0m"
    if [ ! -f $TMPDIR/$file ]; then
        while read e; do
            mail -s "$p WEBSITE DOWN" "$EMAILLIST"
        done < $EMAILLIST
        echo > $TMPDIR/$file
    fi
  fi
}

# main loop
while read p; do
  simplemonitor $p
done < $LISTFILE