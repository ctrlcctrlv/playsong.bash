#!/bin/bash
INPUT="$1"
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
if [ -z "$OUT" ]; then
    WRAP=1
    OUT='-f matroska -'
else
    WRAP=0
fi
mapfile -d '' COMMAND < <(head -c -1 << 'EOF'
ffmpeg -i "$INPUT" -r "$OUTRATE" -i "$COVER" \
-filter_complex \
    "showspectrum=slide=scroll : color=intensity : mode=separate : fps=$OUTRATE,
    setsar=1, format=rgba, colorchannelmixer=1:0:0:0:0:1:0:0:0:0:1:0:1:1:1:0,
    scale=$OUTWIDTH : $OUTHEIGHTEQ[t];

    [1:v]scale=$OUTWIDTH : $OUTHEIGHT : force_original_aspect_ratio=1 ,
    format=yuv420p, pad=$OUTWIDTH : $OUTHEIGHT : 0 : (oh-ih)/2,
    loop=-1:1:1 [bg];

    [bg][t]overlay=y=$OVERLAYEQ: shortest=1 $SUBS_ADD $VEXTRA" \
-vsync 1 -r "$OUTRATE" -c:v $VCODEC -c:a $ACODEC
EOF
)
PLAYER=$(hash mpv && which mpv || which ffplay)
set -x
if [ $WRAP -eq 0 ]; then
    eval "$COMMAND" "$(printf "%q" "$OUT")"
else
    "$PLAYER" <(eval "$COMMAND" $OUT)
fi
set +x
stty sane
