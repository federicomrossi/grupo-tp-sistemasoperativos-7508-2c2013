#! /bin/bash
#Nombre: VerificarInstalacion.sh

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
# comando 'ACEP' -> chequea que el directorio ACEPDIR exista
# comando 'REC' -> chequea que el directorio RECHDIR exista
# comando 'REP' -> chequea que el directorio REPODIR exista
# comando 'PROC'-> chequea que el directorio PROCDIR exista
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
	dir=""
	dir=`grep "MAEDIR" <$1 | cut -d "=" -f 2`
	
	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "MAEDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			else
				if [ ! -f "$dir/salas.mae" -o ! -f "$dir/obras.mae" ]
				then
					codigo_err=1
				fi
			fi
	#	fi

	return $codigo_err
}

BIN (){
	#Verificar existencia de archivos ejecutables
	#echo "Verificando BIN"
	codigo_err=0
	dir=""
	dir=`grep "BINDIR" <$1 | cut -d "=" -f 2`

	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "BINDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			else
				if [ ! -f "$dir/Iniciar_B.sh" -o ! -f "$dir/Recibir_B.sh" -o ! -f "$dir/Reservar_B.sh" -o ! -f "$dir/Mover_B.pl" -o ! -f "$dir/Start_D.sh" -o ! -f "$dir/Stop_D.sh" -o ! -f "$dir/functions.pm" ]
				then
					codigo_err=1
				fi
			fi
		#fi

	#done <$1
	
	return $codigo_err
}

LOG (){
	#Verificar existencia de directorio de logs
	#echo "Verificando LOG"
	codigo_err=0
	dir=""
	dir=`grep "LOGDIR" <$1 | cut -d "=" -f 2`

	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "LOGDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1

	return $codigo_err
}

ARR (){
	#Verificar existencia de directorio de arribos
	#echo "Verificando ARRIDIR"
	codigo_err=0
	dir=""
	dir=`grep "ARRIDIR" <$1 | cut -d "=" -f 2`

	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "ARRIDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1

	return $codigo_err
}

ACEP (){
	#Verificar existencia de directorio de arribos
	#echo "Verificando ACEPDIR"
	codigo_err=0
	dir=""
	dir=`grep "ACEPDIR" <$1 | cut -d "=" -f 2`

	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "ACEPDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1

	return $codigo_err
}

REC (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando RECHDIR"
	codigo_err=0
	dir=""
	dir=`grep "RECHDIR" <$1 | cut -d "=" -f 2`
	
	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "RECHDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1
	
	return $codigo_err
}

REP (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando REPODIR"
	codigo_err=0
	dir=""
	dir=`grep "REPODIR" <$1 | cut -d "=" -f 2`
	
	
	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "REPODIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1
	
	return $codigo_err
}

PROC (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando PROCDIR"
	codigo_err=0
	dir=""
	dir=`grep "PROCDIR" <$1 | cut -d "=" -f 2`
	
	
	#while IFS== read -r var valor usuario fecha
	#do
	#	if [ "$var" == "PROCDIR" ]
	#	then
			if [ ! -d "$dir" ]
			then 
				codigo_err=2
			fi
	#	fi

	#done <$1
	
	return $codigo_err
}



COM () {
	#echo "COM: Verificando instalacion. Archivo conf es $1"
	codigo_err=0

	MAE $1 ; ec_MAE=$?
	BIN $1 ; ec_BIN=$?
	LOG $1 ; ec_LOG=$?
	ARR $1 ; ec_ARR=$?
	ACEP $1 ; ec_ACEP=$?
	REC $1 ; ec_REC=$?
	REP $1 ; ec_REP=$?
	PROC $1 ; ec_PROC=$?
	
	#Separo el condicional solo por claridad
	if [ $ec_MAE -gt 0 -o $ec_BIN -gt 0 -o $ec_LOG -gt 0 -o $ec_ARR -gt 0 -o $ec_REC -gt 0 -o $ec_ACEP -gt 0 -o $ec_REP -gt 0 -o $ec_PROC -gt 0 ]
	then codigo_err=1
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
