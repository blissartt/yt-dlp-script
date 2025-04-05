#!/bin/bash

# Function to show a warning
show_warning() {
    zenity --warning --title="Error" --text="$1"
}

# Function to download a video using yt-dlp with the selected options
download_video() {
    local url=$1
    local output_path=$2
    local format=$3
    local subtitles=$4

    (
        "$yt_dlp_path" -v --ffmpeg-location "$ffmpeg_path" --newline --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "${subtitles:-it.*,en.*}" -o "$output_path" $format "$url" && notify-send "Download done!" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
    ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill
}

# zenity exists check
command -v zenity >/dev/null 2>&1 || { notify-send "I require zenity but it's not installed. Aborting."; exit; }

# Insert URL
url=$(zenity --entry --text="" --title="Insert the URL :" 2>/dev/null)
if [ -z "$url" ]; then
    show_warning "Operation aborted."
    exit
fi

# Not root check
if [ "$EUID" = 0 ]; then
    show_warning "Please do not run this script as root."
    exit
fi

# Prompt to choose yt-dlp version
if zenity --question --text="Do you want to use a local version of yt-dlp (requires ffmpeg) or install a temporary one?" --title="Local install" --cancel-label="Use temporary install" --ok-label="Use local version"; then
	yt_dlp_path="yt-dlp"
	ffmpeg_path="/usr/bin"
else
	# Check if yt-dlp directory exists and is not empty
	if [ "$('ls' -- "$HOME/.local/share/yt-dlp" 2> /dev/null)" ] && [ -n "$(ls -A "$HOME/.local/share/yt-dlp")" ]; then
		echo ""
	else
		#yt-dlp setup
		(
		'rm' -rf $HOME/.local/share/yt-dlp
		'mkdir' $HOME/.local/share/yt-dlp && cd $HOME/.local/share/yt-dlp ; sleep 0.5
		echo "10"
		wget -O yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux 2> /dev/null ; sleep 0.5
		echo "25"
		wget -O ffmpeg.tar.xz https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz 2> /dev/null ; sleep 0.5
		echo "50"
		tar xf ffmpeg.tar.xz --directory=. && rm ffmpeg.tar.xz ; sleep 0.5
		echo "75"
		'mv' ffmpeg-master-latest-linux64-gpl/bin/* . && 'rm' -rf ffmpeg-master-latest-linux64-gpl ; sleep 0.5
		'chmod' +x * && ls && cd $HOME ; sleep 0.5
		echo "100" ; sleep 1
		) | zenity --progress \
			--title="Progress Status" \
			--text="Preparing setup..." \
			--percentage=0 \
			--auto-close \
			--auto-kill 
		fi
		yt_dlp_path="$HOME/.local/share/yt-dlp/yt-dlp"
		ffmpeg_path="$HOME/.local/share/yt-dlp/"
fi




# User choice for download format
choice=$(zenity --list --radiolist --column="Choose" --column="Option" \
    FALSE "Best audio + Best video" \
    FALSE "Audio + Video 480p" \
    FALSE "Audio + Video 720p" \
    FALSE "Audio + Video 1080p" \
    FALSE "Audio + Best video" \
    FALSE "Best audio only" \
    FALSE "Custom")

# Exit if choice is empty (cancelled)
if [ -z "$choice" ]; then
    show_warning "Operation aborted."
    exit
fi

# Convert choice to lowercase
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

# Prepare output path (reusable)
output_path=$(zenity --file-selection --title="Save to..." --directory)/"%(channel)s - %(title)s"

# If output path is not set, abort
if [ $? -ne 0 ]; then
    show_warning "Error: PATH not set."
    exit
fi

# Default subtitle languages
subtitles="it.*,en.*"

# Case handling for different formats
case "$choice" in
    "best audio + best video")
        format="-f bv+ba/b"
        ;;
    "audio + video 480p")
        format="-S res:480,fps"
        ;;
    "audio + video 720p")
        format="-S res:720,fps"
        ;;
    "audio + video 1080p")
        format="-S res:1080,fps"
        ;;
    "audio + best video")
        format="-f ba[abr<100]+bv/b"
        ;;
    "best audio only")
        format="-f ba/b -x --audio-quality 0"
        ;;
    "custom")
        resolution=$(zenity --entry --text="Enter resolution (e.g., 720, 1080...):" --title="Resolution")
        subtitles=$(zenity --entry --text="Enter subtitle languages (comma-separated, e.g., it,en):" --title="Subtitle Languages")
        if [ -n "$resolution" ]; then
            format+="-S res:$resolution"
        fi
        ;;
    *)
        show_warning "Invalid option selected."
        exit
        ;;
esac

# Perform download
download_video "$url" "$output_path" "$format" "$subtitles"
