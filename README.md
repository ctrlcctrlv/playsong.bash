# playsong.bash

Play a song with visualization using only NVIDIA's driver, Bash, and ffmpeg

----

Sing a song of gladness and cheer<br>
For the time of Christmas is here<br>
Look around about you and see<br>
What a world of wonder this world can be

## Usage
```bash
playsong [infile] [subsfile] [outfile]
```

E.g.:
```bash
./playsong.sh ~/Music/KORN/\[2007\]\ \[untitled\]/04.\ Evolution.flac /tmp/evolution.lrc
```

## Requires
* NVIDIA card (for realtime playback)
* Bash
* ffmpeg (a very [bloated](https://github.com/ctrlcctrlv/bloated-ffmpeg-compile-command) one at least compiled against CUDA and all standard AVFilters)

### Optional deps
* mpv

## License
```
Copyright 2022 Fredrick R. Brennan

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this software or any of the provided source code files except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.
```

**By contributing you release your contribution under the terms of the license.**
