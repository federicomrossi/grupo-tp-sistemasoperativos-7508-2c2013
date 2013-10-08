#!/bin/bash
# 
#############################################################################
# Trabajo práctico N°1
# Grupo 10
# 75.08 - Sistemas Operativos
# Facultad de Ingeniería
# Universidad de Buenos Aires
# #############################################################################
#
# COMANDO RESERVAR_B
# 
# Comando que se encarga de leer los archivos que se encuentran en el directorio $ACEPDIR.
# el cual contiene las resevas solicitadas y grabar sus registros en reservas confirmadas o en
# reservas no confirmadas, según la disponibilidad de butacas y validaciones efectuadas en 
# cuanto a formato, oportunidad y disponibilidad.
#
#
# Parámetros
# ##########
#
#
# Códigos de retorno
# ################
#
#


# Chequeamos que se haya realizado la inicialización de ambiente
# [ INSERTAR AQUÍ LA VERIFICACIÓN ]

# Inicializamos el Log
# [ INSERTAR AQUÍ INICIALIZACIÓN DEL LOG ]
# [ INSERTAR EL GRABADO INICIAL SOBRE EL LOG ]


##############################################################################################
# Constantes
readonly INVALIDO=1
readonly VALIDO=0

# Rechaza la reserva e imprime en el log el motivo de rechazo.
# Recibe como parametro el motivo del rechazo
function rechazarReserva() {
	local motivo=$1
	# echo "Reserva rechazada. Motivo: $1"
}

# Funcion que valida el campo fecha
# Si la fecha es correcta, devuelve 0. De lo contrario, devuelve 1.
# Recibe como parametros: 1- La fecha
function validarFecha() {
	local fecha_a_validar=$1
	local validez=""

	# Compruebo si la fecha esta vacia
	if [ -z "$fecha_a_validar" ]; then
		rechazarReserva "Error en los parametros ingresados en Reservar_B"
		return $INVALIDO
	else
		# Obtengo dia, mes y anio
		dia=`echo $fecha_a_validar | sed 's:\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\):\1:'`
		mes=`echo $fecha_a_validar | sed 's:\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\):\2:'`
		anio=`echo $fecha_a_validar | sed 's:\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\):\3:'`

		# Compruebo si corresponde a fecha de calendario:
		# - Busca en el calendario la fecha, si es valida devuelve 0
		validez=`date -d "$mes/$dia/$anio" > /dev/null 2>&1 ; echo $?`

		# - Si devuelve 0, entonces es una fecha valida
		# - Sino, devuelve un codigo de error 1
		if [ "$validez" == "0" ]; then
			return $VALIDO
		else
			rechazarReserva "Se ingreso una fecha invalida"
			return $INVALIDO
		fi
	fi
}

# Funcion que verifica que la fecha de la reserva caiga entre los 30 dias y los 2 dias de anticipacion.
# De ser una reserva con mucha anticipacion o muy poca, se rechaza.
# Recibe como parametros: 1- La fecha en formato dd/mm/aaaa
function verificarAnticipacion() {
	local fecha_funcion=$1
	local distancia_dias=0
	local hoy=`date +%D`

	if [ -z "$fecha_funcion" ]; then
		rechazarReserva "Fecha invalida"
	else

		# Invierto la fecha para obtener el formato mm/dd/aaaa
		fecha_funcion=`echo "${fecha_funcion}" | sed 's:\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\):\2/\1/\3:'`

		# Obtengo distancia entre fechas en funcion de 'dias'
		distancia_dias=$(( ( (`date --date="$fecha_funcion" +%s`) - (`date --date="$hoy" +%s`) ) / (60*60*24) ))

		# Si la reserva es para el dia actual o para el dia siguiente, la rechazo
		# Si ('dias' < 2), 
		if [ "$distancia_dias" -lt "2" ]; then

			# Si ('dias' >= 0) -> Rechazar
			if [ "$distancia_dias" -ge "0" ]; then
				rechazarReserva "Termino la entrega querido, mas rapido la proxima vez"
				# Se devuelve el estado 1
				return $INVALIDO

			# Si es para una fecha vencida, la rechazo
			elif [ "$distancia_dias" -lt "0" ]; then
				rechazarReserva "La fecha de la funcion esta mas vencida que mi dulce de leche"
				# Se devuelve el estado 1
				return $INVALIDO

			fi
		else
			# Si la reserva tiene mas de 30 dias de anticipacion, la rechazo
			# ('dias' > 30)
			if [ "$distancia_dias" -gt "30" ]; then
				rechazarReserva "Tas apurado que pedis con tanta anticipacion?"
				# Se devuelve el estado 1
				return $INVALIDO
			else
				# Se devuelve el estado 1
				return $VALIDO
				echo "U r good 2 go!!!!!"
			fi
		fi
	fi
}

# Funcion que verifica que la hora sea valida
# Recibe como parametro la hora, si no está en formato hh:mm -> se rechaza
function validarHora() {
	local validez_hora=`date --date="$1" &> /dev/null; echo $?`
	if [ "$validez_hora" == "0" ]; then
		return $VALIDO
	else
		rechazarReserva "Hora de la función invalida"
		return $INVALIDO
	fi
}




# DEBUG: Se debe cambiar el path ingresado por la variable de entorno:

#nombre="Wiii/miArch.txt"
#regex2="\b([0-9a-zA-Z\.]+/)*(([0-9a-zA-Z]+)(\.[0-9a-zA-Z]+)?)\b"
#regex="s:(/?)(\([0-9a-zA-Z]+)(.[0-9a-zA-Z]+)?\)$:PROCESAR/\1:"
#patron_archivo="^[0-9]\+-[^ @]\+@[^ @\.]\+.[a-zA-Z]\+-[^ -]*$"


#paso=`grep -x ${regex2} "./"`
#echo "Processing $nombre file..."
#echo "Processing $paso file..."


# DEBUG: Por ahora el path de la carpeta arribos se define 
ACEPDIR="./aceptados/"
# Variables
cant_archivos=0
nombre_archivo=""
cant_lineas_arch=0
linea=""
fecha=""
ret_val=0

# Busca la cantidad de archivos contenidos en el directorio
cant_archivos=`ls -p $ACEPDIR | wc -l`
# Para cada archivo...
for j in `seq 1 ${cant_archivos}`; do
	# Obtengo el nombre de un archivo
	nombre_archivo=`ls -1p $ACEPDIR | head -n 1`
	
	# Obtiene la cantidad de registros en el archivo (1 reg por linea)
	cant_lineas_arch=`wc -l < $ACEPDIR${nombre_archivo}`

	# Para cada registro...
	for i in `seq 1 ${cant_lineas_arch}`; do
		linea=`head -n $i $ACEPDIR${nombre_archivo} | tail -n 1`

	#	grep '^[0-9]*;\([0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}\);[0-9]\{2\}:[0-9]\{2\};[a-zA-Z]*;[a-zA-Z]*;[0-9]\+;[a-zA-Z]*' Docu

		# Levanto el campo 2, que es el de la fecha
		fecha=`echo ${linea} | cut -d ';' -f "2"`

		# Se valida la fecha
		ret_val=`validarFecha $fecha; echo $?`

		if [ "$ret_val" == "0" ]; then

			# Se comprueba si se trata de una fecha vencida o muy anticipada
			ret_val=`verificarAnticipacion $fecha; echo $?`

			if [ "$ret_val" == "0" ]; then
				# Obtengo la hora, que es el campo 3
				hora=`echo ${linea} | cut -d ';' -f "3"`

				# Se comprueba que la hora de la funcion sea correcta
				ret_val=`validarHora $hora; echo $?`

				echo "La hora $hora tiene validez: $ret_val"
			fi
		fi

	done
done

# FILES=../*
# # Iteramos sobre los archivos del directorio
# for f in $FILES
# do
#         # Procesamos solo los que son archivos
#         if [ -f $f ]; then

#                 # Verificamos si ya ha sido procesado el archivo anteriormente
#                 `ls -l -lp Mover_B.pl &> /dev/null`
#                 res=$?

#                 # Si se encontró el archivo, está duplicado
#                 if [ "$res" -eq "0" ]; then

#                         # Movemos archivo a $RECHDIR
#                         'perl ./Mover_B.pl $f $RECHDIR Reservar_B'

#                         # Generamos entrada nueva en el log informando la situación
#                         echo "todo piola"

#                 # Caso en que no se encontró el archivo duplicado        
#                 else
#                         # Movemos archivo a $PROCDIR
#                         'perl ./Mover_B.pl $f $PROCDIR Reservar_B'
#                 fi
#         fi
# done