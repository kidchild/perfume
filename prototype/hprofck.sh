#!/bin/sh
#
# Author: youqian 
#

PPROF_EXE=/opt/gperftools-2.0/bin/pprof
TARGET_EXE=/opt/someexe/someexe
PREFIX=someexe.profile

# DON'T change following if no feature-add/bug-fix
MEMLOG_FILE=memlog.txt
PPROF_CMD="$PPROF_EXE --text $TARGET_EXE "
START=1

# figure out START
if [ -f $MEMLOG_FILE ]; then
  START_IN_FILE=`tail -1 $MEMLOG_FILE | sed -n 's/.*\([0-9]\{4\}\)\.heap.*/\1/p'`
  [ "x$START_IN_FILE" = "x" ] || START=`expr $START_IN_FILE + 1`
fi

CURRENTFILE=`printf "%0#4d" "$START"`
FILENAME=$PREFIX.$CURRENTFILE.heap

[ -f $FILENAME ] || {
  echo "$FILENAME is not produced, wait a while and try again"
  exit -1
}

echo "Start from file: $FILENAME"

echo $FILENAME
while [ -f $FILENAME ]; do
  $PPROF_CMD $FILENAME | sed -n '2,21s/^.*$/'$FILENAME'\t&/p' >> $MEMLOG_FILE

  CURRENTFILE=`expr $CURRENTFILE + 1`
  CURRENTFILE=`printf "%0#4d" "$CURRENTFILE"`
  FILENAME=$PREFIX.$CURRENTFILE.heap
done

echo "Done at file $FILENAME"

