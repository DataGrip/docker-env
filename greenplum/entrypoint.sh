#!/bin/bash
export STATUS=0
i=0
echo "STARTING... (about 30 sec)"
while [[ $STATUS -eq 0 ]] || [[ $i -lt 30 ]]; do
	sleep 1
	i=$((i+1))
	STATUS=$(grep -r -i --include \*.log "Database successfully started" | wc -l)
done

echo "STARTED"

#trap
while [ "$END" == '' ]; do
			sleep 1
			trap "gpstop -M && END=1" INT TERM
done
