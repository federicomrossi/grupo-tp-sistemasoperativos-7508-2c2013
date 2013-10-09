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

# Funcion que valida que el archivo en cuestion no haya sido procesado antes
# Recibe como parametro el nombre del archivo.
# Devueve 0 si no fue procesado, y 1 en caso contrario
function validarDuplicados() {
	return 0
}

# Funcion que valida si el archivo esta vacio
# Recibe como parametros el nombre del archivo
# Devuelve 0 si no esta vacio, y 1 en caso contrario
function validarTamanio() {
	return 0
}

# Funcion que valida el archivo, es decir: comprueba si esta vacio o si fue ya procesado. 
# Si es valido, devuelve un codigo de 0, sino devuelve 1.
# Recibe como parametro el nombre del archivo
function archivoValido() {
	local ret_val_AV=0
	# Verifico si el archivo esta duplicado, es decir, ya ha sido procesado
	ret_val_AV=`validarDuplicados $1; echo $?`

	# Si no fue procesado,
	if [ "$ret_val_AV" == "0" ]; then
		# Se analiza si esta vacio
		ret_val_AV=`validarTamanio $1; echo $?`

		# Si no esta vacio, devuelve 0
		if [ "$ret_val_AV" == "0" ]; then
			return $VALIDO
		else
			# Si esta vacio, devuelve 1
			return $INVALIDO
		fi

	else
		# Si ya fue procesado, devuelve 1
		return $INVALIDO
	fi
}

# Funcion que procesa linea por linea el archivo que recibe como parametros.
# Una vez procesado, traslada el archivo hacia el directorio $PROCDIR
# Recibe como parametro el nombre del archivo
function procesarArchivo() {
	# Variables
	local linea=""
	local ret_val_PA=0
	local cant_lineas_arch=0
	local fecha=""
	local hora=""
	local id=""
	local id_combo=0
	local cant_butacas=0

	# Obtiene la cantidad de registros en el archivo (1 reg por linea)
	cant_lineas_arch=`wc -l < $ACEPDIR${1}`

	# Se obtiene el ID que aparece al comienzo en el nombre del archivo.
	# El separador de campos es el '-'
	id=`echo $1 | cut -d '-' -f "1"`

	# Para cada registro...
	for i in `seq 1 ${cant_lineas_arch}`; do
		linea=`head -n $i $ACEPDIR${1} | tail -n 1`

	#	grep '^[0-9]*;\([0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}\);[0-9]\{2\}:[0-9]\{2\};[a-zA-Z]*;[a-zA-Z]*;[0-9]\+;[a-zA-Z]*' Docu

		# Levanto el campo 2, que es el de la fecha
		fecha=`echo ${linea} | cut -d ';' -f "2"`

		# Se valida la fecha
		ret_val_PA=`validarFecha $fecha; echo $?`

		# Si no es valida, se procesa otra linea del archivo
		if [ "$ret_val_PA" != "0" ]; then
			continue
		fi

		# Se comprueba si se trata de una fecha vencida o muy anticipada
		ret_val_PA=`verificarAnticipacion $fecha; echo $?`

		# Si la reserva es muy anticipada o es poco anticipada, se lee la siguiente linea
		if [ "$ret_val_PA" != "0" ]; then
			continue
		fi

		# Obtengo la hora, que es el campo 3
		hora=`echo ${linea} | cut -d ';' -f "3"`

		# Se comprueba que la hora de la funcion sea correcta
		ret_val_PA=`validarHora $hora; echo $?`

		# echo "La hora $hora tiene validez: $ret_val_PA"

		# Si la hora no es valida, se lee la siguiente linea
		if [ "$ret_val_PA" != "0" ]; then
			continue
		fi

		# Se comprueba que se trate de un evento existente y ademas, se recibe
		# el ID Combo correspondiente
		id_combo=`validarEvento $id $fecha $hora`

		# echo "El evento tiene id Combo: $id_combo"

		# Si no existe el evento seleccionado, se lee el siguiente registro
		if [ "$id_combo" == "null" ]; then
			continue
		fi

		# Obtengo la cantidad de butacas requeridas, que es el campo 6
		cant_butacas=`echo $linea | cut -d ';' -f "6"`

		# Se comprueba que haya disponibilidad en tal evento
		###### NOTA IMP: Lo siguiente sirve solo para BASH 4 en adelante ##########
		ret_val_PA=`comprobarDisponibilidad $id_combo $cant_butacas; echo $?`

		echo "Estado de disponibilidad: $ret_val_PA"


	done

}

# Funcion que guarda un mensaje en el log de archivo invalido y además
# traslada el archivo hacia el directorio $RECHDIR
# Recibe como parametro el nombre del archivo
function rechazarArchivo() {
	return 0
}

# Rechaza la reserva e imprime en el log el motivo de rechazo.
# Esta funcion graba un registro en el archivo 'reservas.nok'
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
				rechazarReserva "Reserva realizada con menos de 2 dias de anticipacion"
				# Se devuelve el estado 1
				return $INVALIDO

			# Si es para una fecha vencida, la rechazo
			elif [ "$distancia_dias" -lt "0" ]; then
				rechazarReserva "La fecha ingresada no corresponde con un evento vigente"
				# Se devuelve el estado 1
				return $INVALIDO

			fi
		else
			# Si la reserva tiene mas de 30 dias de anticipacion, la rechazo
			# ('dias' > 30)
			if [ "$distancia_dias" -gt "30" ]; then
				rechazarReserva "Reserva realizada con mas de 30 dias de anticipacion"
				# Se devuelve el estado 1
				return $INVALIDO
			else
				# Se devuelve el estado 1
				return $VALIDO
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

# Funcion que valida si el evento pedido existe. Es decir, comprueba
# si existe un evento con el respectivo ID, Fecha y Hora. En vaso de existir, devuelve
# el numero de combo correspondiente al evento. Sino, devuelve 'null' indicando la no existencia
# del evento seleccionado
# Recibe como parametros: 1- ID, 2- Fecha, 3- Hora.
function validarEvento() {
	local id_evento=$1
	local fecha_evento=$2
	local hora_evento=$3
	local id_combo_evento=0

	# Si se trata de un ID par, la clave es el ID Sala. Sino, se trata de un ID Obra.
	if [ $(( $id_evento % 2 )) == "0" ]; then
		# Es un ID Sala
		id_combo_evento=`grep "C\?[0-9]\+;[0-9]\+;$fecha_evento;$hora_evento;$id_evento;[0-9]\+;[0-9]\+;[^;]\+" "$PROCDIR/combos.dis"`
	else
		# Es un ID Obra
		id_combo_evento=`grep "C\?[0-9]\+;$id_evento;$fecha_evento;$hora_evento;[0-9]\+;[0-9]\+;[0-9]\+;[^;]\+" "$PROCDIR/combos.dis"`
	fi

	# Si el evento no es valido, se rechaza la reserva
	if [ "$?" != "0" ]; then
		rechazarReserva "Los datos ingresados no corresponden a un evento existente"
		echo "null"
	else
		# Sino, se devuelve 0 y se guarda en el ultimo parametro el valor de id_combo de este evento
		id_combo_evento=`echo $id_combo_evento | sed "s:\(C\?[0-9]\+\);.\+:\1:"`
		echo "$id_combo_evento"
	fi
}

# Funcion que comprueba si para cierto evento existente, hay disponibilidad o no.
# Devuelve 0 si hay lugar, o 1 en caso contrario.
# Recibe como parametros: 1- ID Combo, 2- Cantidad butacas requeridas
function comprobarDisponibilidad() {
	local estado=0

	# Si existe un registro en la tabla de disponibilidades, entonce uso ese valor
	if [ -n "${disponibilidades["$1"]}" ]; then
		# Si hay mas o igual cantidad de butacas disponibles, entonces acepto
		if [ "${!disponibilidades["$1"]}" -ge "$2" ]; then
			echo "Miro tabla y habian ${!disponibilidades["$1"]} butacas"
			disponibilidades=( ["$1"]=$(( ${!disponibilidades["$1"]} - $2 )) )
			export disponibilidades
			echo "Miro Tabla. Hay lugar y quedan ${!disponibilidades["$1"]} butacas"
			return $VALIDO
		else
			echo "Miro Tabla. No hay lugar"
			return $INVALIDO
		fi
	else
		# Sino, se levanta del arcihvo la disponibilidad correspondiente
		butacas_disponibles=`grep "^C\?[0-9]\+;.\+" "$PROCDIR/combos.dis"`
		butacas_disponibles=`echo $butacas_disponibles | sed "s:C\?[0-9]\+;\([^;]\+;\)\{5\}\([0-9]\+\);[^;]\+:\2:"`

		# Se chequea si hay espacio suficiente
		if [ "$butacas_disponibles" -ge "$2" ]; then
			butacas_disponibles=$(( $butacas_disponibles - $2 ))
			echo "Habia lugar en archivo y quedan $butacas_disponibles porque pidieron $2"
			estado=$VALIDO
		else
			estado=$INVALIDO
		fi

		# Se agrega en la tabla
		disponibilidades=( ["$1"]="$butacas_disponibles" )

		export disponibilidades


		echo "Miro archivo. Hay ${disponibilidades["$1"]} butacas disponibles"
		
		# Se devuelve el estado
		return $estado
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
PROCDIR="./procesados/"
# Variables
cant_elemetos=0
ret_val=0
# Tabla que contiene las disponibilidades de los eventos
declare -A disponibilidades

# Busca la cantidad de elementos contenidos en el directorio
cant_elemetos=`ls -p $ACEPDIR | wc -l`
# Para cada elemento...
for j in `seq 1 ${cant_elemetos}`; do
	# Obtengo el nombre de un elemento
	nombre_archivo=`ls -1p $ACEPDIR | head -n 1`

	# Si se trata de un archivo
	if [ -f $ACEPDIR$nombre_archivo ]; then
		# Se analiza si es valido
		ret_val=`archivoValido $nombre_archivo; echo $?`

		# Si es valido, entonces se procesa
		if [ "$ret_val" == "0" ]; then
			echo "Proceso archivo $nombre_archivo"
			procesarArchivo $nombre_archivo
		else
			echo "Descarto archivo $nombre_archivo"
			# Si no es un archivo valido, se mueve a RECHDIR
			rechazarArchivo $nombre_archivo
		fi
	elif [ -d $ACEPDIR$nombre_archivo ]; then
		echo "Se trata de un dir"
	else
		echo "Algo anda mal"
	fi
	
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
