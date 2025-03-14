#!/bin/bash
# zenity exists check
command -v zenity >/dev/null 2>&1 || { notify-send "I require zenity but it's not installed. Aborting."; exit; }

# insert url
if url=$(zenity --entry --text="" --title="Insert the URL :"); then
  echo ""
else
  # URL exists check
  zenity --warning --title="Error" --text="Operation aborted."
  exit
fi

# not root check
if [ "$EUID" = 0 ]; then
  echo "Please do not run this script as root!"
  zenity --warning --title="Error" --text="Please do not run this script as root."
  exit
fi

if zenity --question --text="Do you want to use a local version of yt-dlp (requires ffmpeg) or do you want to install a temporary one?" --title="Local install"; then
	if choice=$(zenity --list --radiolist --column="Choose" --column="Option" FALSE "Best audio + Best video" FALSE "Audio + Video 480p" FALSE "Audio + Video 720p" FALSE "Audio + Video 1080p" FALSE "Audio + Best video" FALSE "Best audio only"); then
	    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')  # Convert choice to lowercase
	    if [ "$choice" = "best audio + best video" ]; then
	        (
	        yt-dlp --newline --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "bv+ba/b" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 480p" ]; then
	        (
	        yt-dlp --newline  --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:480,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 720p" ]; then
	        (
	        yt-dlp --newline  --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:720,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 1080p" ]; then
	        (
	        yt-dlp --newline  --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:1080,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + best video" ]; then
	        (
	        yt-dlp --newline  --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "ba[abr<100]+bv/b" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "best audio only" ]; then
	        (
	        yt-dlp --newline --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "ba/b" -x --audio-quality 0 "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    fi
	else
	    zenity --warning --title="Error" --text="Operation aborted."
	    exit
	fi
else
	# directory "yt-dlp check"
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
	     \
	    --auto-kill 
	fi


	if choice=$(zenity --list --radiolist --column="Choose" --column="Option" FALSE "Best audio + Best video" FALSE "Audio + Video 480p" FALSE "Audio + Video 720p" FALSE "Audio + Video 1080p" FALSE "Audio + Best video" FALSE "Best audio only"); then
	    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')  # Convert choice to lowercase
	    if [ "$choice" = "best audio + best video" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "bv+ba/b" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 480p" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:480,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 720p" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:720,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + video 1080p" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -S "res:1080,fps" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "audio + best video" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "ba[abr<100]+bv/b" "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    elif [ "$choice" = "best audio only" ]; then
	        (
	        $HOME/.local/share/yt-dlp/yt-dlp --newline --ffmpeg-location $HOME/.local/share/yt-dlp --no-config --embed-chapters --embed-subs --write-auto-sub --sub-lang "it.*,en.*" -o $HOME/"%(channel)s - %(title)s" -f "ba/b" -x --audio-quality 0 "$url" | grep --line-buffered -oP '^\[download\].*?\K([0-9.]+|#\d+ of \d)'
	        ) | zenity --progress --title="Downloading" --text="Please wait..." --percentage=0 --auto-kill && notify-send "Download done!"
	    fi
	else
	    zenity --warning --title="Error" --text="Operation aborted."
	    exit
	fi
fi
