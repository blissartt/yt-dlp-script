# **WARNING**
## **This repo is archived, this project has moved to Codeberg**


## This is a GUI script for yt-dlp.
This script uses the FLOSS program yt-dlp to download videos.
This script uses Zenity to display GUI popups, so the only dependency other than basic GNU utilities is Zenity itself.

### Options
The
 script either lets you use the local version of yt-dlp that is 
installed on your machine (which will require ffmpeg too), or it will 
download the latest yt-dlp and the latest custom-built ffmpeg from the 
yt-dlp devs and store them in :
```
$HOME/.local/share/yt-dlp
```

Be aware that in both cases, the script ignores your custom yt-dlp configuration files.

### Installation
You can either use the script directly or a compiled binary.
The binary cannot obviously be opened and customized at will.

### Defaults
The script downloads Italian and English subtitles as default, but this can be changed in the script.
The default resolutions are also set, but they can be modified and expanded too!

### Credits
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)

- [shc](https://github.com/neurobin/shc) (to compile the bash script)

- [zenity](https://gitlab.gnome.org/GNOME/zenity)

