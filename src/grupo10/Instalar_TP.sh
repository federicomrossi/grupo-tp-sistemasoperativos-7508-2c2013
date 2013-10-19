#! /bin/bash

#Sistemas Operativos
#Modulo Instalador
#Nombre: Instalar_TP.sh
#Autor: Grupo 10

#Definicion variables y constantes
COPY_W="TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 10"
GRUPO=`pwd`
CONFDIR="$GRUPO/confdir"
TEMPBIN="$GRUPO/.tmp/bin"
log="$CONFDIR/Instalar_TP.log"
conf="$CONFDIR/Instalar_TP.conf"
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
ARRIDIR="$GRUPO/arribos"
ACEPDIR="$GRUPO/aceptados"
RECHDIR="$GRUPO/rechazados"
REPODIR="$GRUPO/listados"
PROCDIR="$GRUPO/procesados"
LOGDIR="$GRUPO/log"
LOGEXT=".log"
LOGSIZE=409600 # 400 Kbytes
DATASIZE=100
SLEEPTIME=5


log (){
	perl -I$TEMPBIN -Mfunctions -e "functions::Grabar_L('Instalar_TP', '$1', '$2', '$log')"
	echo " $2"	
}

cargar_config () {
	#Lee el archivo de conf y carga las variables
	
	if [ -f $conf ]
	then
		while IFS== read -r var valor usuario fecha
		do
			case "$var" in 
			GRUPO) GRUPO=$valor ;;
			CONFDIR) CONFDIR=$valor ;;
			ACEPDIR) ACEPDIR=$valor ;;
			PROCDIR) PROCDIR=$valor ;;
			ARRIDIR) ARRIDIR=$valor ;;
			RECHDIR) RECHDIR=$valor ;;
			BINDIR) BINDIR=$valor ;;
			MAEDIR) MAEDIR=$valor ;;
			LOGDIR) LOGDIR=$valor ;;
			REPODIR) REPODIR=$valor ;;
			LOGEXT) LOGEXT=$valor ;;
			LOGSIZE) LOGSIZE=$valor ;;
			DATASIZE) DATASIZE=$valor ;;
			SLEEPTIME) SLEEPTIME=$valor ;;
			esac
			
		done < $conf
		return 0
	else
		return 1
	fi
	
}

mensaje_instalacion_existente_incompleta () {
	./.tmp/bin/VerificarInstalacion.sh BIN $conf ; ec_BIN=$?
	./.tmp/bin/VerificarInstalacion.sh MAE $conf ; ec_MAE=$?
	./.tmp/bin/VerificarInstalacion.sh LOG $conf ; ec_LOG=$?
	./.tmp/bin/VerificarInstalacion.sh ARR $conf ; ec_ARR=$?
	./.tmp/bin/VerificarInstalacion.sh ACEP $conf ; ec_ACEP=$?
	./.tmp/bin/VerificarInstalacion.sh REC $conf ; ec_REC=$?
	./.tmp/bin/VerificarInstalacion.sh REP $conf ; ec_REP=$?
	./.tmp/bin/VerificarInstalacion.sh PROC $conf ; ec_PROC=$?

	ls_conf=`ls $CONFDIR`
	log "I" "Librería del Sistema:  $CONFDIR .Archivos: $ls_conf"

	if [ $ec_BIN == 0 ]
	then 
		log "I" "Ejecutables: $BINDIR " 
		log "I" `ls $BINDIR`
	fi

	if [ $ec_MAE == 0 ]
	then 
		log "I" "Archivos maestros: $MAEDIR"
		log "I" `ls $MAEDIR`
	fi

	if [ $ec_ARR == 0 ] ; then log "I" "Directorio de arribo de archivos externos: $ARRIDIR" ; fi
	if [ $ec_ACEP == 0 ] ; then log "I" "Archivos externos aceptados: $ACEPDIR" ; fi
	if [ $ec_REC == 0 ] ; then log "I" "Archivos externos rechazados: $RECHDIR" ;	fi
	if [ $ec_REP == 0 ] ; then log "I" "Reportes de salida: $REPODIR" ; fi
	if [ $ec_PROC == 0 ] ; then log "I" "Archivos procesados: $PROCDIR" ; fi
	if [ $ec_LOG == 0 ] ; then log  "I" "Logs de auditoría del Sistema: $LOGDIR/<comando>.$LOGEXT" ; fi	
	
		
	log "I"  "Componentes faltantes: "
	
	if [ $ec_BIN == 2 ] ; then log "I" "Directorio de instalación de los ejecutables" ; FALTA_BINDIR=2
	else
		if [ $ec_BIN == 1 ]
		then 
			log "I" "Archivos ejecutables: Iniciar_B.sh, Recibir_B.sh, Reservar_B.sh, Mover_B.pl, Start_D.sh, Stop_D.sh, functions.pm"
			FALTA_BINDIR=1
		fi
	fi

	if [ $ec_MAE == 2 ] ; then log "I" "Directorio de instalación de los archivos maestros" ; FALTA_MAEDIR=2 
	else
		if [ $ec_MAE == 1 ] ; then log "I" "Archivos maestros: salas.mae, obras.mae" ; FALTA_MAEDIR=1 ; fi
	fi

	if [ $ec_ARR == 2 ] ; then log "I" "Directorio de arribo de archivos externos" ; FALTA_ARRIDIR=2 ; fi
	if [ $ec_ACEP == 2 ] ; then log "I" "Archivos externos aceptados" ; FALTA_ACEPDIR=2 ; fi
	if [ $ec_REC == 2 ] ; then log "I" "Archivos externos rechazados" ; FALTA_RECDIR=2 ; fi
	if [ $ec_REP == 2 ] ; then log "I" "Reportes de salida" ; FALTA_REPDIR=2 ; fi
	if [ $ec_PROC == 2 ] ; then log "I" "Archivos procesados" ; FALTA_PROC=2 ; fi
	if [ $ec_LOG == 2 ] ; then log "I" "Logs de auditoría del Sistema" ; FALTA_LOGDIR=2 ; fi
}

leer_opcion_si_no () {
	#Le pide al usuario que ingrese si o no validando la entrada
	#Recibe por parametro que se usa como mensaje para el usuario
	#Devuelve 1 si la eleccion fue si; 0 si fue no
	opcion_valida=0
	while true
	do
		read -p "$1" opcion
		opcion_lower=`echo "$opcion" | tr [:upper:] [:lower:]` #Pasaje a lowercase
		
		if [ "$opcion_lower" == "no" -o "$opcion_lower" == "n" ]
		then return 0
		fi

		if  [ "$opcion_lower" == "si" -o "$opcion_lower" == "s" ]
		then return 1
		fi

	done
}

log_perl_no_instalado () {
	log E "$COPY_W"
	log E "Para instalar el TP es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente."
	log E "Proceso de Instalación Cancelado"
}


log_perl_instalado () {
	log E "$COPY_W"
	log E "Perl Version: $1"
}

detectar_perl (){ 
	#perl --version
	# TODO ver si se puede obtenter la version de pearl y chequear
	version_perl=` perl --version | grep '^This is perl .*' | sed 's/^This is perl \(.\).*$/\1/g'`
	if [ $version_perl != 5 -a $version_perl != 6  ]
	then
		log_perl_no_instalado
		exit 0
	else
		log_perl_instalado "$version_perl" 		
	fi
}

validar_dir () {
	#Si el directorio pasado por parametro no es absoluto lo hace absoluto, dentro de $GRUPO
	#Si comienza en . lo hace absoluto dentro de $GRUPO
	#Si el directorio no esta dentro del directorio de trabajo devuelve null
	retorno=""
	parametro=$1
	
	if [ `expr match "$1" './'` == 2 ]
	then
		# ./ esta al principio, es relativo, quito los caracteres de inicio y concateno
		aux=`echo $parametro | cut -c 3-${#parametro}`
		retorno="${GRUPO}/${aux}"
	else
		if [ `expr match "$1" '/'` != 1 -a "$1" != "" ]
		then
			# no empieza ni con . ni con /
			retorno="${GRUPO}/${1}"
		else
			if [ `expr match "$1" '/'` == 1  ]
			then
				#Es path absoluto
				retorno=$1
			fi
		fi
	fi
	
	echo $retorno
}

validar_repeticion () {
	retorno="0"
	if [ "$1" == "$BINDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$MAEDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$ARRIDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$ACEPDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$RECHDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$REPODIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$PROCDIR" ]
	then
		retorno="1"
	fi
	if [ "$1" == "$LOGDIR" ]
	then
		retorno="1"
	fi
	echo $retorno
}

def_dir () {
	mensaje=$1
	read -p "$1" opcion
	if [ "$opcion" == "" ]
	then
		echo $2
	fi
	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		repeticion_validada=`validar_repeticion $dir_validado`
		if [ "$repeticion_validada" == "1" ]
		then
			#log "I" "Ya se encuentra reservado ese directorio, utilizando valor por defecto"
			echo $2
		else
			if [ "$dir_validado" != "" ]
			then 
				echo $dir_validado
			else
				log I "Entrada invalida, utilizando valor por defecto"
				echo $2
			fi
		fi
	fi	
}

validar_valor_numerico () {
	#Valida que el valor pasado por parametro sea numerico y mayor a cero
	#Devuelve 1 si es valido, 0 en caso contrario
	retorno=0
	numerico=0
	numerico=`echo $1 | grep -c "[A-Z|a-z|-]"`
	len=`expr length "$1"`
	
	#El valor 15 me permite multiplicar por 1024 y que no se vaya de rango
	if [ $numerico -eq 0 -a $len -le 15 ] 
	then 
		cero=0
		cero=`echo $1 | grep -c "[1-9]"`
		if [ $cero -gt 0 ]
		then retorno=1
		fi
	fi
	
	return $retorno
}


def_espacio_libre_min (){
	espacio_ok=0
	DATASIZE_TEST=${DATASIZE}

	#Se guarda el resultado de hacer df -P $GRUPO en un array y luego se toma el tamaño disponible
	read -d '' -ra df_retorno < <(LC_ALL=C df -Pm "$GRUPO")
	espacio_disponible=${df_retorno[10]}


	while [ $espacio_ok != 1 ]
	do
		mensaje="Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes. Máximo ${espacio_disponible} Mbytes (entrar para default: $DATASIZE): "
		read -p "$mensaje" opcion

		#Valido que sea numerico y distinto de cero
		validar_valor_numerico $opcion

		if [ $? -eq 1 ]
		then 
			DATASIZE_TEST=${opcion}
		else
			if [ "$opcion" != "" ]
			then 
				log "I" "Valor invalido. Usando valor por defecto"
				DATASIZE_TEST=${DATASIZE}
			fi
		fi

		#Se guarda el resultado de hacer df -P $GRUPO en un array y luego se toma el tamaño disponible
		read -d '' -ra df_retorno < <(LC_ALL=C df -Pm "$GRUPO")
		espacio_disponible=${df_retorno[10]}
				
		if [ ${DATASIZE_TEST} -ge $espacio_disponible ]
		then
			#espacio_disponible_mb=$((${espacio_disponible}/1024)) #traspaso a Mb para mostrar
			log "E" "Insuficiente espacio en disco."
			log "E" "Espacio disponible: $espacio_disponible Mb."
			log "E" "Espacio requerido ${DATASIZE_TEST} Mb"
			log "E" "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."
			espacio_ok=0
			leer_opcion_si_no "Desea intentarlo nuevamente? (Si-No):"
			if [ $? == 0 ]
			then 
				log "SE" "Instalacion abortada por el usuario"
				exit 0
			fi
		else
			espacio_ok=1
		fi
	done
	
	DATASIZE=$DATASIZE_TEST
	log "I" "DATASIZE es $DATASIZE Mb"
}

def_extension_log (){
	mensaje="Ingrese la extensión para los archivos de log (entrar para default: $LOGEXT): "
	read -p "$mensaje" opcion
	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		LOGEXT=$opcion
	fi

	log "I" "LOGEXT es $LOGEXT"
}

def_tam_log (){
	mensaje="Defina el tamaño máximo para los archivos $LOGEXT en Kbytes (entrar para default: $((${LOGSIZE}/1024))): "
	read -p "$mensaje" opcion

	validar_valor_numerico $opcion
	
	if [ $? -eq 1 ]
	then
		#Usar eleccion de usuario si es valida
		LOGSIZE=$((${opcion}*1024))
	else
		if [ "$opcion" != "" ]
		then log "E" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log "I" "LOGSIZE es $((${LOGSIZE}/1024)) Kb"	
}

mensaje_dir_instalacion (){
	log "I" "$COPY_W"
	log "I" "Librería del Sistema: $CONFDIR"
	log "I" "Ejecutables: $BINDIR"
	log "I" "Archivos maestros: $MAEDIR"
	log "I" "Directorio de arribo de archivos externos: $ARRIDIR"
	log "I" "Espacio mínimo libre para arribos: $DATASIZE Mb"
	log "I" "Archivos externos aceptados: $ACEPDIR"
	log "I" "Archivos externos rechazados: $RECHDIR"
	log "I" "Reportes de salida: $REPODIR"
	log "I" "Archivos procesados: $PROCDIR"
	log "I" "Logs de auditoría del Sistema: $LOGDIR/<comando>.$LOGEXT"
	log "I" "Tamaño máximo para los archivos de log del sistema: $((${LOGSIZE}/1024)) Kb"
	log "I" "Estado de la instalación: LISTA"
}

error_al_instalar () { 
	log "SE" "$1"
	exit 1
}

limpiar_archivos_de_instalacion () {
	#if [ -d "${GRUPO}/.tmp" ]
	#then 
	#	log "I" "Eliminando archivos de instalación"
	#	`rm ${GRUPO}/.tmp/*/*`
	#	`rmdir ${GRUPO}/.tmp/*`
	#	`rmdir ${GRUPO}/.tmp`
    #fi
    log "I" "Eliminando archivos de instalación"
}

instalar () {
	
	##Confirmar Inicio de Instalación
	leer_opcion_si_no  "Iniciando instalación. Desea continuar? (Si-No): "
	if [ $? == 0 ]
	then
		log "I" "Instalación abortada por el usuario"
		#TODO Limpiar basura
		exit 0
	fi

	### crear directorios
	log "I" "Creando estructura de directorios. . . ."
	mkdir -p $BINDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de binarios"
	fi
	log "I" "$BINDIR"

	mkdir -p $MAEDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de archivos maestros"
	fi
	log "I" "$MAEDIR"

	mkdir -p $ARRIDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de arribo de archivos externos"
	fi
	log "I" "$ARRIDIR"

	mkdir -p $RECHDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de archivos externos rechazados"
	fi
	log "I" "$RECHDIR"

	mkdir -p $ACEPDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de archivos externos aceptados"
	fi
	log "I" "$ACEPDIR"

	mkdir -p $REPODIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de reportes de salida"
	fi
	log "I" "$REPODIR"

	mkdir -p $PROCDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de archivos procesados"
	fi
	log "I" "$PROCDIR"

	mkdir -p $LOGDIR
	if [ $? != 0 ]
	then 
		error_al_instalar "No se pudo generar el directorio de logs"
	fi
	log "I" "$LOGDIR"

	### se mueven los archivos

	### mover maestros a $MAEDIR
	find "${GRUPO}/.tmp/mae/" -type f -name "*" -exec cp {} "${MAEDIR}" \;
	log "I" "Instalando Archivos Maestros"

	### mover archivos de disponibilidad a $PROCDIR
	find "${GRUPO}/.tmp/procesados/" -type f -name "*" -exec cp {} "${PROCDIR}" \;
	log "I" "Instalando Archivo de Disponibilidad"

	### mover binarios a $BINDIR
	find "${GRUPO}/.tmp/bin/" -type f -name "*" -exec cp {} "${BINDIR}" \;
	log "I" "Instalando Programas y Funciones"


	### crear archivo de configuracion
	user=`whoami`
	date=`date +"%Y-%m-%d %T"`
	
	if [ -f $conf ]
	then
		rm $conf
	fi
	
	touch "$conf"
	log "I" "Actualizando la configuración del sistema"
	linea="GRUPO=${GRUPO}=${user}=${date}" ; echo "$linea" >> $conf
	linea="CONFDIR=${CONFDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="BINDIR=${BINDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="MAEDIR=${MAEDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="ARRIDIR=${ARRIDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="ACEPDIR=${ACEPDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="RECHDIR=${RECHDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="REPODIR=${REPODIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="PROCDIR=${PROCDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGDIR=${LOGDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGEXT=${LOGEXT}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGSIZE=${LOGSIZE}=${user}=${date}" ; echo "$linea" >> $conf
	linea="DATASIZE=${DATASIZE}=${user}=${date}" ; echo "$linea" >> $conf
	linea="SLEEPTIME=${SLEEPTIME}=${user}=${date}" ; echo "$linea" >> $conf
	linea=""
	
	log "I" "Instalacion CONCLUIDA"

}



##############################################################################################################################
##############################################################################################################################
#INICIO
##############################################################################################################################
#Chequeo si existe el directorio de configuración, si no existe lo creo
if [ ! -d "./confdir" ]
then
	mkdir "./confdir"
fi

log I "Inicio de ejecución"
log I "Log del Comando Instalar_TP: $log"
log I "Directorio de Configuración: $CONFDIR"

#Chequeo si en principio existe el archivo de configuración
existe_conf=1
if [ ! -f "./confdir/Instalar_TP.conf" ]
then
	existe_conf=0
fi

if [ $existe_conf == 1 ] #changeeeeeeeeeeeee
then
	./.tmp/bin/VerificarInstalacion.sh COM $conf
	completa=$?
	if [ $completa == 0 ]
	then
		log I $COPY_W
		cargar_config
		mensaje_dir_instalacion
		log I "Estado de la instalación: COMPLETA"
		log I "Proceso de Instalación Cancelado"
		# Se termina la ejecución porque ya está todo instalado
		exit 0
	fi
	#Si pasa por aca es que la instalación no está completa
	cargar_config
	log I $COPY_W
	mensaje_instalacion_existente_incompleta
	log I "Estado de la instalación: INCOMPLETA"
	leer_opcion_si_no "Desea completar la instalación? (Si-No)"
	if [ $? == 0 ]
	then
		log SE "Instalación incompleta"
		exit 0
	else ############## INSTALACION DE COMPONENTES FALTANTES ############
		log I "Continuando con la instalacion de los componentes faltantes"
		detectar_perl
		datos_ok=0

		while [ $datos_ok != 1 ]
		do
			if [ "$FALTA_BINDIR" == "2" ]
			then 
				log I "Defina el directorio de instalación de los ejecutables"
				BINDIR=`def_dir "(entrar para default: $BINDIR):" $BINDIR`
				echo $BINDIR
			fi

			if [ "$FALTA_BINDIR" == "1" ]
			then 
				log I "Faltan archivos ejecutables. No se puede continuar"
				limpiar_archivos_de_instalacion
				exit 0
			fi
			
			if [ "$FALTA_MAEDIR" == "2" ]
			then 
				log I "Defina el directorio de instalación de los archivos maestros"
				MAEDIR=`def_dir "(entrar para default: $MAEDIR):" $MAEDIR`
				echo $MAEDIR
			fi

			if [ "$FALTA_MAEDIR" == "1" ]
			then 
				log I "Faltan archivos maestros. No se puede continuar"
				limpiar_archivos_de_instalacion
				exit 0
			fi

			if [ "$FALTA_ARRIDIR" == "2" ]
			then 
				log I "Defina el directorio de arribo de archivos externos"
				ARRIDIR=`def_dir "(entrar para default: $ARRIDIR):" $ARRIDIR`
				echo $ARRIDIR
			fi

			if [ "$FALTA_ACEPDIR" == "2" ]
			then 
				log I "Defina el directorio de grabación de los archivos externos aceptados"
				ACEPDIR=`def_dir "(entrar para default: $ACEPDIR):" $ACEPDIR`
				echo $ACEPDIR
			fi

			if [ "$FALTA_RECDIR" == "2" ]
			then 
				log I "Defina el directorio de grabación de los archivos externos rechazados"
				RECHDIR=`def_dir "(entrar para default: $RECHDIR):" $RECHDIR`
				echo $RECHDIR
			fi

			if [ "$FALTA_REPDIR" == "2" ]
			then 
				log I "Defina el directorio de grabación de los listados de salida"
				REPODIR=`def_dir "(entrar para default: $REPODIR):" $REPODIR`
				echo $REPODIR
			fi

			if [ "$FALTA_PROC" == "2" ]
			then 
				log I "Defina el directorio de grabación de los archivos procesados"
				PROCDIR=`def_dir "(entrar para default: $PROCDIR):" $PROCDIR`
				echo $PROCDIR
			fi


			if [ "$FALTA_LOGDIR" == "2" ]
			then 
				log I "Defina el directorio de logs"
				LOGDIR=`def_dir "(entrar para default: $LOGDIR):" $LOGDIR`
				echo $LOGDIR
			fi
	
			if [ "$DATASIZE" == "" ] ; then def_espacio_libre_min ; fi
			if [ "$LOGSIZE" == "" ] ; then def_tam_log ; fi
			if [ "$LOGEXT" == "" ] ; then def_extension_log ; fi

			clear
			mensaje_dir_instalacion
			leer_opcion_si_no "Los datos ingresados son correctos? (Si-No): "
			if [ $? == 1 ]
			then 
				datos_ok=1
			fi
		done

		instalar
		limpiar_archivos_de_instalacion
		exit 0
	fi
fi
#Se procede a instalar todo de cero
log I $COPY_W
log I "A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa aceptar los términos y Condiciones del ACUERDO DE LICENCIA DE SOFTWARE incluido en este paquete. "
leer_opcion_si_no "Acepta? Si – No  "
if [ $? == 0 ]
then 
	exit 0
fi

detectar_perl

datos_ok=0

while [ $datos_ok != 1 ]
do
	# Directorio bin
	log I "Defina el directorio de instalación de los ejecutables"
	BINDIR=`def_dir "(entrar para default: $BINDIR):" $BINDIR`
	echo $BINDIR
	# Directorio archivos maestros
	log I "Defina el directorio de instalación de los archivos maestros"
	MAEDIR=`def_dir "(entrar para default: $MAEDIR):" $MAEDIR`
	echo $MAEDIR
	# Directorio archivos externos
	log I "Defina el directorio de arribo de archivos externos"
	ARRIDIR=`def_dir "(entrar para default: $ARRIDIR):" $ARRIDIR`
	echo $ARRIDIR

	def_espacio_libre_min

	log I "Defina el directorio de grabación de los archivos externos aceptados"
	ACEPDIR=`def_dir "(entrar para default: $ACEPDIR):" $ACEPDIR`
	echo $ACEPDIR

	log I "Defina el directorio de grabación de los archivos externos rechazados"
	RECHDIR=`def_dir "(entrar para default: $RECHDIR):" $RECHDIR`
	echo $RECHDIR

	log I "Defina el directorio de grabación de los listados de salida"
	REPODIR=`def_dir "(entrar para default: $REPODIR):" $REPODIR`
	echo $REPODIR

	log I "Defina el directorio de grabación de los archivos procesados"
	PROCDIR=`def_dir "(entrar para default: $PROCDIR):" $PROCDIR`
	echo $PROCDIR

	log I "Defina el directorio de logs"
	LOGDIR=`def_dir "(entrar para default: $LOGDIR):" $LOGDIR`
	echo $LOGDIR

	def_extension_log

	def_tam_log

	read -p "Configuraciones previas concluidas. Ingrese entrar para continuar" opcion_aux

	clear

	mensaje_dir_instalacion

	leer_opcion_si_no "Los datos ingresados son correctos? (Si-No): "
	if [ $? == 1 ]
	then 
		datos_ok=1
	fi
done

instalar

limpiar_archivos_de_instalacion

exit 0