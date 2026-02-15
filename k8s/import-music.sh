#!/bin/bash

function get-progress() {
	local prog=$(\
		curl -s -H "Authorization: MediaBrowser Token=${JF_API_KEY}" \
		https://archie.zapto.org/jf-lh/Library/VirtualFolders \
		| jq '.[] | select(.Name == "Music") | .RefreshProgress' \
	)
	echo $prog
}


# Written by fearside on Stack Overflow
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
	printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}



echo -e "Importing new files from MacBook to Archie...\n"
rsync \
	--recursive \
	--progress \
	'macbook:/Users/martinreid/Music/music-downloads/Music/' \
	~/music-imports/ \
	2> /dev/null

if [ $? -ne 0 ]
then
	return $?
fi

echo -e "\nAdding new music to Jellyfin library..."
# kubectl cp isn't working with directories, so instead of the following:
#kubectl -n archie cp ~/music-imports/ ${JFPOD:4}:/media/Music
# we've gotta do it the old-fashioned way
tar -cf - -C /home/martin ./music-imports |
	kubectl -n archie exec -i $JFPOD -- \
	tar -xf - --strip-components=2 -C /media/Music
# --strip-components=N removes the enclosing directories to N levels

if [ $? -ne 0 ]
then
	return $?
fi

echo "Starting library rescan..."
jellyroller scan-library $JF_MUSIC_LIB_ID new-updated


PROGRESS=$(get-progress)

while [[ $PROGRESS != "null" ]]; do
	
	PROG_INT=$(printf "%.0f" ${PROGRESS})
	progress-bar $PROG_INT 100	
	sleep 0.2
	PROGRESS=$(get-progress)
done

# fill in last bit
progress-bar 100 100

echo -e "\n${ANSI_GREEN}Done!${ANSI_RESET}"
