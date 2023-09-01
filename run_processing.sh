#!/bin/sh
# run processing in presentation mode (full screen)
echo "[arche-scriptures] start processing"
processing-java --sketch=/Users/student/archeReaderController --run & (sleep 15s && killall -u student java)
echo "[arche-scriptures] closed first processing instance"
echo "[arche-scriptures] wait 20 seconds"
sleep 20s
echo "[arche-scriptures] start processing in presentation mode"
processing-java --sketch=/Users/student/archeReaderController --present