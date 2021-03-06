#!/bin/sh

###############################################################################
# FUNCTIONS
###############################################################################
usage()
{
	echo "NAME"
	echo "        youtube-samsung - download videos from youtube.com and set usable codecs on samsung televisions"
	echo "DEPENDENCIES"
	echo "        youtube-dl"
	echo "        ffmpeg"
	echo "SYNOPSIS"
	echo "        ./youtube-samsung [OPTION] <ARGUMENT>"
	echo "DESCRIPTION"
	echo "        Download an entire playlist, or a single video, from a youtube ID or a URL."
	echo "        Only one option at a time can be used"
	echo "OPTIONS"
	echo "        -l, --list"
	echo "                Download entire playlist.  <argument> is the playlist ID"
	echo "        -lu, --lurl"
	echo "                Download entire playlist.  <argument> is the playlist URL"
	echo "        -v, --video"
	echo "                Download single video.  <argument> is the video ID"
	echo "        -vu, --vurl"
	echo "                Download single video.  <argument> is the video URL"
	echo "        -d, --dir, --directory"
	echo "                Download file in directory given in <argument>.  If the argument is missing, or if the script is used without this option, files are saved in the current directory"
	echo "        -y, --yes"
	echo "                Overwrite existing files"
	echo "EXAMPLES"
	echo "        Download playlist from list URL"
	echo "                ./youtube-samsung.sh -lu https://www.youtube.com/watch?list=PLHJH2BlYG-EEBtw2y1njWpDukJSTs8Qqx"
	echo "        Download playlist from list ID"
	echo "                ./youtube-samsung.sh -l PLHJH2BlYG-EEBtw2y1njWpDukJSTs8Qqx"
	echo "        Download single video from video URL"
	echo "                ./youtube-samsung.sh -vu https://www.youtube.com/watch?v=zSQbUV-u5Xo"
	echo "        Download single video from video ID"
	echo "                ./youtube-samsung.sh -v zSQbUV-u5Xo"
}

###############################################################################
# SCRIPT ENTRY POINT
###############################################################################
listid=""
videoid=""
url=""
targetdir=""	# Default target directory is the current directory
overwrite=false

#
# CHECK SCRIPT'S ARGUMENTS
#

# Get arguments from command line
while [ "$1" != "" ]; do
	case $1 in
		-l|--list)	# Pass playlist id
			listid="$2"
			if [ "$listid" = "" ]; then
				echo "Error: Missing argument with option -l, --list" ; echo
				usage
				exit 1
			fi
			shift 2
			;;
		-lu|--lurl)	# Pass playlist url
			lurl="$2"
			if [ "$lurl" = "" ]; then
				echo "Error: Missing argument with option -lu, --lurl" ; echo
				usage
				exit 1
			fi
			shift 2
			;;
		-v|--video)	# Pass video id
			videoid="$2"
			if [ "$videoid" = "" ]; then
				echo "Error: Missing argument with option -v, --video" ; echo
				usage
				exit 1
			fi
			shift 2
			;;
		-vu|--vurl)	# Pass video url
			vurl="$2"
			if [ "$vurl" = "" ]; then
				echo "Error: Missing argument with option -vu, --vurl" ; echo
				usage
				exit 1
			fi
			shift 2
			;;
		-d|--dir|--directory)	# Target directory
			targetdir="$2"
			if [ "$targetdir" = "" ]; then
				echo "Error: Missing argument with option -d, --dir, --directory" ; echo
				exit 1
			fi
			shift 2
			;;
		-y|--yes)	# Overwrite files without notice
			overwrite=true
			shift
			;;
		*)
			usage
			exit 1
			;;
	esac
done

# Check number of options in use
i=0
if [ "$listid" != "" ]; then
	i=$((i+1))
fi
if [ "$videoid" != "" ]; then
	i=$((i+1))
fi
if [ "$vurl" != "" ]; then
	i=$((i+1))
fi
if [ "$lurl" != "" ]; then
	i=$((i+1))
fi

if [ "$i" -lt 1 ]; then
	echo "Error: Too few options..." ; echo
	usage
	exit 1
fi
if [ "$i" -gt 1 ]; then
	echo "Error: Too many options in use" ; echo
	usage
	exit 1
fi

#
# START DOWNLOAD
#
echo "STARTING DOWNLOAD ..."

# Make temporary directory
if [ "$targetdir" != "" ]; then
	mkdir "$targetdir"
	echo "... target directory has been built"
else
	#targetdir="$PWD"
	targetdir="."

	echo "... using current directory"
fi

echo " ... downloading.  Please wait!"
# Download video from URL
if [ "$vurl" != "" ]; then
	youtube-dl -f bestvideo+bestaudio -o "$targetdir/"'%(title)s.%(ext)s' "$vurl"
fi

# Download video from ID
if [ "$videoid" != "" ]; then
	vurl="https://www.youtube.com/watch?v=${videoid}"
	youtube-dl -f bestvideo+bestaudio -o "$targetdir/"'%(title)s.%(ext)s' "$vurl"
fi

# Download list from URL
if [ "$lurl" != "" ]; then
	youtube-dl -f bestvideo+bestaudio -o "$targetdir/"'%(title)s.%(ext)s' "$lurl"
fi

# Download list from ID
if [ "$listid" != "" ]; then
	lurl="https://www.youtube.com/watch?list=${listid}"
	youtube-dl -f bestvideo+bestaudio -o "$targetdir/"'%(title)s.%(ext)s' "$lurl"
fi

echo

#
# START CODEC CONVERSION
#
echo "STARTING CONVERSION ..."
# Change audio/video codecs
IFSbackup=$IFS
IFS=$'\n'

for file in "$targetdir"/*
do
	filetype="$(file --mime-type -b "$file" | cut -d\/ -f1)"
	echo "$file is type: $filetype" ; echo
       	if [ "$filetype" = "video" ]; then
		targetfile="${file}.avi"
		echo "... processing \"$file\" to \"$targetfile\".  Please wait!"
		echo "---------------------"
		echo "Overwrite = $overwrite"
		echo "---------------------"
		if [ "$overwrite" = true ]; then
			ffmpeg -y -i "$file" -acodec aac -vcodec libx264 "$targetfile"
		else
			ffmpeg -i "$file" -acodec aac -vcodec libx264 "$targetfile"
		fi
		rm "$file"
	fi
done

IFS=$IFSbackup
echo

echo

echo "CONVERSION IS OVER!"
