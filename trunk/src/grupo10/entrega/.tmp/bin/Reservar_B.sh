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
# Comando que se encarga de leer los archivos que se encuentran en el directorio $ACEPDIR
# (que contiene las resevas solicitadas) y grabar sus registros en reservas confirmadas o en
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

##############################################################################################
# Constantes
readonly INVALIDO=1
readonly VALIDO=0
# Constante que representa caracteres ascii salvo el delimitador ';'
readonly ASCII_SIN_PC="[\x00-\x3A|\x3C-\x7F]"
# Constante que representa caracteres ascii salvo el delimitador '-'
readonly ASCII_SIN_G="[\x00-\x2C|\x2E-\x7F]"
# Constante que representa caracteres ascii y no ascii, salvo el delimitador ';'
readonly CHAR_SIN_PC="[\x00-\x3A|\x3C-\xFF]"
# Constante que representa caracteres ascii y no ascii, salvo el delimitador '-'
readonly CHAR_SIN_G="[\x00-\x2C|\x2E-\xFF]"
# Constante que representa caracteres ascii y no ascii, salvo el delimitador '.'
readonly CHAR_SIN_P="[\x00-\x2D|\x2F-\xFF]"
# Constante que representa caracteres ascii y no ascii, salvo los char ';' y '/'
readonly CHAR_SIN_PCyB="[\x00-\x2E|\x30-\x3A|\x3C-\xFF]"
# Constante que representa caracteres ascii y no ascii, salvo los char ';' y ':'
readonly CHAR_SIN_PCyDP="[\x00-\x39|\x3C-\xFF]"

# DEBUG: Deben cambiar
readonly LOG_PATH="../log/Reservar_B.log"
readonly SCRIPTS="./"

# Funcion que escribe en el log
# Recibe como parametros: 1- Tipo de mensaje, 2- Mensaje
function log (){
    perl -I$SCRIPTS -Mfunctions -e "functions::Grabar_L('Reservar_B', '$1', '$2', '$LOG_PATH')"
}


# Funcion que valida que el archivo en cuestion no haya sido procesado antes.
# Devueve 0 si no fue procesado, y 1 en caso contrario.
# Recibe como parametro: 1- El nombre del archivo.
function validarDuplicados() {
	# Se obtiene el nombre del archivo sin la extension de repeticion
	local nombre_sin_duplicado=`echo $1 | grep -P "^[0-9]+-$CHAR_SIN_G+-$CHAR_SIN_P+"`

	# Si existe en $PROCDIR se descarta
	if [ -a "$PROCDIR/$nombre_sin_duplicado" ]; then
		return $INVALIDO
	else
		return $VALIDO
	fi
}

# Funcion que valida si el archivo esta vacio.
# Devuelve 0 si no esta vacio, y 1 en caso contrario.
# Recibe como parametros: 1- El nombre del archivo.
function validarTamanio() {
	# Si existe el archivo y ademas tiene tamaño mayor a 0
	if [ -s "$ACEPDIR$1" ]; then
		return $VALIDO
	else
		return $INVALIDO
	fi
}

# Funcion que valida el archivo, es decir: comprueba si esta vacio o si fue ya procesado. 
# Si es valido, devuelve un codigo de 0, sino devuelve 1 y el motivo del rechazo.
# Recibe como parametro: 1- El nombre del archivo
function archivoValido() {
	local ret_val_AV=0

	# Verifico si el archivo esta duplicado, es decir, ya ha sido procesado
	ret_val_AV=`validarDuplicados $1; echo $?`

	# Si fue procesado, se devuelve 1
	if [ "$ret_val_AV" != "0" ]; then
		echo "El archivo $1 ya fue procesado."
		return $INVALIDO
	fi

	# Sino, se analiza si esta vacio
	ret_val_AV=`validarTamanio $1; echo $?`

	# Si esta vacio, devuelve 1
	if [ "$ret_val_AV" != "0" ]; then
		echo "El archivo $1 se encuentra vacio"
		return $INVALIDO
	fi

	# Sino, se analiza que los campos obligatorios esten presentes
	# ret_val_AV=`grep -c -v "^[^;]*;[^;/]\+/[^;/]\+/[^;/]\+;[^;:]\+:[^;:]\+;[^;]*;[^;]*;[0-9]\+;[^;]*$" "$ACEPDIR$1"`
	ret_val_AV=`grep -c -v -P "^$CHAR_SIN_PC*;$CHAR_SIN_PCyB+/$CHAR_SIN_PCyB+/$CHAR_SIN_PC+;$CHAR_SIN_PCyDP+:$CHAR_SIN_PC+;$CHAR_SIN_PC*;$CHAR_SIN_PC*;[0-9]+;$CHAR_SIN_PC*$" "$ACEPDIR$1"`
	
	# Si hay 1 o mas lineas invalidas, entonces se rechaza el archivo completo
	if [ "$ret_val_AV" != "0" ]; then
		echo "El archivo $1 tiene $ret_val_AV registros invalidos."
		return $INVALIDO
	fi

	return $VALIDO

}

# Funcion que procesa linea por linea el archivo que recibe. Realiza comprobaciones
# de campos, valida los registros y por ultimo procesa la información contenida.
# Recibe como parametro: 1El nombre del archivo
function procesarArchivo() {
	# Variables
	local linea=""
	local ret_val_PA=0
	local motivo=""
	local cant_lineas_arch=0
	local fecha=""
	local hora=""
	local id=""
	local id_combo=0
	local combo=""
	local cant_butacas=0
	local cant_reservas_ok=0
	local cant_reservas_nok=0
	

	# Obtiene la cantidad de registros en el archivo (1 reg por linea)
	cant_lineas_arch=`wc -l < $ACEPDIR${1}`
	cant_lineas_arch=$(( $cant_lineas_arch + 1 ))

	# Se obtiene el ID que aparece al comienzo en el nombre del archivo.
	# El separador de campos es el '-'
	id=`echo $1 | cut -d '-' -f "1"`

	# Para cada registro...
	for i in `seq 1 ${cant_lineas_arch}`; do
		linea=`head -n $i $ACEPDIR${1} | tail -n 1`

		# Levanto el campo 2, que es el de la fecha
		fecha=`echo ${linea} | cut -d ';' -f "2"`

		# Se valida la fecha
		motivo=`validarFecha $fecha`
		ret_val_PA=`echo $?`

		# Si no es valida, se rechaza la reserva y se procesa otra linea del archivo
		if [ "$ret_val_PA" != "0" ]; then
			# Se rechaza la reserva
			rechazarReserva "$linea" "$motivo" "$1"
			# Se contabiliza un registro mas invalido
			cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
			continue
		fi

		# Se comprueba si se trata de una fecha vencida o muy anticipada
		motivo=`verificarAnticipacion $fecha`
		ret_val_PA=`echo $?`

		# Si la reserva tiene mas de 30 dias de anticipacion o menos de 2, se rechaza la reserva y se lee la siguiente linea
		if [ "$ret_val_PA" != "0" ]; then
			# Se rechaza la reserva
			rechazarReserva "$linea" "$motivo" "$1"
			# Se contabiliza un registro mas invalido
			cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
			continue
		fi

		# Obtengo la hora, que es el campo 3
		hora=`echo ${linea} | cut -d ';' -f "3"`

		# Se comprueba que la hora de la funcion sea correcta
		motivo=`validarHora $hora`
		ret_val_PA=`echo $?`

		# Si la hora no es valida, se rechaza la reserva y se lee la siguiente linea
		if [ "$ret_val_PA" != "0" ]; then
			# Se rechaza la reserva
			rechazarReserva "$linea" "$motivo" "$1"
			# Se contabiliza un registro mas invalido
			cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
			continue
		fi

		# Se comprueba que se trate de un evento existente y ademas, se recibe
		# el combo correspondiente
		combo=`validarEvento $id $fecha $hora`

		# Si no existe el evento seleccionado, se lee el siguiente registro
		if [ "$combo" == "null" ]; then
			# Se rechaza la reserva
			motivo="El evento seleccionado no existe"
			rechazarReserva "$linea" "$motivo" "$1"
			# Se contabiliza un registro mas invalido
			cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
			continue
		fi

		# Se obtuvo el combo, entonces se parsea el ID Combo y se guarda
		id_combo=`echo $combo | cut -d ';' -f "1"`
		id_combo=`echo $id_combo | sed "s:^C\?\([0-9]\+\):\1:"`

		# Obtengo la cantidad de butacas requeridas, que es el campo 6
		cant_butacas=`echo $linea | cut -d ';' -f "6"`

		# Si piden 0 butacas o menos, se rechaza la reserva
		if [ "$cant_butacas" -le "0" ]; then
			# Se rechaza la reserva
			motivo="Se seleccionó una cantidad incorrecta de butacas."
			rechazarReserva "$linea" "$motivo" "$1"
			# Se contabiliza un registro mas invalido
			cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
			continue
		fi

		# Se comprueba que haya disponibilidad en tal evento
		####### NOTA IMP: Lo siguiente sirve solo para BASH 4 en adelante ##########

		# Si existe un registro en la tabla de disponibilidades, entonces uso ese valor
		if [ -n "${disponibilidades["$id_combo"]}" ]; then

			# Si hay mas o igual cantidad de butacas disponibles, entonces acepto
			if [ "${disponibilidades["$id_combo"]}" -ge "$cant_butacas" ]; then
				disponibilidades=( ["$id_combo"]=$(( ${disponibilidades["$id_combo"]} - $cant_butacas )) )
			else
				# Si no hay lugar, se rechaza la reserva
				motivo="No hay la suficiente cantidad de butacas para aceptar la reserva"
				rechazarReserva "$linea" "$motivo" "$1"
				# Se contabiliza un registro mas invalido
				cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
				continue
			fi
		else
			# Si no existe un registro en la tabla, se levanta del archivo la disponibilidad correspondiente
			# butacas_disponibles=`grep "^C\?$id_combo;[^;]\+;[^;]\+;[^;]\+;[^;]\+;[^;]\+;[^;]\+;[^;]\+$" "$PROCDIR/combos.dis"`
			butacas_disponibles=`grep -P "^C?$id_combo;[0-9]+;$CHAR_SIN_PC+;$CHAR_SIN_PC+;[0-9]+;[0-9]+;[0-9]+;$CHAR_SIN_PC+$" "$PROCDIR/combos.dis"`
			# butacas_disponibles=`grep "^C\?$id_combo" "$PROCDIR/combos.dis"`

			butacas_disponibles=`echo $butacas_disponibles | cut -d ';' -f "7"`

			# Se chequea si hay butacas suficientes
			if [ "$butacas_disponibles" -ge "$cant_butacas" ]; then
				# Si hay, se acepta la reserva
				butacas_disponibles=$(( $butacas_disponibles - $cant_butacas ))
			else
				# Si no hay butacas suficientes, se rechaza la reserva
				motivo="No hay la suficiente cantidad de butacas para aceptar la reserva"
				rechazarReserva "$linea" "$motivo" "$1"
				# Se contabiliza un registro mas invalido
				cant_reservas_nok=$(( $cant_reservas_nok + 1 ))
				continue
			fi

			# Se agrega en la tabla
			disponibilidades+=( ["$id_combo"]="$butacas_disponibles" )
		fi

		# Se procede a aceptar la reserva, ya que esta paso todas las validaciones
		aceptarReserva "$linea" "$1" "$combo"

		# Se contabiliza como reserva OK
		cant_reservas_ok=$(( $cant_reservas_ok + 1 ))

	done

	# Se graba la cantidad de reservas OK y NOK
	log "I" "Se finalizo el proceso del archivo $1. Cantidad de reservas aceptadas: $cant_reservas_ok. Cantidad de reservas rechazadas: $cant_reservas_nok."

	# Se graba un mensaje de debug, en el cual: #Registros = #Aceptados + #Rechazados
	log "D" "$cant_lineas_arch (registros) = $cant_reservas_ok (reservas aceptadas) + $cant_reservas_nok (reservas rechazadas)"

}

# Funcion que guarda un mensaje en el log de archivo invalido y además
# traslada el archivo hacia el directorio $RECHDIR.
# Recibe como parametros: 1- El nombre del archivo, 2- Motivo rechazo
function rechazarArchivo() {
    # Movemos archivo a $RECHDIR
    perl ./Mover_B.pl "$ACEPDIR$1" "$RECHDIR" "Reservar_B"
    
    # Se graba en el log un mensaje aclaratorio
    log "M" "El archivo se rechaza por el siguiente motivo: $2"
}

# Funcion que rechaza la reserva e imprime en el log el motivo de rechazo.
# Esta funcion graba un registro en el archivo 'reservas.nok'
# Recibe como parametros: 1- El registro completo a rechazar, 2- El motivo del rechazo
# 3- El nombre del archivo
function rechazarReserva() {
	local id_sala=""
	local id_obra=""
	local correo=""
	local fecha_hoy=""
	local usuario=""
	local registro_nok=""

	# Obtengo el id a partir del nombre del archivo
	id_sala=`echo $3 | cut -d '-' -f "1"`

	# Si se trata de un ID par, la clave es el ID Sala. Sino, se trata de un ID Obra.
	if [ $(( $id_sala % 2 )) == "0" ]; then
		# Es un ID Sala
		id_obra="falta OBRA"
	else
		# Es un ID Obra
		id_obra=$id_sala
		id_sala="falta SALA"
	fi

	# Obtengo el correo a partir del nombre del archivo
	correo=`echo $3 | cut -d '-' -f "2"`

	# Obtengo la fecha del dia
	fecha_hoy=`date +%D`

	# Obtengo el usuario logueado actualmente
	usuario=`id -u -n`

	# Se arma el registro a guardar en el archivo
	registro_nok="$1;$2;$id_sala;$id_obra;$correo;$fecha_hoy;$usuario"

	# Se escribe el registro
	echo "$registro_nok" >> "$PROCDIR/reservas.nok"
}

# Funcion que graba en el archivo 'reservas.ok' el registro correspondiente a la reserva
# correctamente realizada. 
# Recibe como parametros: 1- El registro completo a aceptar, 2- Nombre del archivo, 3- Combo
function aceptarReserva() {
	# Se leen los campos del primer argumento
	local ref_interna=`echo $1 | cut -d ';' -f "1"`
	local fecha_evento=`echo $1 | cut -d ';' -f "2"`
	local hora_evento=`echo $1 | cut -d ';' -f "3"`
	local butacas_solicitadas=`echo $1 | cut -d ';' -f "6"`

	# Se leen los campos del 2do argumento
	local correo_solicitante=`echo $2 | cut -d '-' -f "2"`

	# Se leen los parametros del 3er argumento
	local id_obra=`echo $3 | cut -d ';' -f "2"`
	local id_sala=`echo $3 | cut -d ';' -f "5"`
	local id_combo=`echo $3 | cut -d ';' -f "1"`

	# Se obtiene la fecha actual
	local fecha_hoy=`date +%D`

	# Se obtiene el usuario logueado actualmente
	local usuario=`id -u -n`

	# Se obtiene la informacion que resta
	local nombre_obra=`grep -P "^$id_obra" "$MAEDIR/obras.mae"`
	nombre_obra=`echo $nombre_obra | cut -d ';' -f "2"`

	local nombre_sala=`grep -P "^$id_sala" "$MAEDIR/obras.mae"`
	nombre_sala=`echo $nombre_sala | cut -d ';' -f "2"`

	# Se arma el registro
	local registro_ok="$id_obra;$nombre_obra;$fecha_evento;$hora_evento;$id_sala;$nombre_sala;$butacas_solicitadas;$id_combo;$ref_interna;$butacas_solicitadas;$correo_solicitante;$fecha_hoy;$usuario"

	# Se graba en el archivo
	echo "$registro_ok" >> "$PROCDIR/reservas.ok"

}


# Funcion que valida el campo fecha.
# Si la fecha es correcta, devuelve 0. De lo contrario, devuelve 1.
# Recibe como parametros: 1- La fecha
function validarFecha() {
	local fecha_a_validar=$1
	local validez=""

	# Compruebo si la fecha esta vacia
	if [ -z "$fecha_a_validar" ]; then
		echo "Error en los parametros ingresados en Reservar_B"
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
			echo "Se ingreso una fecha invalida"
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
		echo "Fecha invalida"
		return $INVALIDO
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
				echo "Reserva realizada con menos de 2 dias de anticipacion"
				# Se devuelve el estado 1
				return $INVALIDO

			# Si es para una fecha vencida, la rechazo
			elif [ "$distancia_dias" -lt "0" ]; then
				echo "La fecha ingresada no corresponde con un evento vigente"
				# Se devuelve el estado 1
				return $INVALIDO

			fi
		else
			# Si la reserva tiene mas de 30 dias de anticipacion, la rechazo
			# ('dias' > 30)
			if [ "$distancia_dias" -gt "30" ]; then
				echo "Reserva realizada con mas de 30 dias de anticipacion"
				# Se devuelve el estado 1
				return $INVALIDO
			else
				# Se devuelve el estado 1
				return $VALIDO
			fi
		fi
	fi
}

# Funcion que verifica que la hora de la reserva sea valida. Si no está en formato hh:mm -> se rechaza
# Recibe como parametro: 1- La hora.
function validarHora() {
	# Si el campo hora esta vacio, se devuelve 1
	if [ -z "$1" ]; then
		return $INVALIDO
	fi

	# Sino, se comprueba que se trate de una hora con formato hh:mm
	local validez_hora=`date --date="$1" &> /dev/null; echo $?`

	if [ "$validez_hora" == "0" ]; then
		return $VALIDO
	else
		echo "Hora de la función invalida"
		return $INVALIDO
	fi
}

# Funcion que valida si el evento pedido existe. Es decir, comprueba
# si existe un evento con el respectivo ID, Fecha y Hora. En vaso de existir, devuelve
# el combo correspondiente al evento. Sino, devuelve 'null' indicando la no existencia
# del evento seleccionado.
# Recibe como parametros: 1- ID, 2- Fecha, 3- Hora.
function validarEvento() {
	local id_evento=$1
	local fecha_evento=$2
	local hora_evento=$3
	local combo_evento=0

	# Si se trata de un ID par, la clave es el ID Sala. Sino, se trata de un ID Obra.
	if [ $(( $id_evento % 2 )) == "0" ]; then
		# Es un ID Sala
		combo_evento=`grep -P "C?[0-9]+;[0-9]+;$fecha_evento;$hora_evento;$id_evento;[0-9]+;[0-9]+;$CHAR_SIN_PC+" "$PROCDIR/combos.dis"`
	else
		# Es un ID Obra
		combo_evento=`grep -P "C?[0-9]+;$id_evento;$fecha_evento;$hora_evento;[0-9]+;[0-9]+;[0-9]+;$CHAR_SIN_PC+" "$PROCDIR/combos.dis"`
	fi

	# Si el evento no es valido, se rechaza la reserva
	if [ "$?" != "0" ]; then
		echo "null"
	else
		# Sino, se devuelve 0 y se devuelve el valor del combo de este evento
		echo "$combo_evento"
	fi
}


# Funcion que persiste en el archivo 'combos.dis' las disponibilidades actualizadas.
# No recibe parametros
function guardarDisponibilidades() {
	# Se guarda la cantidad de elementos en la tabla
	local id_c=0

	# Para cada elemento, se lo busca en el archivo y se lo actualiza
	for id_c in ${!disponibilidades[*]}; do

		sed -i "s:^\([C]\?$id_c;[0-9]\+;[^;]\+;[^;]\+;[0-9]\+;[0-9]\+\);[0-9]\+:\1;${disponibilidades[$id_c]}:" "$PROCDIR/combos.dis"

	done

	log "I" "Actualización del archivo de disponibilidad"
}


###### Programa principal ######


# DEBUG: Por ahora el path de la carpeta arribos se define 
ACEPDIR="../aceptados/"
PROCDIR="../procesados/"
MAEDIR="../mae/"
RECHDIR="../rechazados/"

# Variables
cant_elementos=0
ret_val=0
motivo_rechazo=""
# Tabla que contiene las disponibilidades de los eventos
declare -A disponibilidades

# Busca la cantidad de elementos contenidos en el directorio
cant_elementos=`ls -p $ACEPDIR | wc -l`

# Se graba en el log el inicio de este comando y la cantidad de archivos a procesar
log "I" "Inicio de Reservar_B. Hay $cant_elementos archivos en $ACEPDIR"

# Para cada elemento...
for j in `seq 1 ${cant_elementos}`; do
	# Obtengo el nombre de un elemento
	nombre_archivo=`ls -1p $ACEPDIR | head -n 1`

	log "I" "Archivo a procesar: $nombre_archivo."

	# Si se trata de un archivo,
	if [ -f $ACEPDIR$nombre_archivo ]; then
		# Se analiza si es valido
		motivo_rechazo=`archivoValido $nombre_archivo`
		ret_val=`echo $?`

		# Si es valido, entonces se procesa
		if [ "$ret_val" == "0" ]; then
			# Se procesa el archivo
			procesarArchivo $nombre_archivo

			# Y se mueve a $PROCDIR
    		perl ./Mover_B.pl "$ACEPDIR$nombre_archivo" "$PROCDIR" "Reservar_B"

			# Se persiste la tabla de disponibilidades en el archivo 'combos.dis'
			guardarDisponibilidades

		else
			# Si no es un archivo valido, se mueve a RECHDIR
			rechazarArchivo "$nombre_archivo" "$motivo_rechazo"
		fi
	# Si es un directorio, se trata de la carpeta de duplicados -> se rechazan todos los archivos
	elif [ -d $ACEPDIR$nombre_archivo ]; then
		# Busca la cantidad de elementos contenidos en el directorio
		cant_elementos_dup=`ls -p $ACEPDIR$nombre_archivo | wc -l`

		# Para cada elemento...
		for k in `seq 1 ${cant_elementos_dup}`; do
			# Obtengo el nombre de un elemento
			nombre_archivo_dup=`ls -1p $ACEPDIR$nombre_archivo | head -n 1`

			motivo_rechazo="Archivo $nombre_archivo_dup se encuentra duplicado"

			# Se mueve a RECHDIR
			rechazarArchivo "$nombre_archivo_dup" "$motivo_rechazo"
		done

	else
		log "E" "$nombre_archivo tiene un tipo de archivo incorrecto"
	fi

done

log "I" "Fin de Reservar_B"
