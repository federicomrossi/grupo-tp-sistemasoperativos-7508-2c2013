#!/bin/bash
########################MAIN########################

q=`ps -ef | grep -v grep | grep '[.]/Recibir_B.sh' | wc -l`
if [ $q -eq 0 ]
then
	./Recibir_B.sh &
	LASTPID=$!
	echo "Se inicio la ejecucion del demonio Recibir_B.sh bajo el PID: $LASTPID"
else
	echo "Ya se encuentra en ejecucion una instancia del demonio Recibir_B.sh"
fi