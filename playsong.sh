#!/bin/bash
INPUT="$1"
COVER="$(dirname -- "$1")/cover.jpg"
SUBS="$2"
OUT="$3"
OUTRATE="${OUTRATE:-60}"
OUTQP="${OUTQP:-23}"
OUTHEIGHT="${OUTHEIGHT:-1080}"
OUTWIDTH="${OUTWIDTH:-1920}"
if [ ! -z "$SUBS" ]; then
    SUBS_ADD="[o]; [o]subtitles=$SUBS,"
else
    SUBS_ADD="[o]; [o]"
fi
if [ ! -z "$HEVC" ]; then
    VCODEC=hevc_nvenc
else
    VCODEC=h264_nvenc
fi
if [ ! -z "$FLAC" ]; then
    ACODEC=copy
else
    ACODEC='aac -b:a 128k'
fi

OUTHEIGHTEQ=$(echo "($OUTHEIGHT/2)-($OUTHEIGHT/10)" | bc)

export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
if [ -z "$OUT" ]; then
    WRAP=1
    OUT='-f matroska -'
else
    WRAP=0
fi
mapfile -d '' COMMAND < <(head -c -1 << 'EOF'
ffmpeg -i "$INPUT" -hwaccel cuda -hwaccel_output_format cuda -i "$COVER" \
-filter_complex "showspectrum=slide=scroll : color=intensity : mode=separate,
format=rgba, colorchannelmixer=1:0:0:0:0:1:0:0:0:0:1:0:1:1:1:0, setsar=1,
hwupload_cuda, scale_npp=$OUTWIDTH : $OUTHEIGHTEQ[t]; [1:v]scale_npp=$OUTWIDTH
: $OUTHEIGHT : force_original_aspect_ratio=decrease : format=yuv420p,
hwdownload, pad=$OUTWIDTH : $OUTHEIGHT : 0 : (oh-ih)/2,
loop=-1:1:1${SUBS_ADD}hwupload_cuda[bg];
[bg][t]overlay_cuda=y=$OUTHEIGHT-($OUTHEIGHTEQ) : shortest=1" -c:v $VCODEC -qp \
"${OUTQP}" -frame_rate 30 -c:a $ACODEC
EOF
)
PLAYER=$(hash mpv && echo mpv || echo ffplay)
set -x
if [ $WRAP -eq 0 ]; then
    eval "$COMMAND $OUT"
else
    $PLAYER <(eval "$COMMAND $OUT")
    reset
fi
set +x
