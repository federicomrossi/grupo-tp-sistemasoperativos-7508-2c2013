#! /bin/bash

#Sistemas Operativos
#Modulo Instalador
#Nombre: VerificarInstalacion.sh
#Autor: Grupo 10

# Este script se utiliza para determinar el estado de la instalacion
# Verifica que los archivos esten donde deben, segun el archivo de configuracion
# pasado por parametro
#
# Parametros: 
#	$1: comando (case sensitive)
#	$2: archivo de configuracion (path completo)
#
# comando 'MAE' -> chequea el directorio MAEDIR en busca de los archivos maestros
# comando 'BIN' -> chequea el directorio BINDIR en busca de los archivos binarios
# comando 'LOG' -> chequea que el directorio LOGDIR exista
# comando 'ARR' -> chequea que el directorio ARRIDIR exista
# comando 'REC' -> chequea que el directorio RECHDIR exista
# comando 'REP' -> chequea que el directorio REPODIR exista
# comando 'COM' -> chequea todos los anteriores. Se utliza para ver si la instalacion está completa
#
# Valor de codigo_err: 0 si el estado es correcto
#					1 si no se encuentra el archivo en su lugar
#					2 si no se encuentra el directorio
#					3 si no se encuentra el archivo de configuracion dado o es invalido
#
# Ejemplo de uso:
# VerificarInstalacion.sh MAE ./Instalacion.conf

############### FUNCIONES INTERNAS #####################################
MAE (){
	#Verificar existencia de archivos $MAEDIR/prod.mae, $MAEDIR/sucu.mae y $MAEDIR/cli.mae
	#echo "Verificando MAE"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "MAEDIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			else
				if [ ! -f "$valor/prod.mae" -o ! -f "$valor/sucu.mae" -o ! -f "$valor/cli.mae" ]
				then
					codigo_err=1
				fi
			fi
		fi

	done <$1
	
	return $codigo_err
}

BIN (){
	#Verificar existencia de archivos ejecutables
	#echo "Verificando BIN"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "BINDIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			else
				if [ ! -f "$valor/IniciarU.sh" -o ! -f "$valor/DetectarU.sh" -o ! -f "$valor/GrabarParqueU.sh" -o ! -f "$valor/ListarU.pl" -o ! -f "$valor/LoguearU.pl" -o ! -f "$valor/MirarU.pl" -o ! -f "$valor/StopD.sh" -o ! -f "$valor/StartD.sh" ]
				then
					codigo_err=1
				fi
			fi
		fi

	done <$1
	
	return $codigo_err
}

LOG (){
	#Verificar existencia de directorio de logs
	#echo "Verificando LOG"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "LOGDIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			fi
		fi

	done <$1

	return $codigo_err
}

ARR (){
	#Verificar existencia de directorio de arribos
	#echo "Verificando ARRIDIR"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "ARRIDIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			fi
		fi

	done <$1

	return $codigo_err
}

REC (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando RECDIR"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "RECHDIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			fi
		fi

	done <$1
	
	return $codigo_err
}

REP (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando REPDIR"
	codigo_err=0
	
	while IFS== read -r var valor usuario fecha
	do
		if [ "$var" == "REPODIR" ]
		then
			if [ ! -d "$valor" ]
			then 
				codigo_err=2
			fi
		fi

	done <$1
	
	return $codigo_err
}

COM () {
	echo "COM: Verificando instalacion. Archivo conf es $1"
	codigo_err=0

	MAE $1
	ec_MAE=$?
	BIN $1
	ec_BIN=$?
	LOG $1
	ec_LOG=$?
	ARR $1
	ec_ARR=$?
	REC $1
	ec_REC=$?
	REP $1
	ec_REP=$?

	if [ $ec_MAE -gt 0 -o $ec_BIN -gt 0 -o $ec_LOG -gt 0 -o $ec_ARR -gt 0 -o $ec_REC -gt 0 -o $ec_REP -gt 0 ]
	then
		codigo_err=1
	fi
	
	return $codigo_err
}

########################################################################

################# INICIO PROGRAMA ######################################
#echo "VerificarInstalacion.sh"
comando=$1
#echo "Comando: $comando"
archivo_conf=$2
#echo "Archivo config $archivo_conf"
codigo_err=0

if [ -f $archivo_conf ]
then
	#echo "Archivo conf existe"
	$comando $archivo_conf
	codigo_err=$?
else
	codigo_err=3
fi

exit $codigo_err

################# FIN PROGRAMA #########################################
