#!/bin/bash
set -e

function get-progress() {
	local prog=$(\
		curl -s -H "Authorization: MediaBrowser Token=${JF_API_KEY}" \
		https://archie.zapto.org/jf-lh/Library/VirtualFolders \
		| jq '.[] | select(.Name == "Music") | .RefreshProgress' \
	)
	echo $prog
}


# based on code by fearside on Stack Overflow
# https://stackoverflow.com/a/28044986/20496903
function progress-bar() {
    	let _progress=(${1}*100/${2}*100)/100
    	let _done=(${_progress}*4)/10
    	let _left=40-$_done
	# Build progressbar string lengths
    	_fill=$(printf "%${_done}s")
    	_empty=$(printf "%${_left}s")

	# Format:
	# Progress : [####################-------------------] 50%
	printf "\rScan progress : [${ANSI_GREEN}${_fill// /#}${ANSI_RESET}${_empty// /-}] ${_progress}%%"
}



echo -e "\n[${ANSI_GREEN}INFO${ANSI_RESET}] Importing new files from MacBook to Archie...\n"
rsync \
	--recursive \
	--progress \
	'macbook:/Users/martinreid/Music/music-downloads/Music/' \
	~/music-imports/



echo -e "\n[${ANSI_GREEN}INFO${ANSI_RESET}] Adding new music to Jellyfin library..."
# kubectl cp isn't working with directories, so instead of the following:
#kubectl -n archie cp ~/music-imports/ ${JFPOD:4}:/media/Music
# we've gotta do it the old-fashioned way
tar -cf - -C /home/martin ./music-imports |
	kubectl -n archie exec -i $JFPOD -- \
	tar -xf - --skip-old-files --strip-components=2 -C /media/Music
# --strip-components=N removes the enclosing directories to N levels



echo -en "[${ANSI_GREEN}INFO${ANSI_RESET}] "
jellyroller scan-library $JF_MUSIC_LIB_ID new-updated



PROGRESS=$(get-progress)
while [[ $PROGRESS != "null" ]] 
do	
	PROG_INT=$(printf "%.0f" ${PROGRESS})
	progress-bar $PROG_INT 100	
	sleep 0.2
	PROGRESS=$(get-progress)
done

# for some reason progress-bar throws an error, 
# but still prints when passed 100, 100
# we'll igore it
set +e
progress-bar 100 100	


echo -e "\n[${ANSI_GREEN}INFO${ANSI_RESET}] ${ANSI_GREEN}Done!${ANSI_RESET}"
