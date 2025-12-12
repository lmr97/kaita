# NOTE: INCOMPLETE. may never be finished, since copy-media.sh works quite well.

LH_POD=$(kubectl get pod -l app=longhorn-loader -n archie -o json | jq --raw-output '.items[0].metadata.name')
TERM_WIDTH=$(tput cols)
ORIG_DIR=$PWD

: '
cd /media/Movies
echo -e "\n${ANSI_GREEN}Copying movies...${ANSI_COLOR_RESET}"

for MOVIE in *
do 
	printf "\tCopying over $MOVIE..."
	tar cf - "$MOVIE" | kubectl exec -i -n archie $LH_POD -- tar xf - -C /
	printf "%$((0 - 11 - ${#MOVIE}))s" "[$(tput setaf 2) DONE $(tput sgr0)]"
	echo
done

echo -e "${ANSI_GREEN}Movies copied!${ANSI_COLOR_RESET}"
'
cd /media/Music
TOTAL_SIZE=$(du -s | grep -oP "\d*")
TOTAL_COPIED=0
echo -e "\n${ANSI_GREEN}Copying music...${ANSI_COLOR_RESET}"

BG_GREEN=$(tput setab 2)
BG_RESET=$(tput sgr0)

for ARTIST in *
do 
	ARTIST_DIR_SIZE=$(du -s "./${ARTIST}" | grep -oP "\d*" | head -n 1)
	PROP_COPIED=$(awk "BEGIN {print $TOTAL_COPIED / $TOTAL_SIZE}")
	BAR_FILL=$(awk "BEGIN {print int($PROP_COPIED * $TERM_WIDTH) }")
	PCT_COPIED=$(awk "BEGIN {print $PROP_COPIED * 100}")
	
	sleep 0.0001 #tar cf - "$ARTIST" | kubectl exec -i -n archie $LH_POD -- tar xf - -C /
	
	printf "[ %05.2f%%" $PCT_COPIED 
	printf " (%09d / %d) " $TOTAL_COPIED $TOTAL_SIZE
	printf "${BG_GREEN} %.0s" $(seq $((BAR_FILL - 35)))
	printf "${BG_RESET} %.0s" $(seq $((TERM_WIDTH - BAR_FILL - 35)))
	printf "%s\r" "]"
	
	TOTAL_COPIED=$((TOTAL_COPIED + ARTIST_DIR_SIZE))
done

echo $BG_RESET
cd $ORIG_DIR 2>&1 > /dev/null
echo
