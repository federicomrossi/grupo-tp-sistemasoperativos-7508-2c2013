#!/bin/sh
# Comando Interprete
# Este comando se encarga de leer los archivos que se encuentran en el directorio $ACEPDIR y graba los registros formateados en archivos de prestamos por pais.

# Archivos Input
#	Archivos Recibidos $ACEPDIR/<pais>-<sistema>-<año>-<mes>
#	Tabla de Separadores $CONFDIR/T1.tab
#	Tabla de Campos $CONFDIR/T2.tab

# Archivos Output
#	Archivos de Préstamos Personales por país $PROCDIR/PRESTAMOS.<pais>
#	Archivos (duplicados) Rechazados $RECHDIR/<nombre del archivo>
#	Archivos Procesados $PROCDIR/<pais>-<sistema>-<año>-<mes>
#	Log $LOGDIR/Interprete.$LOGEXT


# Escribe en el log asociado al Interprete el mensaje dado
# Parametros:
#	$1 Tipo de mensaje a grabar
#	$2 Mensaje a grabar
log () {
	# Verifico si se reciben los 2 parametros requeridos
	if [ $# -ne 2 ]; then
		echo "Error en funcion 'log' de Interprete.sh: Cantidad de parametros incorrecto"
		return 1
	else
		tipo=$1
		mensaje=$2
		GlogX.sh -c "Interprete" -m "$mensaje" -t "$tipo"
		return 0
	fi
}

# Graba en el log un mensaje de error por falta de informacion en T2 para procesar el archivo
# Parametros:
#	$1 Nombre del archivo que no se puede procesar
#	$2 Nombre del campo faltante que no permite procesar el archivo
error_t2 () {
	if [ $# -ne 2 ]; then
		echo "Error en funcion 'error_t2' de Interprete.sh: Cantidad de parametros incorrecto"
		return 1
	else
		log "A" "La informacion de la tabla T2 es insuficiente para procesar el archivo $1: No se encuentra el campo $2"
		return 0
	fi
}

# Graba en el log un mensaje de error por la imposibilidad de procesamiento de un registro dado
# Parametros:
#	$1 Nombre del archivo origen del registro
#	$2 Numero de registro (linea) del archivo que contiene el error
#	$3 Campo del registro que contiene el error
error_registro () {
	if [ $# -ne 3 ]; then
		echo "Error en funcion 'error_registro' de Interprete.sh: Cantidad de parametros incorrecto"
		return 1
	else
		log "A" "El registro $2 del archivo $1 no pudo ser procesado: El campo $3 no cumple con el formato especificado"
		return 0
	fi
}

# Verifica si el numero de punto flotante cumple con la longitud especificada
# Parametros:
#	$1 Numero a verificar
#	$2 Separador de punto flotante
#	$3 Longitud maxima de la parte entera del numero
#	$4 Longitud maxima de la parte decimal del numero
#
# Retorno:
#	0 si el numero cumple con las longitudes especificadas
#	1 si el numero NO cumple con las longitudes especificadas
#	2 si la cantidad de parametros es incorrecta
verificar_longitudes () {
	if [ $# -ne 4 ]; then
		echo "Error en funcion 'verificar_longitud' de Interprete.sh: Cantidad de parametros incorrecto"
		return 2
	fi
	local num=$1
	local sep=$2
	local ent=$3
	local dec=$4
	# Si el numero son solamente numeros, se considera como un entero
	if [ -n "`echo $num | grep -x "[0-9]*"`" ]; then
		# Verifico si no supera la longitud maxima permitida
		if [ `echo $num | wc -L` -gt $ent ]; then
			return 1
		fi
	else
		# El numero contiene el separador
		# Extraigo la parte entera y verifico si no supera la longitud maxima permitida
		local vent=`echo $num | cut -d $sep -f 1`
		if [ `echo $vent | wc -L` -gt $ent ]; then
			return 1
		fi
		# Extraigo la parte decimal y verifico si no supera la longitud maxima permitida
		local vdec=`echo $num | cut -d $sep -f 2`
		if [ `echo $vdec | wc -L` -gt $dec ]; then
			return 1
		fi
	fi
	return 0
}

# Procesa un archivo. Obtiene la información necesaria para procesar el archivo de las tablas y procesa los registros.
# Parametros:
#	$1 Nombre del archivo que se desea procesar
#
# Valor de retorno:
#	0 si el procesamiento fue realizado existosamente.
#	1 si el procesamiento tuvo errores. Los motivos pueden ser: archivo vacio, falta de datos en las tablas para procesar el archivo, formato de fecha erroneo, ningun registro procesado correctamente
procesar_archivo () {
	if [ $# -ne 1 ]; then
		echo "Error en funcion 'procesar_archivo' de Interprete.sh: Cantidad de parametros incorrecto"
		return 1
	fi
	local archivo=$1
	# Obtengo la cantidad de lineas del archivo, que se supone, son la cantidad de registros que posee el archivo.
	local registros_input=`cat "$GRUPO$ACEPDIR/$archivo" | wc -l`
	# Si el archivo está vacio, lo rechazo
	if [ ${registros_input} -eq 0 ]; then
		log "A" "ARCHIVO VACIO: $archivo"
		return 1
	fi
	local registros_output=0
	# Obtengo el codigo de pais y sistema en el nombre del archivo
	local pais=`echo $archivo | sed 's/\([^-]*\)\(.*\)/\1/'`
	local sistema=`echo $archivo | sed 's/\([^-]*-\)\([^-]*\)\(.*\)/\2/'`
	# Obtengo el separador de campos y decimales
	local separadores=`grep "$pais-$sistema-[^-]-[^-]" "$GRUPO$CONFDIR/T1.tab"`
	# Si los separadores no existen para este sistema, no proceso el archivo
	if [ -z "$separadores" ]; then
		log "A" "La informacion de la tabla T1 es insuficiente para procesar el archivo $archivo: No existen separadores de campo y decimal"
		return 1
	fi
	local sep_campos=`echo $separadores | sed 's+\([^-]*\)-\([^-]*\)-\([^-]\)\(.*\)+\3+'`
	local sep_dec=`echo $separadores | sed 's+\([^-]*\)-\([^-]*\)-\([^-]\)-\([^-]\)+\4+'`
	local sep_dec=`echo ${sep_dec} | sed 's+[^,.]++'`
	# Obtengo el orden y formato de los campos
	local archivo_t2="$GRUPO$CONFDIR/T2.tab"
	local del_campo_t2="-"
	local campo_ord_t2=4
	local campo_form_t2=5
	# Campo CTB_FE
	local campo_fecha=`grep "^$pais-$sistema-CTB_FE-[0-9]*-[dmy0-9]*" ${archivo_t2}`
	if [ -z "${campo_fecha}" ]; then
		error_t2 $archivo "CTB_FE"
		return 1
	fi
	local ord_fecha=`echo ${campo_fecha} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local form_fecha=`echo ${campo_fecha} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s-\([mdy0-9]\{7,8\}\)\(.*\)-\1-"`
	local long_fecha=`echo ${form_fecha} | sed "s/[^0-9]*//"`	
	# Campo CTB_ESTADO
	local campo_estado=`grep "^$pais-$sistema-CTB_ESTADO-[0-9]*-[$][0-9]*" ${archivo_t2}`
	if [ -z "${campo_estado}" ]; then
		error_t2 $archivo "CTB_ESTADO"
		return 1
	fi
	local ord_estado=`echo ${campo_estado} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_estado=`echo ${campo_estado} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\([$]\)\([0-9]*\)\(.*\)/\2/"`
	# Campo PRES_ID
	local campo_pres_id=`grep "^$pais-$sistema-PRES_ID-[0-9]*-[$][0-9]*" ${archivo_t2}`
	if [ -z "${campo_pres_id}" ]; then
		error_t2 $archivo "PRES_ID"
		return 1
	fi
	local ord_pres_id=`echo ${campo_pres_id} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_pres_id=`echo ${campo_pres_id} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\([$]\)\([0-9]*\)\(.*\)/\2/"`
	# Campo PRES_CLI_ID
	local campo_pres_cli_id=`grep "^$pais-$sistema-PRES_CLI_ID-[0-9]*-[$][0-9]*" ${archivo_t2}`
        if [ -z "${campo_pres_cli_id}" ]; then
		error_t2 $archivo "PRES_CLI_ID"
		return 1
	fi
	local ord_pres_cli_id=`echo ${campo_pres_cli_id} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_pres_cli_id=`echo ${campo_pres_cli_id} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\([$]\)\([0-9]*\)\(.*\)/\2/"`
	# Campo PRES_CLI
	local campo_pres_cli=`grep "^$pais-$sistema-PRES_CLI-[0-9]*-[$][0-9]*" ${archivo_t2}`
        if [ -z "${campo_pres_cli}" ]; then
		error_t2 $archivo "PRES_CLI"
		return 1
	fi
	local ord_pres_cli=`echo ${campo_pres_cli} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_pres_cli=`echo ${campo_pres_cli} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\([$]\)\([0-9]*\)\(.*\)/\2/"`
	# Campo MT_PRES
	local campo_mt_pres=`grep "^$pais-$sistema-MT_PRES-[0-9]*-commax[0-9]*[.][0-9]" ${archivo_t2}`
        if [ -z "${campo_mt_pres}" ]; then
		error_t2 $archivo "MT_PRES"
		return 1
	fi
	local ord_mt_pres=`echo ${campo_mt_pres} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_mt_pres_e=`echo ${campo_mt_pres} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*\)\([.][0-9]*\)/\2/"`
	local long_mt_pres_d=`echo ${campo_mt_pres} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*[.]\)\([0-9]*\)/\3/"`
	# Campo MT_IMPAGO
	local campo_mt_impago=`grep "^$pais-$sistema-MT_IMPAGO-[0-9]*-commax[0-9]*[.][0-9]" ${archivo_t2}`
        if [ -z "${campo_mt_impago}" ]; then
		error_t2 $archivo "MT_IMPAGO"
		return 1
	fi
	local ord_mt_impago=`echo ${campo_mt_impago} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_mt_impago_e=`echo ${campo_mt_impago} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*\)\([.][0-9]*\)/\2/"`
	local long_mt_impago_d=`echo ${campo_mt_impago} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*[.]\)\([0-9]*\)/\3/"`
	# Campo MT_INDE
	local campo_mt_inde=`grep "^$pais-$sistema-MT_INDE-[0-9]*-commax[0-9]*[.][0-9]" ${archivo_t2}`
	if [ -z "${campo_mt_inde}" ]; then
		error_t2 $archivo "MT_INDE"
		return 1
	fi
	local ord_mt_inde=`echo ${campo_mt_inde} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_mt_inde_e=`echo ${campo_mt_inde} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*\)\([.][0-9]*\)/\2/"`
	local long_mt_inde_d=`echo ${campo_mt_inde} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*[.]\)\([0-9]*\)/\3/"`
	# Campo MT_INNODE
	local campo_mt_innode=`grep "^$pais-$sistema-MT_INNODE-[0-9]*-commax[0-9]*[.][0-9]" ${archivo_t2}`
	if [ -z "${campo_mt_innode}" ]; then
		error_t2 $archivo "MT_INNODE"
		return 1
	fi
	local ord_mt_innode=`echo ${campo_mt_innode} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_mt_innode_e=`echo ${campo_mt_innode} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*\)\([.][0-9]*\)/\2/"`
	local long_mt_innode_d=`echo ${campo_mt_innode} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*[.]\)\([0-9]*\)/\3/"`
	# Campo MT_DEB
	local campo_mt_deb=`grep "^$pais-$sistema-MT_DEB-[0-9]*-commax[0-9]*[.][0-9]" ${archivo_t2}`
	if [ -z "${campo_mt_deb}" ]; then
		error_t2 $archivo "MT_DEB"
		return 1
	fi
	local ord_mt_deb=`echo ${campo_mt_deb} | cut -d ${del_campo_t2} -f ${campo_ord_t2}`
	local long_mt_deb_e=`echo ${campo_mt_deb} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*\)\([.][0-9]*\)/\2/"`
	local long_mt_deb_d=`echo ${campo_mt_deb} | cut -d ${del_campo_t2} -f ${campo_form_t2} | sed "s/\(commax\)\([0-9]*[.]\)\([0-9]*\)/\3/"`

	# Itero por cada linea (registro)
	for i in `seq 1 ${registros_input}`; do
		linea=`head -n $i $GRUPO$ACEPDIR/$archivo | tail -n 1`
		# Si la linea no es nula, la proceso como un registro
		if [ -n "$linea" ]; then
			# Obtengo la fecha del registro
			val_fecha=`echo $linea | cut -d ${sep_campos} -f ${ord_fecha}`
			if [ `echo ${val_fecha}|wc -L` -eq 0 ]; then
				log "A" "El registro $i del archivo $archivo no pudo ser procesado: El campo CTB_FE se encuentra vacio"
				continue
			fi
			# Interpreto la fecha
			dia=0
			mes=0
			anio=0
			if [ "${form_fecha}" = "ddmmyy8" ]; then
				dia=`echo ${val_fecha} | sed "s-\([0-9]\{2\}\)\(.*\)-\1-"`
				mes=`echo ${val_fecha} | sed "s-\([0-9]\{2\}\)\([0-9]\{2\}\)\(.*\)-\2-"`
				anio=`echo ${val_fecha} | sed "s-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{4\}\)\(.*\)-\3-"`
			elif [ "${form_fecha}" = "ddmmyy10" ]; then
				dia=`echo ${val_fecha} | sed "s-\([0-9]\{2\}\)\(.*\)-\1-"`
				mes=`echo ${val_fecha} | sed "s-\([0-9]\{2\}/\)\([0-9]\{2\}\)\(.*\)-\2-"`
				anio=`echo ${val_fecha} | sed "s-\([0-9]\{2\}/\)\([0-9]\{2\}/\)\([0-9]\{4\}\)\(.*\)-\3-"`
			elif [ "${form_fecha}" = "yymmdd8" ]; then
				anio=`echo ${val_fecha} | sed "s-\([0-9]\{4\}\)\(.*\)-\1-"`
				mes=`echo ${val_fecha} | sed "s-\([0-9]\{4\}\)\([0-9]\{2\}\)\(.*\)-\2-"`
				dia=`echo ${val_fecha} | sed "s-\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\(.*\)-\3-"`
			elif [ "${form_fecha}" = "yymmdd10" ]; then
				anio=`echo ${val_fecha} | sed "s-\([0-9]\{4\}\)\(.*\)-\1-"`
				mes=`echo ${val_fecha} | sed "s-\([0-9]\{4\}/\)\([0-9]\{2\}\)\(.*\)-\2-"`
				dia=`echo ${val_fecha} | sed "s-\([0-9]\{4\}/\)\([0-9]\{2\}/\)\([0-9]\{2\}\)\(.*\)-\3-"`
			else
				# Si el formato obtenido de T2 no es compatible con ninguno de los especificados, salgo de la funcion, ya que no puedo procesar el archivo.
				log "A" "La informacion de la tabla T2 es insuficiente para procesar el archivo $archivo: El formato del campo CTB_FE es erroneo"
				return 1
			fi
			# Obtengo el campo CTB_ESTADO
			val_estado=`echo $linea | cut -d ${sep_campos} -f ${ord_estado}`
			if [ -z "${val_estado}" ] || [ ${long_estado} -lt `echo "${val_estado}" | wc -L` ]; then
				error_registro $archivo $i "CTB_ESTADO"
				continue
			fi
			# Obtengo el campo PRES_ID
			val_pres_id=`echo $linea | cut -d ${sep_campos} -f ${ord_pres_id}`
			if [ -z "${val_pres_id}" ] || [ ${long_pres_id} -lt `echo "${val_pres_id}" | wc -L` ]; then
				error_registro $archivo $i "PRES_ID"
				continue
			fi
			# Obtengo el campo PRES_CLI_ID
			val_pres_cli_id=`echo $linea | cut -d ${sep_campos} -f ${ord_pres_cli_id}`
			if [ -z "${val_pres_cli_id}" ] || [ ${long_pres_cli_id} -lt `echo "${val_pres_cli_id}" | wc -L` ]; then
				error_registro $archivo $i "PRES_CLI_ID"
				continue
			fi
			# Obtengo el campo PRES_CLI
			val_pres_cli=`echo $linea | cut -d ${sep_campos} -f ${ord_pres_cli}`
			if [ -z "${val_pres_cli}" ] || [ ${long_pres_cli} -lt `echo "${val_pres_cli}" |wc -L` ]; then
				error_registro $archivo $i "PRES_CLI"
				continue
			fi
			# Obtengo el campo MT_PRES
			val_mt_pres=`echo $linea | cut -d ${sep_campos} -f ${ord_mt_pres}`
			if [ -z "${val_mt_pres}" ]; then
				val_mt_pres=0
			else
				val_mt_pres=`echo ${val_mt_pres} | grep -x "[0-9][0-9]*[${sep_dec}]\?[0-9]*"`
				if [ -z "${val_mt_pres}" ]; then
					error_registro $archivo $i "MT_PRES"
					continue
				fi
				# Verifico si el numero cumple con las longitudes especificadas
				verificar_longitudes ${val_mt_pres} ${sep_dec} ${long_mt_pres_e} ${long_mt_pres_d}
				# Si el resultado es 1, el formato del campo es erroneo. Rechazo el registro y continuo con el siguiente
				if [ $? -eq 1 ]; then
					error_registro $archivo $i "MT_PRES"
					continue
				fi
				# Establezco como separador decimal el punto
				val_mt_pres=`echo ${val_mt_pres} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\.\3/"`
			fi
			# Obtengo el campo MT_IMPAGO
			val_mt_impago=`echo $linea | cut -d ${sep_campos} -f ${ord_mt_impago}`
			if [ -z "${val_mt_impago}" ]; then
				val_mt_impago=0
			else
				val_mt_impago=`echo ${val_mt_impago} | grep -x "[0-9][0-9]*[${sep_dec}]\?[0-9]*"`
				if [ -z "${val_mt_impago}" ]; then
					error_registro $archivo $i "MT_IMPAGO"
					continue
				fi
				# Verifico si el numero cumple con las longitudes especificadas
				verificar_longitudes ${val_mt_impago} ${sep_dec} ${long_mt_impago_e} ${long_mt_impago_d}
				# Si el resultado es 1, el formato del campo es erroneo. Rechazo el registro y continuo con el siguiente
				if [ $? -eq 1 ]; then
					error_registro $archivo $i "MT_IMPAGO"
					continue
				fi
				# Establezco como separador decimal el punto
				val_mt_impago=`echo ${val_mt_impago} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\.\3/"`
			fi
			# Obtengo el campo MT_INDE
			val_mt_inde=`echo $linea | cut -d ${sep_campos} -f ${ord_mt_inde}`
			if [ -z "${val_mt_inde}" ]; then
				val_mt_inde=0
			else
				val_mt_inde=`echo ${val_mt_inde} | grep -x "[0-9][0-9]*[${sep_dec}]\?[0-9]*"`
				if [ -z "${val_mt_inde}" ]; then
					error_registro $archivo $i "MT_INDE"
					continue
				fi
				# Verifico si el numero cumple con las longitudes especificadas
				verificar_longitudes ${val_mt_inde} ${sep_dec} ${long_mt_inde_e} ${long_mt_inde_d}
				# Si el resultado es 1, el formato del campo es erroneo. Rechazo el registro y continuo con el siguiente
				if [ $? -eq 1 ]; then
					error_registro $archivo $i "MT_INDE"
					continue
				fi
				# Establezco como separador decimal el punto
				val_mt_inde=`echo ${val_mt_inde} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\.\3/"`
			fi
			# Obtengo el campo MT_INNODE
			val_mt_innode=`echo $linea | cut -d ${sep_campos} -f ${ord_mt_innode}`
			if [ -z "${val_mt_innode}" ]; then
				val_mt_innode=0
			else
				val_mt_innode=`echo ${val_mt_innode} | grep -x "[0-9][0-9]*[${sep_dec}]\?[0-9]*"`
				if [ -z "${val_mt_innode}" ]; then
					error_registro $archivo $i "MT_INNODE"
					continue
				fi
				# Verifico si el numero cumple con las longitudes especificadas
				verificar_longitudes ${val_mt_innode} ${sep_dec} ${long_mt_innode_e} ${long_mt_innode_d}
				# Si el resultado es 1, el formato del campo es erroneo. Rechazo el registro y continuo con el siguiente
				if [ $? -eq 1 ]; then
					error_registro $archivo $i "MT_INNODE"
					continue
				fi
				# Establezco como separador decimal el punto
				val_mt_innode=`echo ${val_mt_innode} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\.\3/"`
			fi
			# Obtengo el campo MT_DEB
			val_mt_deb=`echo $linea | cut -d ${sep_campos} -f ${ord_mt_deb}`
			if [ -z "${val_mt_deb}" ]; then
				val_mt_deb=0
			else
				val_mt_deb=`echo ${val_mt_deb} | grep -x "[0-9][0-9]*[${sep_dec}]\?[0-9]*"`
				if [ -z "${val_mt_deb}" ]; then
					error_registro $archivo $i "MT_DEB"
					continue
				fi
				# Verifico si el numero cumple con las longitudes especificadas
				verificar_longitudes ${val_mt_deb} ${sep_dec} ${long_mt_deb_e} ${long_mt_deb_d}
				# Si el resultado es 1, el formato del campo es erroneo. Rechazo el registro y continuo con el siguiente
				if [ $? -eq 1 ]; then
					error_registro $archivo $i "MT_DEB"
					continue
				fi
				# Establezco como separador decimal el punto
				val_mt_deb=`echo ${val_mt_deb} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\.\3/"`
			fi
			# Calculo el MT_REST
			val_mt_rest=`echo "scale=2; ${val_mt_pres}+${val_mt_impago}+${val_mt_inde}+${val_mt_innode}-${val_mt_deb}" | bc`
			# Si el monto restante es negativo, no se graba
			if [ `echo "${val_mt_rest} <= 0" | bc` -eq 1 ]; then
				continue
			fi
			# Formateo todos los numeros con coma, que es el separador estandar del sistema
			if [ `echo ${val_mt_press} | grep -x "[0-9]*[.][0-9]*"` ]; then
				val_mt_pres=`echo ${val_mt_pres} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\,\3/"`
			fi
			if [ `echo ${val_mt_impago} | grep -x "[0-9]*[.][0-9]*"` ]; then
                                val_mt_impago=`echo ${val_mt_impago} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\,\3/"`
                        fi
			if [ `echo ${val_mt_inde} | grep -x "[0-9]*[.][0-9]*"` ]; then
                                val_mt_inde=`echo ${val_mt_inde} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\,\3/"`
                        fi
			if [ `echo ${val_mt_innode} | grep -x "[0-9]*[.][0-9]*"` ]; then
                                val_mt_innode=`echo ${val_mt_innode} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\,\3/"`
                        fi
			if [ `echo ${val_mt_deb} | grep -x "[0-9]*[.][0-9]*"` ]; then
                                val_mt_deb=`echo ${val_mt_deb} | sed "s/\([0-9]*\)\([^0-9]\)\([0-9]*\)/\1\,\3/"`
                        fi
			# Grabo el registro procesado en el archivo de prestamos correspondiente
			fecha_actual=`date +"%d/%m/%y"`
			usuario=`who am i | awk '{print $1}'`
			registro="$sistema;$anio;$mes;$dia;${val_estado};${val_pres_id};${val_mt_pres};${val_mt_impago};${val_mt_inde};${val_mt_innode};${val_mt_deb};${val_mt_rest};${val_pres_cli_id};"${val_pres_cli}";${fecha_actual};$usuario"
			archivo_pais="$GRUPO$PROCDIR/prestamos.$pais"
			if [ -f ${archivo_pais} ]; then
				# Si el archivo existe, verifico si se tienen los permisos de escritura
				if [ -w ${archivo_pais} ]; then
					# Si se tienen los permisos de escritura, grabo el registro
					echo $registro >> ${archivo_pais}
				else
					# Si no se tienen los permisos de escritura, lanzo un error
					log "E" "No se tiene permiso de escritura en el archivo ${archivo_pais}, el registro no pudo ser grabado."
				fi
			else
				# Si el archivo no existe, lo creo y agrero el registro
				echo $registro > ${archivo_pais}
			fi
			# Una vez procesado el registro, incremento en una unidad el contador de registros procesados
			registros_output=`echo "${registros_output}+1"|bc`
		fi
	done
	# Si no se proceso ningun registro, es porque ninguno cumplia con el formato requerido. Entonces se lo rechaza por contener datos erroneos
	if [ ${registros_output} -eq 0 ]; then
		log "A" "ARCHIVO CON DATOS ERRONEOS: $archivo"
		return 1
	fi
	# Escribo en el log la cantidad de registros input y output del archivo
	log "I" "Registros input en archivo $archivo: ${registros_input}"
	log "I" "Registros output en archivo $archivo: ${registros_output}"
	return 0
}

# Si no esta Inicializado el AMBIENTE sale con retorno 1, no ejecuta el comando
if [ -z $GRUPO ]; then
	echo "ERROR: Falta inicializar Ambiente"
	log "E" "ERROR: Falta inicializar Ambiente"
	exit 1
fi

# Verifico que Interprete no este en ejecucion
daemon_old=`pgrep -o "Interprete.sh"`
daemon_new=`pgrep -n "Interprete.sh"`
if [ $daemon_old != $daemon_new ]; then
	echo "ERROR: Ya se encuentra corriendo un demonio Interprete.sh"
	log "E" "ERROR: Ya se encuentra corriendo un demonio Interprete.sh"
	exit 2
fi

# Verifico si se encuentran los archivos T1.tab y T2.tab en el directorio CONFDIR
if [ ! -r "$GRUPO$CONFDIR/T1.tab" ]; then
	echo "No existe o no se tiene permiso de lectura en archivo $GRUPO$CONFDIR/T1.tab"
	log "SE" "No existe o no se tiene permiso de lectura en archivo $GRUPO$CONFDIR/T1.tab"
	exit 3
fi
if [ ! -r "$GRUPO$CONFDIR/T2.tab" ]; then
	echo "No existe o no se tiene permiso de lectura en archivo $GRUPO$CONFDIR/T2.tab"
	log "SE" "No existe o no se tiene permiso de lectura en archivo $GRUPO$CONFDIR/T2.tab"
	exit 3
fi

# Inicia log y graba el mensaje 'Inicio Interprete' y cantidad de archivos de entrada
archivos=`ls -p "$GRUPO$ACEPDIR"`
cant_archivos=`ls -p "$GRUPO$ACEPDIR" | wc -l`
log "I" "Inicio de Interprete"
log "I" "Cantidad de Archivos de Input: ${cant_archivos}"

# Defino el patron del nombre de archivo aceptado
patron_archivo="^[A-Z]\{1,3\}-[0-9]\{1,2\}-[0-9]\{4\}-[0-9]\{1,2\}$"
for i in `seq 1 $cant_archivos`; do
	# Obtengo el nombre de un archivo
	archivo_original=`ls -1p $GRUPO$ACEPDIR | head -n 1`
	archivo=`echo ${archivo_original} | grep -x ${patron_archivo}`
	# Si el nombre de archivo tiene longitud distinta de 0, es decir, paso correctamente por el patron
	if [ -n "$archivo" ]; then	
		# Verifico si esta en el directorio $PROCDIR, lo muevo a $RECHDIR
		if [ -f $GRUPO$PROCDIR/$archivo ]; then
			# Escribo en el log "DUPLICADO: $archivo"
			log "A" "DUPLICADO: $archivo"
			MoverX.sh "$GRUPO$ACEPDIR/$archivo" "$GRUPO$RECHDIR/" "Interprete"
		else
			# Si no está duplicado, lo proceso
			procesar_archivo $archivo
			resultado=$?		
			# Si el resultado es 0, significa que se proceso correctamente el archivo. Lo muevo a archivos procesados.
			if [ $resultado -eq 0 ]; then
				MoverX.sh "$GRUPO$ACEPDIR/${archivo}" "$GRUPO$PROCDIR/" "Interprete"
			else
				# Si el procesamiento de archivo tuvo errores, significa, por ejemplo, no encontrar separadores de campos y decimales o campos obligatorios para un pais y sistema dado. Lo muevo a archivos rechazados.
				MoverX.sh "$GRUPO$ACEPDIR/${archivo}" "$GRUPO$RECHDIR/" "Interprete"
			fi
		fi
	else
		# Si el nombre del archivo no paso por el patron, lo rechazo por no contemplar el formato exigido
		log "A" "NOMBRE DE ARCHIVO ERRONEO: ${archivo_original}"
		MoverX.sh "$GRUPO$ACEPDIR/${archivo_original}" "$GRUPO$RECHDIR/" "Interprete"
	fi
done

# Escribo en el log 'Fin de Interprete'
log "I" "Fin de Interprete"

exit 0
