LH_POD=$(kubectl get pod -l app=longhorn-loader -n archie -o json | jq --raw-output '.items[0].metadata.name')
TERM_WIDTH=$(tput cols)
ORIG_DIR=$PWD


#cd /media/Movies
#echo -e "\n${ANSI_GREEN}Copying movies...${ANSI_COLOR_RESET}"
#
#for MOVIE in *
#do
#	if [[ $MOVIE == "Beauty and the Beast (1991)" ]]; then continue; fi
#	if [[ $MOVIE == "Howl's Moving Castle (2004)" ]]; then continue; fi
#	printf "\tCopying over $MOVIE..."
#	kubectl cp "/media/Movies/$MOVIE" -n archie $LH_POD:/media/Movies
#	printf "%$((TERM_WIDTH - 16 - ${#MOVIE}))s" "[$(tput setaf 2) DONE $(tput sgr0)]"
#	echo
#done
#
#echo -e "${ANSI_GREEN}Movies copied!${ANSI_COLOR_RESET}"
#

cd /media/Music
TOTAL_SIZE=$(du -s | grep -oP "\d*")
TOTAL_COPIED=0
echo -e "\n${ANSI_GREEN}Copying music...${ANSI_COLOR_RESET}"

BG_GREEN=$(tput setab 2)
BG_RESET=$(tput sgr0)

for ARTIST in *
do 
	ARTIST_DIR_SIZE=$(du -s "./${ARTIST}" | grep -oP "\d*" | head -n 1)
	TOTAL_COPIED=$((TOTAL_COPIED + ARTIST_DIR_SIZE))
	PROP_COPIED=$(awk "BEGIN {print $TOTAL_COPIED / $TOTAL_SIZE}")
	BAR_FILL=$(awk "BEGIN {print int($PROP_COPIED * $TERM_WIDTH)}")
	PCT_COPIED=$(awk "BEGIN {print $PROP_COPIED * 100}")
	kubectl cp "/media/Music/$ARTIST" -n archie $LH_POD:/media/Music
	#echo $BAR_FILL	
	printf "[ %05.2f%% " $PCT_COPIED 
	printf " (%09d / %d) " $TOTAL_COPIED $TOTAL_SIZE
	printf "${BG_GREEN} %.0s" $(seq 0 $(( BAR_FILL - 38 )))
	printf "${BG_RESET} %.0s" $(seq 0 $((TERM_WIDTH - BAR_FILL - 42)))
	printf "%s\r" " ]"
done

echo $BG_RESET
cd $ORIG_DIR 2>&1 > /dev/null
echo

