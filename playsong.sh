#!/bin/bash
#   Copyright 2022 Fredrick R. Brennan
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

INPUT="${INPUT:-$1}"
COVER="${COVER:-$(dirname -- "$1")/cover.jpg}"
SUBS="$2"
OUT="$3"
OUTRATE="${OUTRATE:-30}"
OUTQP="${OUTQP:-23}"
OUTHEIGHT="${OUTHEIGHT:-1080}"
OUTWIDTH="${OUTWIDTH:-1920}"
if [ ! -z "$SUBS" ]; then
    SUBS_ADD=",subtitles=$SUBS"
else
    SUBS_ADD=""
fi
if [ ! -z "$HEVC" -a -z "$VCODEC" ]; then
    VCODEC="hevc_nvenc -qp $OUTQP"
elif [ -z "$VCODEC" ]; then
    VCODEC="h264_nvenc -qp $OUTQP"
fi
if [[ "$VCODEC" =~ v[[:digit:]]* ]]; then
    VEXTRA=", format=yuv420p"
fi
if [ ! -z "$FLAC" ]; then
    ACODEC=copy
else
    ACODEC='aac -b:a 128k'
fi

OUTHEIGHTEQ=$(bc <<< "($OUTHEIGHT/2)-($OUTHEIGHT/10)")
OVERLAYEQ=$(bc <<< "$OUTHEIGHT-$OUTHEIGHTEQ")

export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
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
ffmpeg -i $(printf "%q" "$INPUT") -r "$OUTRATE" -i "$COVER" \
-filter_complex \
    $(printf "%q" "showspectrum=slide=scroll : color=intensity : mode=separate : fps=$OUTRATE,
    setsar=1, format=rgba, colorchannelmixer=1:0:0:0:0:1:0:0:0:0:1:0:1:1:1:0,
    scale=$OUTWIDTH : $OUTHEIGHTEQ[t];

    [1:v]scale=$OUTWIDTH : $OUTHEIGHT : force_original_aspect_ratio=1 ,
    format=yuv420p, pad=$OUTWIDTH : $OUTHEIGHT : 0 : (oh-ih)/2,
    loop=-1:1:1 [bg];

    [bg][t]overlay=y=$OVERLAYEQ: shortest=1 $SUBS_ADD $VEXTRA") \
-vsync 1 -r "$OUTRATE" -c:v $VCODEC -c:a $ACODEC
EOF
)

PLAYER=$(hash mpv && which mpv || which ffplay)

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
