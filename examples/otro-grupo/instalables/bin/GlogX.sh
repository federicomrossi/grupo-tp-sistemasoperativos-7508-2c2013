#!/bin/bash
#Script de GlogX del TP-Grupo 9 Sistemas Operativos - FIUBA
#
#Autor: Ignacio Mazzara 92459


#De Ambiente (a settear dsp)
LOGIFS="-"
INSTAL="InstalX"
if [ -z $LOGEXT ]; then
	LOGEXT=".log"
fi;
if [ -z $CONFDIR ]; then
	CONFDIR="conf"
fi;
if [ -z $LOGSIZE ]; then
	LOGSIZE=1048576
fi;
if [ -z "$LOGDIR" ]; then
	LOGDIR="log"
fi;

#Locales
_CODERROR="$GRUPO/bin/coderror.dat"
_LOGFILE=
_LOGTYPE=
_LOGMSG=
_LOGCOM=
_LOGTAG=
_SHOW=
############################################################
###################   FUNCIONES   ##########################

#
# Escribe en el log correspondiente el nuevo registro
# Params:
#		$1 DONDE:
#			Nombre del Comando, función o rutina en donde
#			se produce el evento que se registra en el log
#		$2 TIPO:
#			Valores Posibles: I (info),A (alerta),
#								E (error),SE(error severo)
#		$3 MENSAJE:
#			Mensaje a loguear
#
# Formato default de logueo:
# FECHA-AUTOR-DONDE-QUE-PORQUE
#
escribirLog()
{
	FECHA=$(date +%Y/%m/%d//%H:%M:%S);
	AUTOR=$(whoami);
	DONDE=$1;
	TIPO=$2;
	MENSAJE=$3;
	if [[ $MENSAJE =~ ^[0-9]+$ ]]; then
		MENSAJE=`grep "$3" "$_CODERROR"| cut -f2 -d ':'`;
	fi;
	
	if [ ! -z $_SHOW ]; then
		echo "$MENSAJE";	
	fi;
	
	echo "$FECHA$LOGIFS$AUTOR$LOGIFS$DONDE$LOGIFS$TIPO$LOGIFS$MENSAJE" >> "$_LOGFILE";
}



#
# Esta funcion borra el 50% de los registros del Log que 
# se sera escrito $$_LOGFILE. 
#
borrarLogsViejos()
{
	escribirLog $1 "I" "Log Excedido."
	LINEAS=$(wc -l "$_LOGFILE" | awk '{ print int($1/2) }');
	tail -n "$LINEAS" "$_LOGFILE" >> "${_LOGFILE}a";
	rm "$_LOGFILE";
	mv "${_LOGFILE}a" "$_LOGFILE";
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
verificarTipo()
{
	TIPO=$1;
	if [ "$TIPO" != "I" -a "$TIPO" != "A" -a "$TIPO" != "E" -a "$TIPO" != "SE" ]; then
		echo "El tipo de mensaje no es valido. Valores Posibles: I (info), A (alerta), E (error), SE(error severo)";
      	exit 1;	
	fi;
}


#
# Muesta el siguiente help del script:
#-----------------------------------------------------------------
#GlogX: Loguea en el archivo correspondiente el mensaje pasado 
#por parametro.
#
#Opciones y Parametros:	Los argumentos son obligatorios
#Obligatorios:
#	-c [comando]
#		Nombre del comando que loguea.
#	-m [mensaje]
#		Mensaje a loguear.
#	-t [tipo]
#		Tipo de mensaje a loguear:
#			+ I (informacion).
#			+ A (alerta).
#			+ E (error).
#			+ SE(error severo).
#Opcionales:
#	-e [extension]
#		Perminte cambiar la extension default de _LOGFILE.
#	-f [funcion]
#		Nombre de la funcion que loguea, en caso de omicion se toma 
#		el Comando como autor del mensaje a loguear.
#	-h
#		Muestra la ayuda.
#	-s [separador]
#		Permite definir el separador de campos. Default: '-' (guion).
#
verAyuda()
{
	echo "Uso: GlogX [opciones] [pars]";
	echo "GlogX: Loguea en el archivo correspondiente el mensaje pasado por parametro.
";
	echo "Opciones y Parametros:	Los argumentos son obligatorios";
	echo "Obligatorios:";	
	echo "	-c [comando]
		Nombre del comando que loguea.";
	echo "	-m [mensaje]
		Mensaje a loguear o codigo de error.";
	echo "	-t [tipo]
		Tipo de mensaje a loguear:
			+ I (informacion).
			+ A (alerta).
			+ E (error).
			+ SE(error severo).";
	echo "Opcionales:";
	echo "	-e [extension]
		Perminte cambiar la extension default de _LOGFILE.";
	echo "	-f [funcion]
		Nombre de la funcion que loguea, en caso de omicion se toma el Comando como autor del mensaje a loguear.";
	echo "	-h
		Muestra la ayuda.";
	echo "	-s [separador]
		Permite definir el separador de campos. Default: '-' (guion)."
	exit 0;
}

#
# Elimina los acentos y caracteres no imprimibles.
# En caso de que existan multiples caracteres de control 
# (espacio, tab, enter) seguidos, deja un espacio
#
convertirAMensajeAlfaNumerico()
{
	#_LOGMSG="$(echo $_LOGMSG|sed 's/[â� áä]/a/g')"
	_LOGMSG="$(echo $_LOGMSG|sed 's/[âáä]/a/g')"
	_LOGMSG="$(echo $_LOGMSG|sed 's/[êèéë]/e/g')"
	_LOGMSG="$(echo $_LOGMSG|sed 's/[îìíï]/i/g')"
	_LOGMSG="$(echo $_LOGMSG|sed 's/[ôòóö]/o/g')"
	_LOGMSG="$(echo $_LOGMSG|sed 's/[ûùúü]/u/g')"
	_LOGMSG="$(echo $_LOGMSG|tr -dc '[:print:]')"
}
#############################################################
#######################    SCRIPT    ########################

_SHOW=""
# Procesamiento de parámetros
while getopts 'c:e:f:m:t:sh' OPCION; do
	case $OPCION in
		c)
			_LOGCOM="$OPTARG";
			;;
		e)
			LOGEXT="$OPTARG";
			;;
		f)
			_LOGTAG="$OPTARG";
			;;
		h)
			verAyuda;
			;;
		m)
      		_LOGMSG="$OPTARG";
			;;
   		t)
    		_LOGTYPE="$OPTARG";
      		;;
		s)
			_SHOW="SI";
			;;
    	?)
      		echo "-$OPTARG no es un parametro valido." 1>&2;
      		exit 1;
      		;;
	esac;
done
_LOGFILE="$GRUPO$LOGDIR/$_LOGCOM$LOGEXT"

if [ -z "$_LOGCOM" ]; then
	echo "Falta parametro obligatorio -c. Para ver ayuda: GlogX -h" 1>&2;
	exit 1;
fi

if  [ "$_LOGCOM" == "$INSTAL" ]; then
	_LOGFILE="$GRUPO$CONFDIR/$_LOGCOM$LOGEXT";
fi

if [ -z "$_LOGTYPE" ]; then
	echo "Falta parametro obligatorio -t. Para ver ayuda: GlogX -h" 1>&2;
	exit 1;
fi

verificarTipo $_LOGTYPE;

#Verifico si existe el directorio $LOGDIR
#if [ ! -d "$GRUPO$LOGDIR" ]; then
#	mkdir "$GRUPO$LOGDIR";
#fi;

#Verifico si existe el directorio $LOGDIR
#if [ ! -d "$GRUPO$CONFDIR" ]; then
#	mkdir "$GRUPO$CONFDIR";
#fi;


#Verifico si existe el log a escribir
if [ ! -f "$_LOGFILE" ]; then
	touch "$_LOGFILE";
fi;

#Verifico el tamaño del archivo
tam=$(echo $LOGSIZE | awk '{ print int($1 * 1024) }')
if [ $(stat -c %s "$_LOGFILE") -gt $tam ] &&  [ "$_LOGCOM" != "$INSTAL" ]; then
	borrarLogsViejos "$_LOGTAG";
fi;

if [ -z $_LOGTAG ]; then
	_LOGTAG="$_LOGCOM";
fi;

convertirAMensajeAlfaNumerico;
escribirLog "$_LOGTAG" "$_LOGTYPE" "$_LOGMSG";

