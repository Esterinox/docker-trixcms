#!/bin/sh
for i in `seq 1 3`
do
  mysqladmin --host=${TRIX_DB_HOST} --user=${TRIX_DB_USERNAME} -p${TRIX_DB_PASSWORD} ping
  r=$?
  if [ $r -eq 0 ]
  then
    break
  else
    sleep 5
  fi
done

exit $r
