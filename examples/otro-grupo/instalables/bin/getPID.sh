#!/bin/bash
# Script que devuelve el id de proceso (PID)
#   Parametros: 
#	Parametro 1: Proceso del cual quiero determinar el PID.
#	Parametro 2: Proceso que invoca a la función esta.
#   Codigo de salida del comando
#	0: Salida exitosa
#   	1: No se encontro el PID
#   	2: Cantidad inválida de parametros

# Valido que se ingrese los parametros correcto  
if [ $# -eq 0 ]; then 
    echo "Debe ingresar al menos 1 parametro"
    exit 2
fi 

# Obtengo todos los procesos excluyendo el propio y el grep
PROCESOS=`ps ax | grep -v $$ | grep -v "grep" | grep -v -w "$2" | grep "$1"`

# Obtengo el PID (id Process)
PID=$(echo "$PROCESOS" | grep "$1" | head -n 1 | head -c 5)

# Verifico que haya encontrado el PID
if [ $(echo $PID | wc -w) -eq 0 ]; then
	exit 1
else
	echo "$PID" #Aca devuelvo el id de proceso
	exit 0
fi
