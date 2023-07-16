#!/bin/bash
#   Copyright 2022–2023 Fredrick R. Brennan
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

FFSPECCOLOR="${FFSPECCOLOR:-intensity}"
INPUT="${INPUT:-$1}"
_COVERGIVEN="$COVER"
COVER="${COVER:-"$(readlink -f "$(dirname -- "$1")/cover.jpg")"}"
_cover_extensions=(jpg jpeg png gif webp jxl avif bmp)
breakout=""
for ext in "${_cover_extensions[@]}"; do
    for possible_cover in cover folder; do
        if [[ ! -f "$COVER" && -z "$_COVERGIVEN" ]]; then
            COVER="$(readlink -f "$(dirname -- "$1")")/$possible_cover.$ext"
        fi
        >&2 echo "Trying $COVER…"
        if [[ -f "$COVER" ]]; then
            breakout=1
            break
        fi
    done
    if [[ -n "$breakout" ]]; then
        break
    fi
done
if [[ ! -f "$COVER" ]]; then
    COVER=/usr/share/playsong/logo.webp
fi
SUBS="$2"
OUT="$3"
OUTRATE="${OUTRATE:-60}"
OUTQP="${OUTQP:-23}"
OUTHEIGHT="${OUTHEIGHT:-1080}"
OUTWIDTH="${OUTWIDTH:-1920}"
MPVARGS="${MPVARGS:--hwdec=auto}"
which nvidia-smi > /dev/null && ( export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
VCODECEXTRA=_nvenc)
[[ -d /opt/intel/oneapi ]] && VCODECEXTRA=_vaapi
if [ ! -z "$SUBS" ]; then
    SUBS_ADD=",subtitles=$SUBS"
else
    SUBS_ADD=""
fi
if [ ! -z "$HEVC" -a -z "$VCODEC" ]; then
    VCODEC="hevc$VCODECEXTRA -qp $OUTQP"
elif [ -z "$VCODEC" ]; then
    VCODEC="h264$VCODECEXTRA -qp $OUTQP"
fi
if [[ "$VCODEC" =~ v[[:digit:]]* ]]; then
    VEXTRA=", format=yuv420p"
fi
if [[ "$VCODECEXTRA" = "_vaapi" ]]; then
    VEXTRA="$VEXTRA, format=nv12,hwupload"
fi
if [ ! -z "$FLAC" ]; then
    ACODEC=copy
else
    ACODEC='aac -b:a 128k'
fi
AEXTRA="${AEXTRA:--ac 2}"

OUTHEIGHTEQ=$(bc <<< "($OUTHEIGHT/2)-($OUTHEIGHT/10)")
OVERLAYEQ=$(bc <<< "$OUTHEIGHT-$OUTHEIGHTEQ")

[[ -d /opt/intel/oneapi ]] && \
    BEFOREARGS="-hwaccel vaapi -init_hw_device vaapi -hwaccel_output_format vaapi"
if [[ "$OUT" =~ \.mp4$ ]]; then
    MP4=1
else
    MP4=0
fi
if [ -z "$OUT" ]; then
    WRAP=1
    OUTFLAGS='-f matroska'
    OUT='-'
else
    WRAP=0
fi
if [ $((MPEGTS)) -eq 1 -o \( $((MPEGTS)) -ne 0 -a $((MP4)) -eq 1 \) ]; then
    OUTFLAGS="-bsf:v h264_mp4toannexb -movflags +faststart -f mpegts"
fi

mapfile -d '' COMMAND < <(head -c -1 << 'EOF'
ffmpeg $BEFOREARGS -i $(printf "%q" "$INPUT") -r "$OUTRATE" -i $(printf "%q" "$COVER") \
-filter_complex \
    $(printf "%q" "showspectrum=slide=scroll : fps=$OUTRATE : color=$FFSPECCOLOR : mode=separate : s=${OUTWIDTH}x${OUTHEIGHTEQ},
    format=rgba, colorchannelmixer=1:0:0:0:0:1:0:0:0:0:1:0:1:1:1:0,
    setsar[t];

    [1:v]scale=$OUTWIDTH : $OUTHEIGHT : force_original_aspect_ratio=1 ,
    format=yuv420p, pad=$OUTWIDTH : $OUTHEIGHT : 0 : (oh-ih)/2,
    loop=-1:1:1 [bg];

    [bg][t]overlay=y=$OVERLAYEQ: shortest=1 $SUBS_ADD $VEXTRA") \
    -r "$(($OUTRATE))" -c:v $VCODEC -c:a $ACODEC $AEXTRA
EOF
)

PLAYER=${PLAYER:-$(hash mpv && echo "$(which mpv)" ${MPVARGS} || which ffplay)}
[[ "$PLAYER" =~ ffplay$ ]] && PLAYER="${PLAYER} -autoexit"

if [ $((WRAP)) -eq 0 ]; then
    FINAL_COMMAND="$(eval echo "$COMMAND") $OUTFLAGS $(printf "%q" "$OUT")"
else
    FINAL_COMMAND="$PLAYER <(eval "$(printf "%q" "$(eval echo "$COMMAND")")" $OUTFLAGS "$(printf "%q" "$OUT")")"
fi

if [ $((ECHOONLY)) -eq 1 ]; then
    echo "$FINAL_COMMAND"
else
    eval $FINAL_COMMAND
fi

stty sane

# vim: ts=4 sw=4 et
