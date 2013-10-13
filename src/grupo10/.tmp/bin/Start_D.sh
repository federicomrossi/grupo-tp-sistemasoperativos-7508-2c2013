#!/bin/bash
########################MAIN########################

if [ -z $(pgrep Recibir_B.sh) ] 
then
	#./Recibir_B.sh &
	 nohup Recibir_B.sh > /dev/null 2>&1 &
	LASTPID=$!
	echo "Se inicio la ejecucion del demonio Recibir_B.sh bajo el PID: $LASTPID"
else
	echo "Ya se encuentra en ejecucion una instancia del demonio Recibir_B.sh"
fi