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
# comando 'REC' -> chequea que el directorio RECHDIR exista
# comando 'REP' -> chequea que el directorio REPODIR exista
# comando 'PARQ'-> chequea que el directorio $GRUPO10/parque_instalado exista
# comando 'RECIBIDAS'-> chequea que el directorio $GRUPO10/inst_recibidas exista
# comando 'RECHAZADAS'-> chequea que el directorio $GRUPO10/inst_rechazadas exista
# comando 'PROCESADAS'-> chequea que el directorio $GRUPO10/inst_procesadas exista
# comando 'ORDENADAS'-> chequea que el directorio $GRUPO10/inst_ordenadas exista
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
				if [ ! -f "$dir/prod.mae" -o ! -f "$dir/sucu.mae" -o ! -f "$dir/cli.mae" ]
				then
					codigo_err=1
				fi
			fi
	#	fi

	#done <$1
	
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
				if [ ! -f "$dir/IniciarU.sh" -o ! -f "$dir/DetectarU.sh" -o ! -f "$dir/GrabarParqueU.sh" -o ! -f "$dir/ListarU.pl" -o ! -f "$dir/MirarU.pl" -o ! -f "$dir/StopD.sh" -o ! -f "$dir/StartD.sh" -o ! -f "$dir/functions.pm" ]
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

REC (){
	#Verificar existencia de directorio de rechazos
	#echo "Verificando RECDIR"
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
	#echo "Verificando REPDIR"
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

PARQ () {
	codigo_err=0
	dir=""
	dir=`grep "GRUPO" <$1 | cut -d "=" -f 2`
	
	if [ ! -d "$dir/parque_instalado" ]
	then 
		codigo_err=2
	fi
	
	return $codigo_err
}

RECIBIDAS () {
	codigo_err=0
	dir=""
	dir=`grep "GRUPO" <$1 | cut -d "=" -f 2`
	
	if [ ! -d "$dir/inst_recibidas" ]
	then 
		codigo_err=2
	fi
	
	return $codigo_err
}

ORDENADAS () {
	codigo_err=0
	dir=""
	dir=`grep "GRUPO" <$1 | cut -d "=" -f 2`
	
	if [ ! -d "$dir/inst_ordenadas" ]
	then 
		codigo_err=2
	fi
	
	return $codigo_err
}

PROCESADAS () {
	codigo_err=0
	dir=""
	dir=`grep "GRUPO" <$1 | cut -d "=" -f 2`
	
	if [ ! -d "$dir/inst_procesadas" ]
	then 
		codigo_err=2
	fi
	
	return $codigo_err
}

RECHAZADAS () {
	codigo_err=0
	dir=""
	dir=`grep "GRUPO" <$1 | cut -d "=" -f 2`
	
	if [ ! -d "$dir/inst_rechazadas" ]
	then 
		codigo_err=2
	fi
	
	return $codigo_err
}

COM () {
	#echo "COM: Verificando instalacion. Archivo conf es $1"
	codigo_err=0

	MAE $1 ; ec_MAE=$?
	BIN $1 ; ec_BIN=$?
	LOG $1 ; ec_LOG=$?
	ARR $1 ; ec_ARR=$?
	REC $1 ; ec_REC=$?
	REP $1 ; ec_REP=$?
	PARQ $1 ; ec_PARQ=$?
	RECIBIDAS $1 ; ec_RECI=$?
	RECHAZADAS $1 ; ec_RECH=$?
	ORDENADAS $1 ; ec_ORD=$?
	PROCESADAS $1 ; ec_PROC=$?
	
	#Separo el condicional solo por claridad
	if [ $ec_MAE -gt 0 -o $ec_BIN -gt 0 -o $ec_LOG -gt 0 -o $ec_ARR -gt 0 -o $ec_REC -gt 0 ]
	then codigo_err=1
	fi
	
	if [ $ec_REP -gt 0 -o $ec_PARQ -gt 0 -o $ec_RECI -gt 0 -o $ec_RECH -gt 0 -o $ec_ORD -gt 0 -o $ec_PROC -gt 0 ]
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
