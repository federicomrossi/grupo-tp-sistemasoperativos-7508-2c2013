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



log (){
	perl -I$SCRIPTS -Mfunctions -e "functions::Grabar_L('Instalar_TP', '$1', '$2', '$log')"
	echo $2	
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

if [ $existe_conf == 1 ]
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



exit 0