TOTAL_ARTISTS=$(ls /media/Music | wc -l)
N_DONE=0
TERM_WIDTH=$(tput cols)

for ARTIST_DIR in /media/Music/*; 
do
	MSG="Copying music by ${ARTIST_DIR##*/}"
	REM_TERM=$(( $TERM_WIDTH - ${#MSG} - 15 ))	
	
	printf "$MSG... "
	printf "%${REM_TERM}s($N_DONE/$TOTAL_ARTISTS)\n"

	kubectl cp "$ARTIST_DIR" archie/$LOADER_POD:/media/Music
	
	((N_DONE++))
done
