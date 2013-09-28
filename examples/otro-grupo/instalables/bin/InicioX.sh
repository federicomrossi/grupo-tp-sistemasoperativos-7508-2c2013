#!/bin/bash

#***************************************************************
# v0.0.1
# Comando para la verificacion de la instalacion
# e inicializacion de las variables de entorno necesarias para
# el correcto funcionamiento del programa.
# 
# INPUT: 
#          CONFIGFILE = ../conf/InstalX.conf 
# OUTPUT:
#          CODERROR = 0 -> Finalizacion satisfactoria
#          CODERROR = 1 -> No existe el archivo de configuracion
#          CODERROR = 2 -> Falta/n directorio/s principales
#          CODERROR = 3 -> Falta/n archivo/s principales
#****************************************************************

#CONSTANTES 
VERIFICAR_AMBIENTE=1
PARSER_CONFIG=${VERIFICAR_AMBIENTE}+1
SETEAR_AMBIENTE=${PARSER_CONFIG}+1
VALIDAR_INSTALACION=${SETEAR_AMBIENTE}+1
SETEAR_VARIABLES_DETECTA=${VALIDAR_INSTALACION}+1
INICIAR_DETECTA=${SETEAR_VARIABLES_DETECTA}+1
PRINT_ESTADO=${INICIAR_DETECTA}+1
FIN=${PRINT_ESTADO}+1

CONFIGFILE="../conf/InstalX.conf"


#VARIABLE DE ESTADO
ESTADO=${VERIFICAR_AMBIENTE} 

#CONDICION DE CORTE DEL LOOP
EXIT=false

#VALOR DE RETORNO
CODERROR=0

#VALORES A EXTRAER DEL CONFIGFILE
BIND=""
MAED=""
ARRI=""
RECH=""
ACEP=""
PROC=""
REPO=""
LOGD=""
LOGE=""
LOGS=""
DATS=""


#****************************************************************
#def: logear mediante el comando GlogX en el archivo InicioX.log
#input: 
# 		param1 = mensaje a logear
#		param2 = tipo de mensaje 
#****************************************************************
function Logear {
	declare -a mensaje=$2
	declare -a tipo=$1

	./GlogX.sh -c "InicioX" -t "$tipo" -m "$mensaje"
}

#****************************************************************
#def: setea un permiso a un directorio.
#input: 
# 	param1 = permiso r, w, o x
#       param2 = nombre del directorio
#****************************************************************
function SetearPermisoDirectorio {
	declare -a permiso=$1
	declare -a directorio=$2

	if [ ! -$permiso "${directorio}" ]; then
		chmod +$permiso "${directorio}" 
		
	fi

}

#****************************************************************
#def: recorre una lista de nombre de archivos y les setea a todos
#     el permiso.
#input: 
# 	param1 = permiso r, w, o x
#       param2 = nombre del directorio
#       param3 = vector de nombre de archivos
#****************************************************************
function SetearPermisoArchivo {
	declare -a permiso=$1
	declare -a directorio=$2
	declare -a archivos=("${!3}")

	for file in "${archivos[@]}"
	do
		if [ ! -$permiso "${directorio}/${file}" ]; then
			chmod +$permiso "${directorio}/${file}" 
		fi
	done
}

#****************************************************************
#def: verifica la existencia de un archivo
#input: 
# 		param1 = nombre del archivo
#ouput:
#       0 si no existe
#       1 si existe
#****************************************************************
function ExisteArchivo {
	declare -a arch=$1
	if [ ! -e "${arch}" ]; then
		echo "El archivo ${arch} no existe"
		return 0
	fi
	return 1
}

#****************************************************************
#def: verifica la existencia de un directorio y le setea los
#     permisos de ejecucion.
#input: 
# 		param1 = nombre del directorio
#ouput:
#       0 si no existe
#       1 si existe
#****************************************************************
function ExisteDirectorio {
	declare -a direct=$1
	if [ ! -d "${direct}" ]; then
		echo "El directorio ${direct} no existe."
		return 0
	else
		SetearPermisoDirectorio "x" "${direct}"
	fi
	return 1
}

#****************************************************************
#def: recorre una lista de nombre de archivos verificando que 
#     existan.
#input: 
# 		param1 = nombre del directorio
#       param2 = vector de nombre de archivos a buscar
#ouput:
#       0 si no existe alguno de ellos
#       1 si existen todos
#****************************************************************
function ExistenArchivos {
	declare -a directorio=$1
	declare -a archivos=("${!2}")
	for file in "${archivos[@]}"
	do
		ExisteArchivo "${directorio}/${file}"
		result=$?
		if [ $result -eq 0 ]; then
			return 0
		fi
	done
	return 1
}

#****************************************************************
#def: recorre una lista de nombre de directorios verificando que 
#     existan.
#input: 
# 		param1 = nombre del directorio
#ouput:
#       0 si no existe alguno de ellos
#       1 si existen todos
#****************************************************************
function ExistenDirectorios {
	declare -a directorios=("${!1}")

	for directorio in "${directorios[@]}"
	do
		ExisteDirectorio "${directorio}"
		result=$?
		if [ $result -eq 0 ]; then
			return 0
		fi
	done
	return 1
}


#****************************************************************
#def: busca una cadena dentro de otra.
#input: 
# 		param1 = string
#       param2 = substring a buscar
#output:
#		0 si no la encuentra
#		1 si la encuentra
#****************************************************************
function FindSubstring {
	string="$1"
	substring="$2"
	found=`echo "$string" | grep "$substring"`
	if [ -z "$found" ]; then
		return 0
	fi
	return 1
}

#****************************************************************
#def: busca en el archivo de configuracion el valor de algun campo
#     correspondiente a un determinado registro.
#input: 
# 		param1 = nombre del registro (ej. GRUPO)
#       param2 = numero de campo (ej. 2) 
#output:
#		valor encontrado (ej. "/home/usuario/grupo09"
#****************************************************************
function FindValueConfig {
	declare -a reg=$1
	declare -a field=$2
	grep $reg "${CONFIGFILE}" | awk ' BEGIN {FS="="}; { print $'$field' };'
}

function printAmbiente { 
	echo "VARIABLES DE AMBIENTE EXISTENTES:";
	echo "   AMBINIT = $AMBINIT"
    echo "   GRUPO = $GRUPO"
    echo "   CONFDIR = $CONFDIR"
    echo "   BINDIR = $BINDIR"
    echo "   MAEDIR = $MAEDIR"
	echo "   ARRIDIR = $ARRIDIR"
    echo "   RECHDIRIR = $RECHDIR"
    echo "   ACEPDIR = $ACEPDIR"
    echo "   PROCDIR = $PROCDIR"
    echo "   LOGDIR = $LOGDIR"
	echo "   LOGSIZE = $LOGSIZE"
	echo "   LOGEXT = $LOGEXT"
	echo "   DATASIZE = $DATASIZE"
	echo "   PATH = $PATH"
}

#****************************************************************
#def: verifica si el ambiente fue seteado.
#     si fue seteado se valida la instalacion, sino se buscan
#     las variables de entorno para setearlas.
#****************************************************************
function VerificarAmbiente {
 	if [ -z $AMBINIT ]; then
		ESTADO=${PARSER_CONFIG}
	else
		ESTADO=${VALIDAR_INSTALACION}
	fi
}

#****************************************************************
#def: Busca en el archivo de configuracion los valores de las 
#     variables de entorno a setear.
#pos: Si el archivo de configuracion no existe finaliza con:  
#          ESTADO=FIN 
#          CODERROR=1
#	  Si todo esta bien: 
#          ESTADO=SETEAR_AMBIENTE
#****************************************************************
function ParserConfig {
	ExisteArchivo "${CONFIGFILE}" 
	result=$?
	if [ $result -eq 0 ]; then
		echo "No se encuentra el archivo de configuracion."
		echo "Debe reinstalar el programa."
		CODERROR=1
		ESTADO=${FIN}
		return
	fi

	GRUP=$(FindValueConfig "GRUPO" 2)
	#CONF=$(FindValueConfig "CONFDIR" 2)
	CONF=conf  # Es fijo porque el instalador lo crea asi
	BIND=$(FindValueConfig "BINDIR" 2)
	MAED=$(FindValueConfig "MAEDIR" 2)
	ARRI=$(FindValueConfig "ARRIDIR" 2)
	RECH=$(FindValueConfig "RECHDIR" 2)
	ACEP=$(FindValueConfig "ACEPDIR" 2)
	PROC=$(FindValueConfig "PROCDIR" 2)
	REPO=$(FindValueConfig "REPODIR" 2)
	LOGD=$(FindValueConfig "LOGDIR" 2)
	LOGE=$(FindValueConfig "LOGEXT" 2)
	LOGS=$(FindValueConfig "LOGSIZE" 2)
	DATS=$(FindValueConfig "DATASIZE" 2)
	ESTADO=${SETEAR_AMBIENTE}
}

#****************************************************************
#def: Setea el entorno.
#pos: Si no existe algun directorio  
#          ESTADO=FIN 
#          CODERROR=3
#	  Si todo esta bien: 
#          ESTADO=VALIDAR_INSTALACION
#****************************************************************
function SetearAmbiente {
	local ok=true
	local directorios=("$GRUP" "${GRUP}${CONF}" "${GRUP}${BIND}" "${GRUP}${MAED}" "${GRUP}${ARRI}" )

	ExistenDirectorios directorios[@]
	result=$?
	if [ $result -eq 0 ]; then
		ok=false
	fi

	if ($ok); then
		AMBINIT=1
		GRUPO=${GRUP}
		CONFDIR=${CONF}
		BINDIR=${BIND}
		MAEDIR=${MAED}
		ARRIDIR=${ARRI}
		RECHDIR=${RECH}
		ACEPDIR=${ACEP}
		PROCDIR=${PROC}
		REPODIR=${REPO}
		LOGDIR=${LOGD}
		LOGEXT=${LOGE}
		LOGSIZE=${LOGS}
		DATASIZE=${DATS}
		export AMBINIT GRUPO CONFDIR BINDIR MAEDIR ARRIDIR RECHDIR ACEPDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE DATASIZE
		ESTADO=${VALIDAR_INSTALACION}
	else
		echo "No se pudieron setear las variables de ambiente. Falta/n directorio/s"
		echo "Debe reinstalar el programa."
		CODERROR=2
		ESTADO=${FIN}
	fi
}

#****************************************************************
#def: Valida que existan los archivos de configuracion, los comandos
#	  y los archivos maestros. 
#pre: Las variables de ambiente fueron seteadas correctamente.
#pos: Si alguno no existe finaliza con:  
#          ESTADO=FIN 
#          CODERROR=3
#	  Si todo esta bien: 
#          ESTADO=SETEAR_VARIABLES_DETECTA
#****************************************************************
function ValidarInstalacion {
	## COMANDOS
	local GETPID="getPID.sh" 
	local INICIOX="InicioX.sh"
	local DETECTAX="DetectaX.sh"
	local INTERPRETE="Interprete.sh"
	local REPORTEX="ReporteX.pl" 
	local MOVERX="MoverX.sh" 
	local GLOGX="GlogX.sh"
	local VLOGX="VlogX.sh"
	local STARTX="StartX.sh"
	local STOPX="StopX.sh"
	## ARCHIVOS DE CONFIGURACION
	local PSMAE="p-s.mae" 
	local PPIMAE="PPI.mae"
	local INSTALCONF="InstalX.conf" 
	## ARCHIVOS MAESTROS
	local T1="T1.tab" 
	local T2="T2.tab"
	
	local ok=true
	local result

	local comandos=($GETPID $INICIOX $DETECTAX $INTERPRETE $REPORTEX $MOVERX $GLOGX $VLOGX $STARTX $STOPX)
	local maestros=($PSMAE $PPIMAE)
	local config=($INSTALCONF $T1 $T2)

	ExistenArchivos "${GRUPO}${BINDIR}" comandos[@]
	result=$?
	if [ $result -eq 0 ]; then
		ok=false
	fi
	ExistenArchivos "${GRUPO}${MAEDIR}" maestros[@]
	result=$?
	if [ $result -eq 0 ]; then
		ok=false
	fi
	ExistenArchivos "${GRUPO}${CONFDIR}" config[@]
	result=$?
	if [ $result -eq 0 ]; then
		ok=false
	fi

	if ($ok); then
		SetearPermisoDirectorio "w" "${GRUPO}"
		SetearPermisoDirectorio "r" "${GRUPO}"
		SetearPermisoDirectorio "w" "${GRUPO}${BINDIR}"
		SetearPermisoDirectorio "r" "${GRUPO}${BINDIR}"
		SetearPermisoDirectorio "r" "${GRUPO}${MAEDIR}"
		SetearPermisoDirectorio "w" "${GRUPO}${CONFDIR}"
		SetearPermisoDirectorio "r" "${GRUPO}${CONFDIR}"
		SetearPermisoArchivo "r" "${GRUPO}${BINDIR}" comandos[@]
		SetearPermisoArchivo "w" "${GRUPO}${BINDIR}" comandos[@]
		SetearPermisoArchivo "r" "${GRUPO}${BINDIR}" comandos[@]
		SetearPermisoArchivo "x" "${GRUPO}${BINDIR}" comandos[@]
		SetearPermisoArchivo "r" "${GRUPO}${MAEDIR}" maestros[@]
		SetearPermisoArchivo "r" "${GRUPO}${CONFDIR}" config[@]
		FindSubstring "$PATH" "${GRUPO}${BINDIR}" 
		result=$?
		if [ $result -eq 0 ]; then
			PATH="$PATH:$GRUPO$BINDIR"
			export PATH
		fi
	fi



	if ($ok); then
		ESTADO=${SETEAR_VARIABLES_DETECTA}
	else
		echo "Ocurrio un error al validar la instalacion."
		echo "Debe reinstalar el programa."
		CODERROR=3
		ESTADO=${FIN}
	fi
	
}

#****************************************************************
#def: se encarga de setear las variables necesarias para el 
#	  funcionamiento del comando DetectaX.sh. 
#     Si el demonio se encuentra corriendo se ofrece al usuario
#     detenerlo para poder volver a setar las variables.
#pre: Las variables de ambiente fueron seteadas correctamente.
#****************************************************************
function SetearVariablesDetecta {

	Logear "I" "Comando InicioX Inicio de Ejecucion"

	local answer=""
	PID=$(getPID.sh "DetectaX.sh" "$$")
	if [ ! -z $PID ]; then 
		Logear "I" "Demonio DetectaX corriendo bajo el no.: $PID" 
		while [ -z $answer ]
		do
			echo "Ya existe una instancia del demonio DetectaX corriendo. Desea detenerla? (Si-No)"
			read -e answer
			answer=$( echo $answer | grep '^[Ss][Ii]$\|^[Nn][Oo]$' );
		done
		answer=$(echo $answer | sed 's/^[Ss][Ii]$/si/');
		if [ $answer == "si" ]; then
			StopX.sh "DetectaX.sh" 
			Logear "I" "El Demonio DetectaX fue detenido por el usuario."
		else
			ESTADO=${PRINT_ESTADO}
			return
		fi
	fi
	local OLDCANLOOP=$CANLOOP
	local OLDTESPERA=$TESPERA
	answer=""

	if [ -z $OLDCANLOOP ]; then
		OLDCANLOOP=100
	fi
	if [ -z $OLDTESPERA ]; then
		OLDTESPERA=1
	fi
	while [ -z $answer ]
	do
		read -p "Cantidad de Ciclos de DetectaX ? ($OLDCANLOOP ciclos) " answer; 
		answer=$( echo $answer | grep '^[1-9]$\|^[1-9][0-9]*$' );
	done
	CANLOOP=$answer 
	export CANLOOP

	local answer=""
	while [ -z $answer ]
	do
		read -p "Tiempo de espera entre ciclos ? ($OLDTESPERA minutos) " answer; 
		answer=$( echo $answer | grep '^[1-9]$\|^[1-9][0-9]*$' );
	done
	TESPERA=$answer 
	export TESPERA

	Logear "I" "Fueron seteadas las variables de entorno CANLOOP=${CANLOOP} y TESTPERA=${TESPERA}."
	
	ESTADO=${INICIAR_DETECTA}
}

#****************************************************************
#def: ofrece al usuario arrancar el DetectaX.sh
#pre: Las variables de ambiente fueron seteadas correctamente.
#****************************************************************
function IniciarDetecta {
	local RESPUESTA=""
	while [ -z $RESPUESTA ]
	do
		echo "Correr DetectaX.sh? (Si-No)"
	    read -e RESPUESTA
		RESPUESTA=$( echo $RESPUESTA | grep '^[Ss][Ii]$\|^[Nn][Oo]$' );
	done
	RESPUESTA=$(echo $RESPUESTA | sed 's/^[Ss][Ii]$/si/');
	if [ $RESPUESTA == "si" ]; then
		StartX.sh "DetectaX.sh" 
	fi 
	ESTADO=${PRINT_ESTADO}
}

#****************************************************************
#def: Imprime por pantalla el estado de los directorios al 
#	  finalizar el comando.
# 	  En caso de que el DetectaX este corriendo se imprime 
#     su numero de proceso.
#     Imprime en el archivo log un mensaje indicando que se 
#     finalizo correctamente y si esta corriendo DetectaX tambien
#     registra bajo el numero de proceso que esta corriendo.
#****************************************************************
function PrintEstado {
	clear
	echo "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 09"
	echo Librería del Sistema: $GRUPO$CONFDIR
 	ls $GRUPO$CONFDIR
   	echo Ejecutables: $GRUPO$BINDIR
	ls $GRUPO$BINDIR
	echo Archivos maestros: $GRUPO$MAEDIR
	ls $GRUPO$MAEDIR
	echo Directorio de arribo de archivos externos: $GRUPO$ARRIDIR
	echo Archivos externos aceptados: $GRUPO$ACEPDIR
	echo Archivos externos rechazados: $GRUPO$RECHDIR
	echo Archivos procesados: $GRUPO$PROCDIR
	echo Reportes de salida: $GRUPO$REPODIR
	echo Logs de auditoría del Sistema: $GRUPO$LOGDIR"/InicioX"$LOGEXT
	echo Estado del Sistema: INICIALIZADO
	PID=$(getPID.sh "DetectaX.sh" $$)
	if [ -n "$PID" ]; then 
		echo Demonio DetectaX corriendo bajo el no.: $PID
		Logear "I" "Demonio DetectaX corriendo bajo el no.: $PID" 
	fi
	Logear "I" "Comando InicioX.sh Fin de Ejecucion" 
	ESTADO=${FIN}
}

#****************************************************************
#def: estado de finalizacion -> EXIT=true -> sale del while
#****************************************************************
function Fin {
	EXIT=true
}


while (! ${EXIT} ) 
do 
	case ${ESTADO} in
	  	${VERIFICAR_AMBIENTE})
	    VerificarAmbiente
		;;
		${PARSER_CONFIG})
		ParserConfig
		;;
	  	${SETEAR_AMBIENTE})
		SetearAmbiente
		;;
		${VALIDAR_INSTALACION})
		ValidarInstalacion
		;;
	  	${SETEAR_VARIABLES_DETECTA})
	    SetearVariablesDetecta
		;;
	  	${INICIAR_DETECTA})
	    IniciarDetecta
		;;
	  	${PRINT_ESTADO})
	    PrintEstado
		;;
		${FIN})
		Fin
		;;
		*)
		Fin
	esac
done 

return $CODERROR
