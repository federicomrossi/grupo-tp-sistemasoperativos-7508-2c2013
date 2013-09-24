#! /bin/bash

#Sistemas Operativos
#Modulo Instalador
#Nombre: InstalarU.sh
#Autor: Grupo 10

#Definicion variables y constantes
GRUPO=`pwd`
CONFDIR="$GRUPO/confdir"
log="$CONFDIR/InstalarU.log"
conf="$CONFDIR/InstalarU.conf"
cabecera_mensajes="TP SO7508 1mer cuatrimestre 2012. Tema U Copyright © Grupo 10"
ARRIDIR="$GRUPO/arribos"
RECHDIR="$GRUPO/rechazos"
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
REPODIR="$GRUPO/reportes"
LOGDIR="$GRUPO/log"
LOGEXT=".log"
LOGSIZE=409600 # 400 Kbytes
DATASIZE=100 
SLEEPTIME=5 #Variable extra utilizada por DetectarU agregada al archivo de configuracion
INST_RECIBIDAS="${GRUPO}/inst_recibidas"
INST_ORDENADAS="${GRUPO}/inst_ordenadas"
INST_RECHAZADAS="${GRUPO}/inst_rechazadas"
INST_PROCESADAS="${GRUPO}/inst_procesadas"
PARQUE_INSTALADO="${GRUPO}/parque_instalado"


########## FUNCIONES ###################################################
log (){
	#Loguea en el log correspondiente, con el formato correpondiente, a traves
	#de la funcion LoguearU.
	#Imprime en pantalla el mensaje pasado
	#$1 Opcion de logueo.
	#	-l: solo log
	#	-e: solo por pantalla
	#	-b: ambos
	#$2 Tipo de mensaje (para lista completa ver funcion perl LoguearU)
	#	I: informativo
	#	A: alerta
	#	E: error
	#	SE: error severo
	#$3 Numero de mensaje (para lista completa ver funcion perl LoguearU)
	#	1: "Arhivo inexistente"
    #	2: "Permiso Denegado"
    #	3: "No se pudo leer el archivo"
	#$4 Mensaje

	if [ "$1" == "-b" -o "$1" == "-l" ]
	#then echo `date +"%Y-%m-%d %T"` " $mensaje" >> $log
	then  perl -I$GRUPO/.tmp/bin -Mfunctions -e "functions::LoguearU('InstalarU', '$2', '$3', '$4', '$log')"
	fi

	if [ "$1" == "-b" -o "$1" == "-e" ]
	then echo "$4"
	fi
}

leer_opcion_si_no () {
	#Le pide al usuario que ingrese si o no validando la entrada
	#Recibe por parametro que se usa como mensaje para el usuario
	#Devuelve 1 si la eleccion fue si; 0 si fue no
	opcion_valida=0
	while true
	do
		read -p "$1" opcion
		opcion=${opcion,,} #Pasaje a lowercase
		
		if [ "$opcion" == "no" -o "$opcion" == "n" ]
		then return 0
		fi

		if  [ "$opcion" == "si" -o "$opcion" == "s" ]
		then return 1
		fi
		
		if [ "$opcion" == "Q" -o "$opcion" == "q" ]
		then exit 0
		fi
	done
}

cargar_config () {
	#Lee el archivo InstalarU.conf y carga las variables
	#CONFDIR
	#BINDIR
	#MAEDIR
	#ARRIDIR
	#RECHDIR
	#LOGDIR
	#REPODIR
	
	if [ -f $conf ]
	then
		while IFS== read -r var valor usuario fecha
		do
			case "$var" in 
			GRUPO) GRUPO=$valor ;;
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

detectar_inst_perl (){ 
	log -b "I" "0" "Verificando instalacion de perl"
	perl --version
	if [ ! $? == 0 ]
	then
		mensaje_perl_no_instalado
		exit 0
	fi
}

validar_dir () {
	#Si el directorio pasado por parametro no es absoluto lo hace absoluto, dentro de $GRUPO
	#Si comienza en . lo hace absoluto dentro de $GRUPO
	#Si el directorio no esta dentro del directorio de trabajo devuelve null
	retorno=""
	
	if [ `expr match "$1" './'` == 2 ]
	then
		# ./ esta al principio, es relativo
		retorno=${1/"."/$GRUPO}
	else
		if [ `expr match "$1" '/'` != 1 -a "$1" != "" ]
		then
			# no empieza ni con . ni con /
			retorno="${GRUPO}/${1}"
		else
			if [ "`echo $1 | grep -o '.*grupo10'`" == "$GRUPO" ]
			then
				#Es path absoluto y esta dentro de $GRUPO
				retorno=$1
			fi
		fi
	fi
	
	echo $retorno
}

def_bindir () {
	mensaje="Defina el directorio de instalación de los ejecutables (entrar para default: $BINDIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion
	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then 
			BINDIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "BINDIR es $BINDIR"
	echo ""
}

def_maedir () {
	mensaje="Defina el directorio de instalación de los archivos maestros (entrar para default: $MAEDIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion
	
	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then 
			MAEDIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "MAEDIR es $MAEDIR"
	echo ""
}

def_arridir () {
	mensaje="Defina el directorio de arribo de los archivos externos (entrar para default: $ARRIDIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion

	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then
			ARRIDIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "ARRIDIR es $ARRIDIR"
	echo ""
}

def_espacio_libre_min (){
	mensaje="Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (entrar para default: $DATASIZE): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion
	espacio_ok=0
	
	while [ $espacio_ok != 1 ]
	do
		if [ "$opcion" != "" -a "$opcion" != 0 ]
		then DATASIZE=$opcion 
		else
			if [ "$opcion" == 0 ]
			then log -b "A" "0" "Valor invalido. Usando valor por defecto"
			fi
		fi

		#Se guarda el resultado de hacer df -P $GRUPO en un array y luego se toma el tamaño disponible
		read -d '' -ra df_retorno < <(LC_ALL=C df -P "$GRUPO")
		espacio_disponible=${df_retorno[10]}
				
		if [ $((${DATASIZE}*1024)) -ge $espacio_disponible ]
		then
			espacio_disponible_mb=$((${espacio_disponible}=/1024)) #traspaso a Mb para mostrar
			log -b "A" "0" "Insuficiente espacio en disco."
			log -b "A" "0" "Espacio disponible: $espacio_disponible_mb Mb."
			log -b "A" "0" "Espacio requerido $DATASIZE Mb"
			log -b "A" "0" "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."
			espacio_ok=0
			leer_opcion_si_no "Desea intentarlo nuevamente? (Si-No):"
			if [ $? == 0 ]
			then 
				log -b "SE" "0" "Instalacion cancelada por el usuario"
				exit 0
			fi
		else
			espacio_ok=1
		fi
	done
	log -b "I" "0" "DATASIZE es $DATASIZE"
}

def_rechdir () {
	mensaje="Defina el directorio de grabación de los archivos externos rechazados (entrar para default: $RECHDIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion

	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then
			RECHDIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "RECHDIR es $RECHDIR"
	echo ""
}

def_logdir (){
	mensaje="Defina el directorio de grabación de los logs de auditoria (entrar para default: $LOGDIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion

	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then
			LOGDIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi
	
	log -b "I" "0" "LOGDIR es $LOGDIR"
	echo ""
}

def_extension_log (){
	mensaje="Defina la extensión para los archivos de log (entrar para default: $LOGEXT): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion
	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		LOGEXT=$opcion
	fi

	log -b "I" "0" "LOGEXT es $LOGEXT"
	echo ""
}

def_tam_log (){
	mensaje="Defina el tamaño máximo para los archivos $LOGEXT en Kbytes (entrar para default: $LOGSIZE): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion
	if [ "$opcion" != "" -a "$opcion" != 0 ]
	then
		#Usar eleccion de usuario si es valida
		LOGSIZE=$((${opcion}*1024))
	else
		if [ "$opcion" == 0 ]
		then log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "LOGSIZE es $LOGSIZE"
	echo ""
}

def_repodir (){
	mensaje="Defina el directorio de grabación de los reportes de salida (entrar para default: $REPODIR): "
	log -l "I" "0" "$mensaje"
	read -p "$mensaje" opcion

	if [ "$opcion" != "" ]
	then
		#Usar eleccion de usuario si es valida
		dir_validado=`validar_dir $opcion`
		if [ "$dir_validado" != "" ]
		then
			REPODIR=$dir_validado
		else
			log -b "A" "0" "Entrada invalida, utilizando valor por defecto"
		fi
	fi

	log -b "I" "0" "REPODIR es $REPODIR"
	echo ""
}

instalar () {
	
	##Confirmar Inicio de Instalación
	echo ""
	log -l "I" "0" "Iniciando instalación. Desea continuar? (Si-No): "
	leer_opcion_si_no  "Iniciando instalación. Desea continuar? (Si-No): "
	if [ $? == 0 ]
	then
		log -b "SE" "0" "Instalacion abortada por el usuario"
		#Limpiar basura
		exit 0
	fi

	### crear directorios
	mkdir -p $BINDIR ; log -b "I" "0" "Creado directorio $BINDIR"
	mkdir -p $LOGDIR ; log -b "I" "0" "Creado directorio $LOGDIR"
	mkdir -p $ARRIDIR ; log -b "I" "0" "Creado directorio $ARRIDIR"
	mkdir -p $MAEDIR ; log -b "I" "0" "Creado directorio $MAEDIR"
	mkdir -p $REPODIR ; log -b "I" "0" "Creado directorio $REPODIR"
	mkdir -p $RECHDIR ; log -b "I" "0" "Creado directorio $RECHDIR"
	mkdir -p $INST_RECIBIDAS ; log -b "I" "0" "Creado directorio $INST_RECIBIDAS"
	mkdir -p $INST_ORDENADAS ; log -b "I" "0" "Creado directorio $INST_ORDENADAS"
	mkdir -p $INST_RECHAZADAS ; log -b "I" "0" "Creado directorio $INST_RECHAZADAS"
	mkdir -p $INST_PROCESADAS ; log -b "I" "0" "Creado directorio $INST_PROCESADAS"
	mkdir -p $PARQUE_INSTALADO ; log -b "I" "0" "Creado directorio $PARQUE_INSTALADO"

	### crear archivo de configuracion
	user=`whoami`
	date=`date +"%Y-%m-%d %T"`
	
	if [ -f $conf ]
	then
		rm $conf
	fi
	
	touch "$conf"
	log -b "I" "0" "Generando archivo de configuracion"
	linea="GRUPO=${GRUPO}=${user}=${date}" ; echo "$linea" >> $conf
	linea="ARRIDIR=${ARRIDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="RECHDIR=${RECHDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="BINDIR=${BINDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="MAEDIR=${MAEDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="REPODIR=${REPODIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGDIR=${LOGDIR}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGEXT=${LOGEXT}=${user}=${date}" ; echo "$linea" >> $conf
	linea="LOGSIZE=${LOGSIZE}=${user}=${date}" ; echo "$linea" >> $conf
	linea="DATASIZE=${DATASIZE}=${user}=${date}" ; echo "$linea" >> $conf
	linea=""
	
	#Se agregan 10 lineas en blanco al archivo de configuracion para futuros usos
	for (( i=0; i<10; i++ ))
	do echo "$linea" >> $conf
	done

	#Campos extra
	linea="SLEEPTIME=${SLEEPTIME}=${user}=${date}" ; echo "$linea" >> $conf

	### mover ejecutables a $BINDIR y dar permiso de ejecucion para el usuario
	find "${GRUPO}/.tmp/bin/" -type f -name "*" -exec cp -n {} "${BINDIR}" \;
	log -b "I" "0" "Instalando archivos binarios en $BINDIR"
	chmod u+x ${BINDIR}/*

	### mover maestros a $MAEDIR
	find "${GRUPO}/.tmp/mae/" -type f -name "*" -exec cp -n {} "${MAEDIR}" \;
	log -b "I" "0" "Instalando archivos maestros en $MAEDIR"

	#Mostrar mensaje de fin de instalación
	echo ""
	log -b "I" "0" "Instalacion finalizada"

}

limpiar_archivos_de_instalacion () {
	if [ -d "${GRUPO}/.tmp" ]
	then 
		log -b "I" "0" "Eliminando archivos de instalación"
		`rm ${GRUPO}/.tmp/*/*`
		`rmdir ${GRUPO}/.tmp/*`
		`rmdir ${GRUPO}/.tmp`
	fi
}

############ FIN FUNCIONES #############################################

############ MENSAJES Y LOGS ###########################################
mensaje_instalacion_existente_completa () {
	log -b "I" "0" "--------------------------------------------------------------"
	log -b "I" "0" "$cabecera_mensajes"
	log -b "I" "0" "Librería del Sistema: $CONFDIR"
	log -b "I" "0" `dir $CONFDIR`
	log -b "I" "0" "Directorio de instalación de los ejecutables: $BINDIR"
	log -b "I" "0" `dir $BINDIR`
	log -b "I" "0" `dir $MAEDIR`
	log -b "I" "0" "Directorio de arribo de archivos externos: $ARRIDIR"
	log -b "I" "0" "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
	log -b "I" "0" "Directorio de grabación de los logs de auditoria: $LOGDIR"
	log -b "I" "0" "Directorio de grabación de los reportes de salida: $REPODIR"
	log -b "I" "0" "Estado de la instalacion: COMPLETA"
	echo ""
	log -b "I" "0" "Proceso de Instalación Cancelado"
	log -b "I" "0" "--------------------------------------------------------------"
}

mensaje_instalacion_existente_incompleta () {
	log -b "I" "0" "--------------------------------------------------------------"
	log -b "I" "0" "$cabecera_mensajes"

	./.tmp/bin/VerificarInstalacion.sh BIN $conf ; ec_BIN=$?
	./.tmp/bin/VerificarInstalacion.sh MAE $conf ; ec_MAE=$?
	./.tmp/bin/VerificarInstalacion.sh REC $conf ; ec_REC=$?
	./.tmp/bin/VerificarInstalacion.sh REP $conf ; ec_REP=$?
	./.tmp/bin/VerificarInstalacion.sh LOG $conf ; ec_LOG=$?
	./.tmp/bin/VerificarInstalacion.sh ARR $conf ; ec_ARR=$?
	
	log -b "I" "0" "Componentes existentes: "

	if [ $ec_BIN == 0 ]
	then log -b "I" "0" "Directorio de instalación de los ejecutables: $BINDIR" ; log -b "I" "0" `dir $BINDIR`
	fi

	if [ $ec_MAE == 0 ]
	then log -b "I" "0" "Directorio de instalación de los archivos maestros: $MAEDIR" ; log -b "I" "0" `dir $MAEDIR`
	fi

	if [ $ec_ARR == 0 ]
	then log -b "I" "0" "Directorio de arribo de archivos externos: $ARRIDIR"
	fi

	if [ $ec_REC == 0 ]
	then log -b "I" "0" "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
	fi

	if [ $ec_LOG == 0 ]
	then log -b "I" "0" "Directorio de grabación de los logs de auditoria: $LOGDIR"
	fi
	
	if [ $ec_REP == 0 ]
	then log -b "I" "0" "Directorio de grabación de los reportes de salida: $REPODIR"
	fi
	
	log -b "I" "0" "Componentes faltantes: "
	
	if [ $ec_BIN == 2 ]
	then log -b "I" "0" "Directorio de instalación de los ejecutables" ; FALTA_BINDIR=1
	else
		if [ $ec_BIN == 1 ]
		then 
			log -b "I" "0" "Archivos ejecutables: IniciarU.sh, DetectarU.sh, GrabarParqueU.sh, ListarU.pl, LoguearU.pl, MirarU.pl, StopD.sh, StartD.sh"
			FALTA_BINDIR=1
		fi
	fi

	if [ $ec_MAE == 2 ]
	then log -b "I" "0" "Directorio de instalación de los archivos maestros" ; FALTA_MAEDIR=2
	else
		if [ $ec_MAE == 1 ]
		then log -b "I" "0" "Archivos maestros: cli.mae, sucu.mae, prod.mae" ; FALTA_MAEDIR=1
		fi
	fi

	if [ $ec_ARR == 2 ]
	then log -b "I" "0" "Directorio de arribo de archivos externos" ; FALTA_ARRIDIR=2
	fi

	if [ $ec_REC == 2 ]
	then log -b "I" "0" "Directorio de grabación de los archivos externos rechazados" ; FALTA_RECDIR=2
	fi

	if [ $ec_LOG == 2 ]
	then log -b "I" "0" "Directorio de grabación de los logs de auditoria" ; FALTA_LOGDIR=2
	fi
	
	if [ $ec_REP == 2 ]
	then log -b "I" "0" "Directorio de grabación de los reportes de salida" ; FALTA_REPDIR=2
	fi

	log -b "I" "0" "--------------------------------------------------------------"
}

mensaje_perl_no_instalado () {
	log -b "I" "0" "$cabecera_mensajes"
	log -b "SE" "0" "Para instalar el TP es necesario contar con Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente."
	log -b "SE" "0" "Proceso de instalación cancelado"

}

informacion_instalacion () {
	log -b "I" "0" "--------------------------------------------------------------"
	log -b "I" "0" "$cabecera_mensajes"
	log -b "I" "0" "Directorio de Trabajo para la instalacion: `pwd`"
	log -b "I" "0" "Archivos y subdirectorios: `ls -R`"
	log -b "I" "0" "Librería del Sistema: $CONFDIR"
	log -b "I" "0" "Archivos de confguracion: `ls $CONFDIR -R`"

	log -b "I" "0" "Estado de la instalacion: PENDIENTE"
	log -b "I" "0" "Para completar la instalación Ud. Deberá:"
	log -b "I" "0" "Definir el directorio de instalación de los ejecutables"
	log -b "I" "0" "Definir el directorio de instalación de los archivos maestros"
	log -b "I" "0" "Definir el directorio de arribo de archivos externos"
	log -b "I" "0" "Definir el espacio mínimo libre para el arribo de archivos externos"
	log -b "I" "0" "Definir el directorio de grabación de los archivos externos rechazados"
	log -b "I" "0" "Definir el directorio de grabación de los logs de auditoria"
	log -b "I" "0" "Definir la extensión y tamaño máximo para los archivos de log"
	log -b "I" "0" "Definir el directorio de grabación de los reportes de salida"
	log -b "I" "0" "--------------------------------------------------------------"

}

mensaje_instalacion_lista () {
	log -b "I" "0" "--------------------------------------------------------------"
	log -b "I" "0" "$cabecera_mensajes"
	log -b "I" "0" "Se instalaran los componentes con la siguiente informacion:"
	log -b "I" "0" "Directorio de Trabajo: $GRUPO"
	log -b "I" "0" "Librería del Sistema: $CONFDIR"
	log -b "I" "0" "Directorio de instalación de los ejecutables: $BINDIR"
	log -b "I" "0" "Directorio de instalación de los archivos maestros: $MAEDIR"
	log -b "I" "0" "Directorio de arribo de archivos externos: $ARRIDIR"
	log -b "I" "0" "Espacio mínimo libre para el arribo de archivos externos: $DATASIZE Mb"
	log -b "I" "0" "Directorio de grabación de los archivos externos rechazados: $RECHDIR"
	log -b "I" "0" "Directorio de grabación de los logs de auditoria: $LOGDIR"
	log -b "I" "0" "Extensión para los archivos de log: $LOGEXT"
	log -b "I" "0" "Tamaño máximo para los archivos de log: $LOGSIZE Kb"
	log -b "I" "0" "Directorio de grabación de los reportes de salida: $REPODIR"
	log -b "I" "0" "Estado de la instalacion: LISTA"
	log -b "I" "0" "--------------------------------------------------------------"
}

############ FIN MENSAJES Y LOGS #######################################

############ INICIO INSTALACION ########################################
# Crear directorio conf e inicializar el archivo log
if [ ! -d "./confdir" ]
then 
	mkdir ./confdir ; log -b "I" "0" "Creando directorio confdir"
fi

log -b "I" "0" "Comando InstalarU inicio de ejecucion"

#Utiliza shell script VerificarInstalacion.sh para comprobar el estado
#de los distintos directorios y de la instalacion.
./.tmp/bin/VerificarInstalacion.sh COM $conf
inst_completa=$?

if [ $inst_completa == 0 ]
then 
	cargar_config
	mensaje_instalacion_existente_completa
	log -b "I" "0" "Instalacion completa, saliendo del instalador"
	exit 0
fi

if [ $inst_completa == 1 ]
then
	log -b "I" "0" "Faltan componentes. Configurar componentes faltantes"
	cargar_config
	mensaje_instalacion_existente_incompleta
	leer_opcion_si_no "Desea completar la instalacion? (Si-No): "

	if [ $? == 0 ]
	then
		log -b "SE" "0" "Instalacion abortada por el usuario"
		exit 0
	else ############## INSTALACION DE COMPONENTES FALTANTES ############
		log -b "I" "0" "Continuando con la instalacion de los componentes faltantes"
		detectar_inst_perl
		datos_ok=0

		while [ $datos_ok != 1 ]
		do
			if [ "$FALTA_BINDIR" == "2" ]
			then def_bindir
			fi
			if [ "$FALTA_MAEDIR" == "2" ]
			then def_maedir
			fi
			if [ "$FALTA_ARRIDIR" == "2" ]
			then def_arridir
			fi
			if [ "$FALTA_RECHDIR" == "2" ]
			then def_rechdir
			fi
			if [ "$FALTA_LOGDIR" == "2" ]
			then def_logdir
			fi
			if [ "$FALTA_REPODIR" == "2" ]
			then def_repodir
			fi
			
			if [ "$DATASIZE" == "" ]
			then def_espacio_libre_min
			fi
			if [ "$LOGSIZE" == "" ]
			then def_tam_log
			fi
			if [ "$LOGEXT" == "" ]
			then def_extension_log
			fi
			
			clear
			mensaje_instalacion_lista
			log -l "I" "0" "Los datos ingresados son correctos? (Si-No): "
			leer_opcion_si_no "Los datos ingresados son correctos? (Si-No): "
			if [ $? == 1 ]
			then datos_ok=1
			fi
		done

		instalar
		limpiar_archivos_de_instalacion
		exit 0
	fi
fi

if [ $inst_completa == 3 ]
then ########## INSTALACION COMPLETA #################
	log -b "I" "0" "Ningun componente instalado. Continuando con la instalacion completa"
	
	#Chequear que Perl este instalado
	detectar_inst_perl

	##Brindar informacion de la instalacion
	informacion_instalacion
	datos_ok=0

	while [ $datos_ok != 1 ]
	do
		##Definir directorio de instalacion binarios
		def_bindir

		##Definir directorio de instalacion archivos maestros
		def_maedir

		##Definir directorio de arribo de archivos externos
		def_arridir

		##Definir el espacio minimo libre para el arribo de archivos ext
		def_espacio_libre_min

		##Definir directorio de grabacion de los archivos rechazados
		def_rechdir

		##Definir directorio de grabacion de los logs de auditoria
		def_logdir

		##Definir la extensión y tamaño máximo para los archivos de log
		def_extension_log
		def_tam_log

		##Definir el directorio de grabación de los reportes de salida
		def_repodir

		##Mostrar estructura de directorios resultante y valores de parámetros configurados
		#informacion_configuracion
		clear
		mensaje_instalacion_lista
		log -l "I" "0" "Los datos ingresados son correctos? (Si-No): "
		leer_opcion_si_no "Los datos ingresados son correctos? (Si-No): "
		if [ $? == 1 ]
		then datos_ok=1
		fi
		
	done
	
	##Instalación
	instalar
	limpiar_archivos_de_instalacion
fi

#Fin
exit 0
