#!/bin/bash
# PURPOSE:	Preparar el entorno de ejecución del TP (ambiente)

#APP_PATH="$PWD/trunk" 

#FILE="archivo.log"
MSG_TYPE="Test"
MSG_NUM=0
MSG_TEXT="Mensaje de Log"
########################VARIABLES########################
CONFDIR="/confdir/Instalar_TP.conf"
BASEPATH=`echo $PWD | grep -o '.*grupo10'` 
CONF="${BASEPATH}${CONFDIR}"
ERRORCODE=0
########################FUNCTIONS########################
function verificar_configuracion(){
	if [ -f "$PROCDIR/reservas.ok" ]; then
		rm "$PROCDIR/reservas.ok"
	fi
	if [ -f "$PROCDIR/reservas.nok" ]; then
		rm "$PROCDIR/reservas.nok"
	fi

    #chequea si el archivo de configuración existe
    #CONF="./${CONFDIR}/${CONFFILE}"
    #El nombre del archivo de configuración es: $CONF
    if [ ! -f $CONF ]
    then
		echo "Error: el archivo de configuración no existe (no se puede loggear)"
		return 1
    fi
    #Si se detecta algún problema en la instalación, explicar la situación y terminar la ejecución - Identificar componentes faltantes (leer instalación) - GRABA EN LOG
    #Si no se detecta problemas, seguir
    #echo "Verificar si la instalación está completa"
    return 0
}
function verificar_ejecucion_anterior(){

	if [ "$BINDIR" != "" ] 
	then
		log "I" "Comando Iniciar_B Inicio de Ejecucion"
		log "I" "TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10"
		log "I" "Librería del Sistema: $CONF"
		log "I" "`ls -lrt $CONF`"
		log "I" "Directorio de instalación de los ejecutables: $BINDIR"
		log "I" "`ls $BINDIR`"
		log "I" "Directorio de instalación de los archivos maestros: $MAEDIR"
		log "I" "`ls -lrt $MAEDIR`"
		log "I" "Directorio de arribo de archivos externos: $ARRIDIR"
		log "I" "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
		log "I" "Directorio de grabación de los logs de auditoria: $LOGDIR"
		log "I" "Directorio de grabación de los reportes de salida: $REPODIR"
		log "I" "La extension de los archivos de log es: $LOGEXT"
		log "I" "El tiempo de sleep del demonio es: $SLEEPTIME"
		log "I" "Estado del Sistema: INICIALIZADO"
		log "A" "No es posible efectual una reinicializacion del sistema."
		return 1
	else
		return 0
	fi
	return 0
}
function set_variables(){
		#echo "Seteo de todas las variables en el archivo config"
        #export GRUPO="./grupo10"
        #export LOGSIZE=1024
        #export DATASIZE=100000
	while read LINE; do
		#echo "$LINE"

		VARIABLE=`echo $LINE | cut -d '=' -f '1'`
		VALOR=`echo $LINE | cut -d '=' -f '2'`
		if [[ $LINE != "" ]];
		then
			 export $VARIABLE="$VALOR"
		fi
	done<$CONF
	FILE="${LOGDIR}/archivo${LOGEXT}"
    return 0
}
function log (){
	echo "$2"

	perl -I$BINDIR -Mfunctions -e "functions::Grabar_L('Iniciar_B', '$1', '$2')"
	return 0	
}
function verificar_instalacion(){
	VERIFICADIR="${BINDIR}/VerificarInstalacion.sh"
	${VERIFICADIR} COM ${CONF}
	if [ $? -eq 0 ]
	then
		#Si Iniciar_B ya fué ejecutado (por cada sesión de usuario) ir al paso FINAL - GRABA EN LOG
		log "I" "TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10"
		echo "Componentes Existentes:"
		echo ""
		if [ -n "$BINDIR" -a -d "$BINDIR" ]
		then
			log "I" "Directorio de instalación de los ejecutables: $BINDIR"
			log "I" "`ls $BINDIR`"
			echo ""
		else
			log "SE" "El directorio bindir: $BINDIR no existe"
			return 1
		fi
		if [ -n "$MAEDIR" -a -d "$MAEDIR" ]
		then
			log "I" "Directorio de instalación de los archivos maestros: $MAEDIR"
			log "I" "`ls -lrt $MAEDIR`"
			echo ""
		else
			log "SE" "El directorio maedir: $MAEDIR no existe"
			return 1
		fi
		#TO-DO: armar lista de pendientes
		#FALTANTES=""
		${VERIFICADIR} MAE ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES MAEDIR "
		fi
		${VERIFICADIR} BIN ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES BINDIR "
		fi
		${VERIFICADIR} LOG ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES LOGDIR "
		fi
		${VERIFICADIR} ARR ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES ARRIDIR "
		fi
		${VERIFICADIR} REC ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES RECDIR "
		fi
		${VERIFICADIR} REP ${CONF}
		if [ $? -gt 0 ]
		then
			FALTANTES="$FALTANTES REPDIR "
		fi
		
		if [ -n "$FALTANTES" ]
		then
			log "SE" "Componentes faltantes: $FALTANTES"
			log "SE" "Estado del Sistema: PENDIENTE DE INSTALACIÓN"
			return 1
		fi
	
	fi
	log "I" "Librería del Sistema: $CONF"
	log "I" "`ls -lrt $CONF`"
	log "I" "Directorio de arribo de archivos externos: $ARRIDIR"
	log "I" "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
	log "I" "Directorio de grabación de los logs de auditoria: $LOGDIR"
	log "I" "Directorio de grabación de los reportes de salida: $REPODIR"
	log "I" "La extension de los archivos de log es: $LOGEXT"
	log "I" "El tiempo de sleep del demonio es: $SLEEPTIME"
	log "I" "Estado del Sistema: INICIALIZADO"
	return 0
}
function set_path(){
	if [ -n "$BINDIR" ]
	then
		if [ ! `echo $PATH | grep $BINDIR` ]
		then
			export PATH=$PATH:$BINDIR
			#echo "$BINDIR EXISTE en PATH"
		#else
			#echo "$BINDIR no existe en PATH"
		#DESCOMENTAR PARA EXPORTAR EL DIRECTORIO A LA VARIABLE PATH  
		fi
	fi
	return 0
}
function invocar_detectar(){
	Start_D.sh
	return 0
}

function otorgarPermisoEjecucion(){
    chmod -R 777 $BASEPATH
}

########################MAIN########################
otorgarPermisoEjecucion
verificar_configuracion
if [ $? -eq 0 ]
then
	#echo "TO-DO: verificar_configuracion OK!!!"
	ERRORCODE=0
else
	#echo "TO-DO: verificar_configuracion ERROR!!!"
	echo "Proceso de Inicializacion Cancelado."
	ERRORCODE=1	
fi

if [ $ERRORCODE -eq 0 ]
then
	verificar_ejecucion_anterior
	if [ $? -eq 0 ]
	then
        	#echo "verificar_ejecucion_anterior OK!!!"
        	ERRORCODE=0
	else
        	#echo "TO-DO: verificar_ejecucion_anterior ERROR!!!"
		echo "Proceso de Inicializacion Cancelado."
		ERRORCODE=1
	fi
fi

if [ $ERRORCODE -eq 0 ]
then
	set_variables
	if [ $? -eq 0 ]
	then
		#echo "TO-DO: set_variables OK!!!"
		ERRORCODE=0
	else
		#echo "TO-DO: set_variables ERROR!!!"
		ERRORCODE=1
	fi
fi

if [ $ERRORCODE -eq 0 ]
then
	verificar_instalacion
	if [ $? -eq 0 ]
	then
		#echo "TO-DO: verificar_instalacion OK!!!"
	        ERRORCODE=0
	else
		#echo "TO-DO: verificar_instalacion ERROR!!!"
		ERRORCODE=1
	fi
fi

if [ $ERRORCODE -eq 0 ]
then
	set_path
	if [ $? -eq 0 ]
	then
		log "I" "Proceso de Inicialización concluido"
		echo "Entorno inicializado correctamente"
		ERRORCODE=0
	else
		#echo "TO-DO: set_path ERROR!!!"
		ERRORCODE=1
	fi
fi
		
if [ $ERRORCODE -eq 0 ]
then
	while :
	do
		echo "Desea efectuar la activación de Recibir_B? S/N"
		read Decision
		if [ ! `echo $Decision | grep '^[SNsn]$'` == "" ] 
		then
			break
		fi
	done
	
	if [ $Decision == "S" -o $Decision == "s" ]
	then
		invocar_detectar
		var=$?
		if [ $var -eq 0 ]
		then
			#echo "TO-DO: invocar_detectar OK!!!"
			echo "Proceso Recibir_B iniciado."
			echo "Para detenerlo ejecute el comando Stop_D"
			ERRORCODE=0
		else
			#echo "TO-DO: invocar_detectar ERROR!!!"
			ERRORCODE=1
		fi
	else
		echo "Eligio no iniciar el proceso Recibir_B."
		echo "Para iniciarlo ejecute el comando Start_D"
	fi
fi

#########################FIN########################