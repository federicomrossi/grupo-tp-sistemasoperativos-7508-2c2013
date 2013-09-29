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
function verificar_configuracion()
{
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
function set_variables()
{
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
function inicializar_log()
{
        #echo "BASEPATH: $BASEPATH"
        #echo "path config entero: $CONF"       
        #Inicializar el archivo de log - GRABA EN LOG
        perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Comando Iniciar_B Inicio de Ejecución', '')"
        return 0
}
function verificar_ejecucion_anterior(){

	#Verifico si todas las variables tienen valor
	if [ "$BINDIR" != "" ] 
	then
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Comando Iniciar_B Inicio de Ejecucion', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Librería del Sistema: $CONF', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls -lrt $CONF`', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de instalación de los ejecutables: $BINDIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls $BINDIR`', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de instalación de los archivos maestros: $MAEDIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls -lrt $MAEDIR`')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de arribo de archivos externos: $ARRIDIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los archivos externos rechazados: $RECHDIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los logs de auditoria: $LOGDIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los reportes de salida: $REPODIR', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'La extension de los archivos de log es: $LOGEXT', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'El tiempo de sleep del demonio es: $SLEEPTIME', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Estado del Sistema: INICIALIZADO', '')"
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'A', '0', 'No es posible efectual una reinicializacion del sistema.', '')"
		echo "TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10"
		echo ""
		echo "Librería del Sistema: $CONF"
		echo `ls -lrt $CONF`
		echo ""
		echo "Directorio de instalación de los ejecutables: $BINDIR"
		echo `ls $BINDIR`
		echo ""
		echo "Directorio de instalación de los archivos maestros: $MAEDIR"
		echo `ls -lrt $MAEDIR`
		echo ""
		echo "Directorio de arribo de archivos externos: $ARRIDIR"
		echo ""
		echo "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
		echo ""
		echo "Directorio de grabación de los logs de auditoria: $LOGDIR"
		echo ""
		echo "Directorio de grabación de los reportes de salida: $REPODIR"
		echo ""
		echo "La extension de los archivos de log es: $LOGEXT"
		echo ""
		echo "El tiempo de sleep del demonio es: $SLEEPTIME"
		echo ""
		echo "Estado del Sistema: INICIALIZADO"
		echo ""
		echo "No es posible efectual una reinicializacion del sistema."
		return 1
	else
		return 0
	fi
	return 0
}
function verificar_instalacion(){
	VERIFICADIR="${BINDIR}/VerificarInstalacion.sh"
	${VERIFICADIR} COM ${CONF}
	if [ $? -eq 0 ]
	then
		#Si Iniciar_B ya fué ejecutado (por cada sesión de usuario) ir al paso FINAL - GRABA EN LOG
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10', '')"
		echo "TP SO7508 2do cuatrimestre 2013. Tema B Copyright © Grupo 10"
		echo ""
		echo "Componentes Existentes:"
		echo ""
		if [ -n "$BINDIR" -a -d "$BINDIR" ]
		then
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de instalación de los ejecutables: $BINDIR', '')"
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls $BINDIR`', '')"
			echo "Directorio de instalación de los ejecutables: $BINDIR"
			echo `ls $BINDIR`
			echo ""
		else
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'SE', '0', 'El directorio bindir: $BINDIR no existe', '')"
			echo "El directorio bindir: $BINDIR no existe"
			return 1
		fi
		if [ -n "$MAEDIR" -a -d "$MAEDIR" ]
		then
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de instalación de los archivos maestros: $MAEDIR', '')"
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls -lrt $MAEDIR`')"
			echo "Directorio de instalación de los archivos maestros: $MAEDIR"
			echo `ls -lrt $MAEDIR`
			echo ""
		else
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'SE', '0', 'El directorio maedir: $MAEDIR no existe', '')"
			echo "El directorio maedir: $MAEDIR no existe"
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
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'SE', '0', 'Componentes faltantes: $FALTANTES', '')"
			perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'SE', '0', 'Estado del Sistema: PENDIENTE DE INSTALACIÓN', '')"
			echo "Componentes faltantes: $FALTANTES"
			echo "Estado del Sistema: PENDIENTE DE INSTALACIÓN"
			return 1
		fi
	
	fi
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Librería del Sistema: $CONF', '')"
	echo "Librería del Sistema: $CONF"
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', '`ls -lrt $CONF`', '')"
	echo `ls -lrt $CONF`
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de arribo de archivos externos: $ARRIDIR', '')"
	echo "Directorio de arribo de archivos externos: $ARRIDIR"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los archivos externos rechazados: $RECHDIR', '')"
	echo "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los logs de auditoria: $LOGDIR', '')" 
	echo "Directorio de grabación de los logs de auditoria: $LOGDIR"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Directorio de grabación de los reportes de salida: $REPODIR', '')" 
	echo "Directorio de grabación de los reportes de salida: $REPODIR"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'La extension de los archivos de log es: $LOGEXT', '')" 
	echo "La extension de los archivos de log es: $LOGEXT"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'El tiempo de sleep del demonio es: $SLEEPTIME', '')" 
	echo "El tiempo de sleep del demonio es: $SLEEPTIME"
	echo ""
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Estado del Sistema: INICIALIZADO', '')" 
	echo "Estado del Sistema: INICIALIZADO"
	return 0
}

function set_path()
{
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
	#Siempre que Recibir_B.sh no este ejecutando, lanzar. Verificar con comando ps - GRABA EN LOG
	#Sino - GRABA EN LOG
	q=`ps r -ef | grep -v grep | grep '[.]/Recibir_B.sh' | wc -l`
	if [ $q -eq 0 ]
	then
		#echo "Puedo lanzar ./Recibir_B.sh"
		./Recibir_B.sh &
		LASTPID=$!
		perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Demonio corriendo bajo el proceso Nro.: ${LASTPID}', '')"
		echo "Demonio corriendo bajo el proceso Nro.: ${LASTPID}"
	fi
	return 0
}
########################MAIN########################
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
	inicializar_log
	if [ $? -eq 0 ]
	then
		#echo "TO-DO: inicializar_log OK!!!"
		ERRORCODE=0
	else
		#echo "TO-DO: inicializar_log ERROR!!!"
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
		#echo "TO-DO: set_path OK!!!"
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
	
	if [ Decision == "S" ]
	then
		invocar_detectar
		if [ $? -eq 0 ]
		then
			#echo "TO-DO: invocar_detectar OK!!!"
			echo "Proceso Recibir_B iniciado correctamente."
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

if [ $ERRORCODE -eq 0 ]
then
	perl -I$BINDIR/functions -Mfunctions -e "functions::LoguearU('Iniciar_B', 'I', '0', 'Proceso de Inicialización concluido', '')"
	echo "Proceso de Inicialización concluido"
	echo "Entorno inicializado correctamente"
fi
#########################FIN########################
