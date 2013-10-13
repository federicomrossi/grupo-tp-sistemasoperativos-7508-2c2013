#!/bin/bash
# PURPOSE:	Comando de deteccion de arribo de archivos
########################Variables########################
CONFDIR="/confdir/Instalar_TP.conf"
BASEPATH=`echo $PWD | grep -o '.*grupo10'` 
CONF="${BASEPATH}${CONFDIR}"
COMMAND="Recibir_B"
MSG_NUM=0

#VERIFICAR SI LLEGAN COMO VARIABLE GLOBAL
MAEOBRA="$MAEDIR/obras.mae"
MAESALA="$MAEDIR/salas.mae"

# Constante que representa caracteres ascii y no ascii, salvo el delimitador ';'
readonly CHAR_SIN_PC="[\x00-\x3A|\x3C-\xFF]"

########################FUNCTIONS########################
function log1 (){
	#Loguea en el log correspondiente, con el formato correpondiente.
	#Recibe el mensaje a loguear
	perl -I$BINDIR -Mfunctions -e "functions::Grabar_L('Recibir_B', '$1', '$2')"
}

function verificar_inicializacion_ambiente()
{
	#Verifica que el ambiente se haya inicializado correctamente
	while read LINE; do
		VARIABLE=`echo $LINE | cut -d '=' -f '1'`
		TEMP=$(eval echo $`echo $VARIABLE`)
		if [[ $TEMP == "" ]]
		then
			echo "La variable $VARIABLE no esta inicializada"
			return 1
		fi
		
	done<$CONF

	return 0
}

function verificar_archivos_maestros()
{
	#Verifica que los archivos maestros contenga el formato correcto.

	#Maestro de sucursales
	qmsuc=`cat $MAESUC | grep -v -E -e "^[0-9]+,[^,]+,[0-9]+,[^,]+,[^,]+,[^,]+,[0-3][0-9]/[0-1][0-9]/[0-2][0-9]{3},([0-3][0-9]/[0-1][0-9]/[0-2][0-9]{3})?$" | wc -l`
	
	if [ $qmsuc -eq 0 ]
	then
		return 1
	fi

	return 0
}

function verificar_ya_ejecutando()
{
	#Verifica si ya se esta ejecutando un Recibir_B.
	q=`ps r -ef | grep -v grep | grep '[.]/Recibir_B.sh' | wc -l`
	if [ $q -gt 1 ]
	then 
		return 1
	else 
		return 0
	fi
}

function validar_archivo_reservas()
{
	#Valida que el nombre del archivo sea correcto y que exista en los maestros
	# $f tiene el nombre del archivo
	
	#Validar formato
	if [[ "$f" =~ ^[0-9]+-[_a-zA-Z0-9.-]+@[a-zA-Z0-9.]+-.* ]] # =~ --> que cumpla con la expresion regular num-mail-abc
	then
		#Validar integridad
		#Extraigo informacion del nombre del archivo de entrada

		id=`echo $f | cut -d- -f1`
		direccion=`echo $f | cut -d@ -f1 | cut -d- -f1 --complement`
		host=`echo $f | cut -d@ -f2 | cut -d- -f1`
		mail="$direccion@$host"		

		if [ $(( $id % 2 )) == "1" ]  #verifico archivo de obras
		then
			if [[ `grep -P "^$id;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$mail" "$MAEOBRA" | wc -l` -eq 1 ]]
			then
				return 1 #encontro todo
			fi
			if [[ `grep -P "^$id;$CHAR_SIN_PC*;$mail;$CHAR_SIN_PC*" "$MAEOBRA" | wc -l` -eq 1 ]]
			then
				return 1 #encontro todo
			fi
			if [[ `grep -P "^$id;" "$MAEOBRA" | wc -l` -eq 1 ]]
			then
				return 2 # correo inexistente
			fi
			if [[ `grep -P "^$CHAR_SIN_PC*;$CHAR_SIN_PC*;$mail;.*" "$MAEOBRA" | wc -l` -eq 1 ]]
			then
				return 3 #id inexistente
			fi
			if [[ `grep -P "^$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$mail" "$MAEOBRA" | wc -l` -eq 1 ]]
			then
				return 3 #id inexistente
			fi
		else
			
			if [[ `grep -P "^$id;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$mail" "$MAESALA" | wc -l` -eq 1 ]]
			then
				return 1 #encontro todo
			fi
			if [[ `grep -P "^$id;" "$MAESALA" | wc -l` -eq 1 ]]
			then
				return 2 #correo inexistente
			fi
			if [[ `grep -P "^$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$CHAR_SIN_PC*;$mail" "$MAESALA" | wc -l` -eq 1 ]]
			then
				return 4 #id inexistente
			fi	

		fi
		return 5
	fi
	return 0
}

function validar_archivo_invitados()
{
	#Valida que el nombre del archivo sea correcto y que exista en los maestros
	# $f tiene el nombre del archivo
	
	#Validar formato
	if [[ "$f" =~ ^[_a-zA-Z0-9]*\.inv$ ]] # =~ --> que cumpla con la expresion regular num-mail-abc
	then
		return 1
	fi
	return 0
}


function mover_archivo_recibido_reservas()
{
	log1 "Se valido y movio el archivo $f a $ACEPDIR."  "I"
	#Mueve el archivo al directorio de recibidos.
	perl -I$BINDIR -Mfunctions -e "functions::Mover_B('$ARRIDIR/$f', '$ACEPDIR', 'Recibir_B')"
	return 0
}

function mover_archivo_recibido_invitados()
{
	log1 "Se valido y movio el archivo $f a $REPODIR."  "I"
	#Mueve el archivo al directorio de recibidos.
	perl -I$BINDIR -Mfunctions -e "functions::Mover_B('$ARRIDIR/$f', '$REPODIR', 'Recibir_B')"
	return 0
}

function mover_archivo_rechazado()
{
	log1 "Se valido y movio el archivo $f de tipo $1 porque $2 a $RECHDIR ."  "I"
	#Mueve el archivo al directorio de rechazados.
	perl -I$BINDIR -Mfunctions -e "functions::Mover_B('$ARRIDIR/$f', '$RECHDIR', 'Recibir_B')"
	return 0
}

function invocar_Reservar_B()
{
	#Siempre que Reservar_B.sh no este ejecutando, lanzar. Verificar con comando ps - GRABA EN LOG
	#Sino - GRABA EN LOG
	igp=`ps r -ef | grep -v grep | grep '[.]/Reservar_B.sh' | wc -l`
	if [ $igp -eq 0 ]
	then
		log1 "Comenzo la ejecucion del script Reservar_B.sh." "I"

		./Reservar_B.sh &
	else
		log1 "Reservar_B.sh ya se esta ejecutando." "A"
	fi 
	return 0
}

function verificar_archivos_nuevos()
{
	#Verifica si hay archivos en $ARRIDIR
	list=`ls -l $ACEPDIR | grep ^- | wc -l`
	if [ $list -eq 0 ]
	then
		return 0
	else
		return 1 
	fi
}

########################DAEMON START########################
verificar_inicializacion_ambiente
if [ $? -eq 0 ]
then
	log1 "La inicializacion de ambiente fue satisfactoria." "I"
else
	log1 "La inicializacion de ambiente fue erronea. Se cancela la ejecucion de Recibir_B" "SE"
	echo "La inicializacion de ambiente fue erronea. Se cancela la ejecucion de Recibir_B."
	exit 1
fi

verificar_archivos_maestros
if [ $? -eq 1 ]
then
	log1 "La validacion de los archivos maestros fue satisfactoria." "I"
else
	log1 "La validacion de los archivos maestros fue erronea. Se cancela la ejecucion de Recibir_B" "SE"
	echo "La validacion de los archivos maestros fue erronea. Se cancela la ejecucion de Recibir_B."
	exit 1
fi

verificar_ya_ejecutando
if [ $? -eq 0 ]
then
	log1 "El script Recibir_B no se encuentra en ejecucion." "I"
else
	log1 "El script Recibir_B esta actualmente en ejecucion. Se cancela la ejecucion de Recibir_B" "SE"
	echo "El script Recibir_B esta actualmente en ejecucion. Se cancela la ejecucion de Recibir_B."
	exit 1
fi

while true; do
	#Loopear en el directorio todos los archivos
	O=$IFS
	IFS=$(echo -en "\n\b")
	for f in `find $ARRIDIR -type f | awk 'BEGIN { FS = "/" } ; { print $NF }'`
	do
		validar_archivo_reservas
		res=$?
		if [ $res -eq 1 ]
		then
			mover_archivo_recibido_reservas
		elif [ $res -eq 2 ]
		then
			mover_archivo_rechazado "Reserva" "Correo Inexistente" 
		elif [ $res -eq 3 ]
		then
			mover_archivo_rechazado "Reserva" "Obra Inexistente"
		elif [ $res -eq 4 ]
		then
			mover_archivo_rechazado "Reserva" "Sala Inexistente"
		elif [ $res -eq 5 ]
		then
			mover_archivo_rechazado "Reserva" "Obra/Sala y Correo Inexistente"
		else
			validar_archivo_invitados
			if [ $res -eq 1 ]
				then
					mover_archivo_recibido_invitados
				else
					mover_archivo_rechazado "Desconocido" "Nombre Inválido"
			fi
		fi
	done
	IFS=$O

	verificar_archivos_nuevos
	if [ $? -eq 1 ]
	then
		invocar_Reservar_B
	fi
	
	#Obtener el tiempo de sleep de una variable
	sleep $SLEEPTIME

done
