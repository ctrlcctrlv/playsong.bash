#!/bin/bash
source .env
cat << EOF
# playsong.bash v$VERSION ⏫$(date +%Y%m%d)

Play a song with visualization using only NVIDIA's driver, Bash, and ffmpeg

<a href="https://www.youtube.com/watch?v=DdPv2SEn-rg"><img src="https://i3.ytimg.com/vi/DdPv2SEn-rg/maxresdefault.jpg" width=480></a>

----

♪&nbsp;Sing a song of gladness and cheer&nbsp;♪<br>
♪&nbsp;For the time of Christmas is here&nbsp;♪<br>
♪&nbsp;Look around about you and see&nbsp;♪<br>
♪&nbsp;What a world of wonder this world can be&nbsp;♪
EOF
cat << 'EOF'
## Usage
```bash
playsong [infile] [subsfile] [outfile]
```

E.g.:
```bash
./playsong.sh ~/Music/KORN/\[2007\]\ \[untitled\]/04.\ Evolution.flac /tmp/evolution.lrc
```

## Requires
* Bash
* ffmpeg (a very [bloated](https://github.com/ctrlcctrlv/bloated-ffmpeg-compile-command) one preferred)

### Optional deps
* mpv
* NVIDIA® card or Intel® Xe™ graphics (for realtime playback @ 60fps)

## License
```
EOF
cat LICENSE | grep -A9999 -m1 -P '^\s+Copyright' LICENSE | sed -e "s/\[yyyy\]/2022–`date +%Y`/;s/\[.*/Fredrick R. Brennan/"
cat << 'EOF'
```

**By contributing you release your contribution under the terms of the license.**
EOF
