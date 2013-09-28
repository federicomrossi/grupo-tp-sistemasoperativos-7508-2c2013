#!/bin/bash
#Script de VlogX del TP-Grupo 9 Sistemas Operativos - FIUBA
#
#Autor: Ignacio Mazzara 92459


#De Ambiente 
LOGIFS="-"
if [ -z "$LOGDIR" ]; then
	LOGDIR="logdir"
fi;
if [ -z $CONFDIR ]; then
	CONFDIR="conf"
fi;
if [ -z $LOGEXT ]; then
	LOGEXT=".log"
fi;

#Locales
INSTAL="InstalX"
_LOGFILE=
_LOGCOM=
_SHOW=
############################################################
###################   FUNCIONES   ##########################

#
# Escribe en el log correspondiente el nuevo registro
# Params:
#		$1 CANTDELOGS:
#			Cantidad de logs a mostrar. Empezando desde el final
#		$2 FILTRO:
#			Filtro de string por el cual van a mostrarse solo esos logs
#
mostrarLogs()
{
	CANTDELOGS=$1;
	FILTRO=$2;
	if  [ "$FILTRO" = "" ]  
	then
		cat "$_LOGFILE" | tail -n $CANTDELOGS |awk -F '-' 'BEGIN { print "Fecha                User     Comando         Tipo      Comentario"}
										{ printf "%-20s %-10s %-10s %4s %s\n",$1,$2 ,$3,$4,$5}'
	fi
	if [ "$FILTRO" != "" ]
	then
		grep "$FILTRO" "$_LOGFILE" | tail -n $CANTDELOGS |awk -F '-' 'BEGIN { print "Fecha                User     Comando         Tipo      Comentario"}
											{ printf "%-20s %-10s %-10s %4s %s\n",$1,$2 ,$3,$4,$5}'
	fi
	exit 0;

}

#
# Verifica que el argumento pasado corresponda a uno de 
# los tipos existentes
# Params:
#		$1 TIPO:
#			Valores Posibles: I (info),A (alerta),
#								E (error),SE(error severo)
# Si no es uno de ellos, se produce un error y se termina 
# la ejecucion.
#
verificarNumero()
{
	CANTDELOGS=$1;
	if [ $CANTDELOGS -le "0" ]; then
		echo "La cantidad de logs a mostrar tiene que ser un numero mayor a 0";
      	exit 1;	
	fi;
}


#
# Muesta el siguiente help del script:
#-----------------------------------------------------------------
#VlogX: muestra los logs de un determinado archivo de log.
#
#
#Opciones y Parametros:	Los argumentos son obligatorios
#Obligatorios:
#	-c [comando]
#		Nombre del archivo de log.
#	-n [mensaje]
#		Cantidad que sirve para indicar que se quieren ver las ultimas n líneas.
#	
#Opcionales:
#	-f [filtro]
#		Solo se muestren las líneas que contienen el string ingresado.
#	-h
#		Muestra la ayuda.
#
verAyuda()
{
	echo "Uso: VlogX [opciones] [pars]";
	echo "VlogX: Muestra los logs guardados previamente
";
	echo "Opciones y Parametros:	Los argumentos son obligatorios";
	echo "Obligatorios:";	
	echo "	-c [comando]
		Nombre del archivo de log.";
	echo "	-n [comando]
		Cantidad que sirve para indicar que se quieren ver las ultimas n lineas. ";
	echo "Opcionales:";
	echo "	-f [filtro]
		Solo se muestren las lineas que contienen el string ingresado.";
	echo "	-h
		Muestra la ayuda.";
	exit 0;
}

#############################################################
#######################    SCRIPT    ########################

_SHOW=""
# Procesamiento de parÃ¡metros
while getopts 'c:n:f:m:h' OPCION; do
	case $OPCION in
		c)
			_LOGCOM="$OPTARG";
			;;
		n)
			_LOGULT="$OPTARG";
			;;
		f)
			LOGSTR="$OPTARG";
			;;
		h)
			verAyuda;
			;;
	esac;
done
_LOGFILE="$GRUPO$LOGDIR/$_LOGCOM$LOGEXT"

if [ -z "$_LOGCOM" ]; then
	echo "Falta parametro obligatorio -c. Para ver ayuda: VlogX -h" 1>&2;
	exit 1;
fi

if [ -z "$_LOGULT" ]; then
	echo "Falta parametro obligatorio -n. Para ver ayuda: VlogX -h" 1>&2;
	exit 1;
fi

verificarNumero $_LOGULT;

if  [ "$_LOGCOM" == "$INSTAL" ]; then
	#Verifico si existe el directorio $CONFDIR
	if [ ! -d "$GRUPO$CONFDIR" ]; then
		echo "No existe el directorio CONFDIR" 1>&2;
		exit 1;
	fi;
	_LOGFILE="$GRUPO$CONFDIR/$_LOGCOM$LOGEXT";
fi

if  [ "$_LOGCOM" != "$INSTAL" ]; then
	#Verifico si existe el directorio $LOGDIR
	if [ ! -d "$GRUPO$LOGDIR" ]; then
		echo "No existe el directorio LOGDIR" 1>&2;
		exit 1;
	fi;
fi

#Verifico si existe el archivo de log
if [ ! -f "$_LOGFILE" ]; then
	echo "El archivo de log ingresado no existe." 1>&2;
	exit 1;
fi;

mostrarLogs "$_LOGULT" "$LOGSTR";

