#!/bin/bash
########################MAIN########################

q=`ps -ef | grep -v grep | grep '[.]/Recibir_B.sh' | wc -l`
if [ $q -eq 1 ]
then
	p=`ps aux | grep -v grep | grep '[.]/Recibir_B.sh' | awk '{print $2}'`	
	kill -9 $p
	echo "Se detuvo la ejecucion del demonio Recibir_B.sh cuyo PID es $p "
else
	echo "No estaba en ejecucion el demonio Recibir_B.sh"
fi