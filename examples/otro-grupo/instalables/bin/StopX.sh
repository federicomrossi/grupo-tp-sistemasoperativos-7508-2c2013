#!/bin/bash
#Script StopX del TP-Grupo 9 Sistemas Operativos - FIUBA
#
#Param:
#		$1: Nombre del proceso a ejecutar como demonio


if [ $# -eq 0 ]; then 
	NombreProceso="DetectaX.sh"
else
	NombreProceso="$1"
fi

IdProceso=$(getPID.sh $NombreProceso $$)
comando=`echo "$NombreProceso" | sed s+".sh"++`
  
      #verifico que se este ejecutando bien
if [ -n "$IdProceso" ];
then
	kill $IdProceso
	GlogX.sh -c $comando -t I -m "En StopX.sh: El comando $comando fue detenido exitosamente"

fi


