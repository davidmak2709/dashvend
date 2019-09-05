#!/bin/bash


VEND_DIR=/home/pi/dashvend
BIN_DIR=$VEND_DIR/bin
IMAGEDIR=$VEND_DIR/display/source_images
OUTDIR=/tmp/rendered_images

IMG_BLANK_SCREEN=$IMAGEDIR/_blank_screen-480x800.png
IMG_BG_LOADING_SCREEN=$IMAGEDIR/loading-480x800.png
IMG_BG_PAYMENT_SCREEN=$IMAGEDIR/payment-480x800.png


IMG_QR_OVERLAY=$IMAGEDIR/icon-blue_dash_d-360x360.png

QR_PAYMENT_LABEL=Dashvend

if [ ! -e $OUTDIR ]; then
    mkdir $OUTDIR
fi

function gen_screen_payment_pending(){

    addinput=$1
    amount=$2
    /usr/bin/qrencode -s 9 -l M -m 0 -o $OUTDIR/qr.png 'dash:'$addinput'?amount='$amount'&label='$QR_PAYMENT_LABEL''
    /usr/bin/composite -blend 100%x100% -gravity center  $IMG_QR_OVERLAY $OUTDIR/qr.png $OUTDIR/qrd.png
    /usr/bin/convert $IMG_BG_PAYMENT_SCREEN \
        -fill "rgb(0, 141, 228)" \
        -pointsize 60 -draw "text 170,150   '$amount'" \
        -pointsize 20 -gravity South -draw "text 0,40 '$addinput'" \
        $OUTDIR/payment_screen.png
    /usr/bin/composite -geometry +75+387 $OUTDIR/qrd.png $OUTDIR/payment_screen.png $OUTDIR/screen-1.png
    rm $OUTDIR/{payment_screen,qr,qrd}.png 2>/dev/null
};

case "$1" in

  # show black (blank)
  blank|black)
    $BIN_DIR/show_image $IMG_BLANK_SCREEN
    ;;

  # screen 0 - boot screen -- pending ready
  0)
    $BIN_DIR/show_image $IMAGEDIR/loading-480x800.png
    ;;

  # screen 1 - payment screen -- waiting for dash
  1)
    gen_screen_payment_pending $2 $3
    $BIN_DIR/show_image $OUTDIR/screen-1.png
    ;;

  # screen 2 - payment received -- thank you
  2)
    $BIN_DIR/show_image $IMAGEDIR/final-480x800.png
    ;;

  # screen 3 - payment rejected -- try again
  3)
    $BIN_DIR/show_image $IMAGEDIR/rejected-480x800.png
    ;;

  # screen 4 - system shutdown
  4)
    # devhak
    if [ ! -e $OUTDIR/screen-4.png ] ; then
        cp $IMAGEDIR/screen-4.png $OUTDIR/screen-4.png
    fi
    $BIN_DIR/show_image $OUTDIR/screen-4.png
    ;;


  # screen 5 - overpaid
  5)
    $BIN_DIR/show_image $IMAGEDIR/overpaid-480x800.png
    ;;
  *)
    echo "Usage: $0 screen_number" >&2
    exit 3
    ;;

esac
