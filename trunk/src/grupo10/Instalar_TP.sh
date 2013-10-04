#! /bin/bash

#Sistemas Operativos
#Modulo Instalador
#Nombre: Instalar_TP.sh
#Autor: Grupo 10

#Definicion variables y constantes
COPY_W="TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 10"
GRUPO=`pwd`
CONFDIR="$GRUPO/confdir"
SCRIPTS="$GRUPO/scripts"
log="$CONFDIR/Instalar_TP.log"
conf="$CONFDIR/Instalar_TP.conf"
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
ARRIDIR="$GRUPO/arribos"


log (){
	perl -I$SCRIPTS -Mfunctions -e "functions::Grabar_L('Instalar_TP', '$1', '$2', '$log')"
	echo " $2"	
}

instalacion_completa () {
	return 0
}

mensajes_directorios () {
	return 1
}

completar_instalacion () {
	return 1
}

loguear_componentes_faltantes () { 
	return 1
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
	log E $COPY_W
	log E "Para instalar el TP es necesario contar con  Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente."
	log E "Proceso de Instalación Cancelado"
}


log_perl_instalado () {
	log E $COPY_W
	log E "Perl Version: $1"
}

detectar_perl (){ 
	#perl --version
	# TODO ver si se puede obtenter la version de pearl y chequear
	version_perl=` perl --version | grep '^This is perl .*' | sed 's/^This is perl \(.\).*$/\1/g'`
	
	if [ $version_perl<5 ]
	then
		log_perl_no_instalado
		exit 0
	else
		log_perl_instalado $version_perl 		
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
		if [ "$dir_validado" != "" ]
		then 
			echo $dir_validado
		else
			log I "Entrada invalida, utilizando valor por defecto"
			echo $2
		fi
	fi	
}

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
	instalacion_completa
	completa=$?
	if [ $completa == 1 ]
	then
		log I $COPY_W
		mensajes_directorios
		log I "Estado de la instalación: COMPLETA"
		log I "Proceso de Instalación Cancelado"
		# Se termina la ejecución porque ya está todo instalado
		exit 0
	fi
	#Si pasa por aca es que la instalación no está completa
	completar_instalacion
	log I $COPY_W
	mensajes_directorios
	loguear_componentes_faltantes
	log I "Estado de la instalación: INCOMPLETA"
	leer_opcion_si_no "Desea completar la instalación? (Si-No)"
	if [ $? == 0 ]
	then
		log SE "Instalación incompleta"
		exit 0
	fi
fi
#Se procede a instalar todo de cero
detectar_perl
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

exit 0