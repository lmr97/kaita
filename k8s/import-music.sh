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

IMPORT_DATE=$(date -I)
rsync \
	--recursive \
	--progress \
	--exclude ".DS_Store" \
	--exclude "*/.DS_Store" \
	'macbook:/Users/martinreid/Music/music-downloads/Music/' \
	~/music-imports/${IMPORT_DATE}/



echo -e "\n[${ANSI_GREEN}INFO${ANSI_RESET}] Adding new music to Jellyfin library..."

tar -cf - -C ~/music-imports/ $IMPORT_DATE \
	| kubectl exec -i -n archie $JFPOD -- \
		tar -xf - -C /media/Music/
# buggy, don't use
# kubectl -n archie cp ~/music-imports/${IMPORT_DATE} $JFPOD:/media/Music/

# extract contents of import folder into parent directory
kubectl -n archie exec -it $JFPOD -- bash -c "cd /media/Music; cp -r ./${IMPORT_DATE}/* ."
kubectl -n archie exec -it $JFPOD -- bash -c "rm -r /media/Music/${IMPORT_DATE}"


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
# so we'll ignore it 
# (the remainder of the script is only printing things)
set +e
progress-bar 100 100	


echo -e "\n[${ANSI_GREEN}INFO${ANSI_RESET}] ${ANSI_GREEN}Done!${ANSI_RESET}"

set -e # undo the above `set`, in case this is running in the current shell
