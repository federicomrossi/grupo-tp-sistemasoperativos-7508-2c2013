#!/bin/bash
#Script StartX del TP-Grupo 9 Sistemas Operativos - FIUBA
#Param:
#		$1: Nombre del proceso a ejecutar como demonio

if [ $# -eq 0 ]; then
	NombreProceso="DetectaX.sh"
else
	NombreProceso="$1"
fi

PID=$(getPID.sh "$NombreProceso" $$)
comando=`echo "$NombreProceso" | sed s+".sh"++`
extension=$(echo $NombreProceso | cut -d "." -f 2) 

if [ -z "$PID" ]; then

	if [ $extension == "pl" ]; then
	  	 ./"$NombreProceso"
	else
		"$NombreProceso" &
	fi
	
	PID=$(getPID.sh "$NombreProceso" $$)
	GlogX.sh -c $comando -t I -m "En StartX.sh: El comando $comando fue inicializado con PID $PID"
	
fi

