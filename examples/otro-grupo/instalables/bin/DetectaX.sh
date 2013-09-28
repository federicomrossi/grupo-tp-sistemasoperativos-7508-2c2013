#!/bin/bash
# Comando DetectaX
# Este comando se encarga de detectar archivos que arriban al directorio ARRIDIR
# Archivos Input 
#	Archivos que arriban al directorio $ARRIDIR/<nombre del archivo>
#	Maestro de paises y Sistemas $MAEDIR/p-s.mae
#
# Archivos Output
#	Archivos Recibidos $ACEPDIR/<pais>-<sistema>-<año>-<mes>
#	Archivos Rechazados $RECHDIR/<nombre del archivo
#	Log $LOGDIR/DetectaX.$LOGEXT
#
# Codigo de retorno del comando
#	1: Ambiente no inicializado
#	2: Otro Demonio esta corriendo



# Función para validar tipo de archivo
function validar_tipo {
	IFS=$'\x0A'$'\x0D'
	FILES=$(ls "$GRUPO$ARRIDIR")

	for FILE in $FILES
	do
	    tipo=$(echo $(file "$GRUPO$ARRIDIR/$FILE"))
	    if [ $(echo $tipo | grep -w "ASCII text" | wc -l) -eq 0  ]; then 
         	GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Tipo de archivo inválido" 
		MoverX.sh "$GRUPO$ARRIDIR/$FILE" "$GRUPO$RECHDIR/" "DetectaX" 
	    fi
	 done
		
}

# Función que valida si el formato es correcto y envia los archivos a los directorios correspondientes
function validar_formato {
	
	# Archivo maestro de paises y sistema
	maestro_ps=$GRUPO$MAEDIR/p-s.mae
	# Patron de búsqueda en el nombre del archivo, para usar sed y obtener todos los campos
	patron_busqueda="\([A-Z]\{1,3\}\)-\([0-9]\{1,2\}\)-\([0-9]\{4\}\)-\([0-9]\{1,2\}\)"

	# Separo los campos del nombre del archivo
	pais=$(echo "$1" | sed "s+$patron_busqueda+\1+")
	sistema=$(echo "$1" | sed "s+$patron_busqueda+\2+")
	anio=$(echo "$1" | sed "s+$patron_busqueda+\3+")
	mes=$(echo "$1" | sed "s+$patron_busqueda+\4+")

        if [ "$1" != "$(echo $1 | tr "[:lower:]" "[:upper:]")" ]; then
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Nombre de archivo con formato inválido" 
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	elif [ $anio -lt 2000 -o $anio -gt $(date +%Y) ];then
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Año inválido" 
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	elif [ $mes -lt 1 -o $mes -gt 12 ]; then
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Mes inválido" 
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	elif [ $anio -eq $(date +%Y) -a $mes -gt $(date +%m) ]; then
	   GlogX.sh -c "DetectaX" -t I  -m "RECHAZADO: Periodo mayor al periodo actual" 	  
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	elif [ $(grep "^$pais-[a-zA-Z]*" $maestro_ps -c) -eq 0 ]; then
	   GlogX.sh -c "DetectaX" -t I  -m "RECHAZADO: País inexistente en el maestro p-s.mae" 
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	elif [ $(grep "^.*-.*-$sistema-" $maestro_ps -c) -eq 0 ]; then
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Sistema inexistente en el maestro p-s.mae"
           MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
        elif [ $(grep "^$pais-[a-zA-Z]*-$sistema-" $maestro_ps -c) -eq 0 ]; then 
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: No existe combinacion pais-sistema en el maestro p-s.mae"
           MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$RECHDIR/" "DetectaX"
	else
	   GlogX.sh -c "DetectaX" -t I -m "ACEPTADO: El archivo se ha guardado correctamente en $GRUPO$ACEPDIR/"
	   MoverX.sh "$GRUPO$ARRIDIR/$1" "$GRUPO$ACEPDIR/" "DetectaX"
	fi

}

# Función que se encarga de inicialiar a interprete salvo que este este corriendo
function iniciar_interprete {
	# Obtengo el PID de interprete
  	PID=$(getPID.sh "Interprete.sh" "$$")
   	# Verifico que el Interprete no esté corriendo
	if [ -n "$PID" ]; then 
	  echo "El Interprete está corriendo."
	else
	  # LLamo a Interprete para que arranque y obtengo el id del proceso interprete
	  StartX.sh "Interprete.sh"
	  PID=$(getPID.sh "Interprete.sh" $$)
	  if [ -n "$PID" ];then
		echo "El PID de Interprete es $PID"
	  else
		echo "Error: No se puede obtener el PID de Interprete"
	  fi
        fi  
}


# Si no esta Inicializado el AMBIENTE sale con retorno 1, no ejecuta el comando
if [ -z $GRUPO ]; then
    echo "ERROR: Falta Inicializar el Ambiente"
    GlogX.sh -c "DetectaX" -t E -m "ERROR: Falta Inicializar el Ambiente"
    exit 1
fi

# Verifico que DetectaX no este en ejecucion
daemon_old=`pgrep -o "DetectaX.sh"`
daemon_new=`pgrep -n "DetectaX.sh"`
if [ $daemon_old != $daemon_new ]; then 
    echo "ERROR: Esta corriendo otro demonio"
    GlogX.sh -c "DetectaX" -t E -m "ERROR: Esta corriendo otro demonio"
    exit 2
fi

# Verifico la existencia de los directorios
if [ ! -d "$GRUPO$RECHDIR" ];then
	mkdir "$GRUPO$RECHDIR"
fi

if [ ! -d "$GRUPO$ACEPDIR" ];then 
	mkdir "$GRUPO$ACEPDIR"
fi

# Este for corresponde a los ciclos que se ejecuta el Daemon
for nro_ciclo in $(seq 1 $CANLOOP)
do

# Inicializo el Log

  GlogX.sh -c "DetectaX"  -t I  -m "             N° de Ciclo $nro_ciclo             "

# Verifico que existan archivos dentro de $ARRIDIR
if [ "$(ls -p "$GRUPO$ARRIDIR" | wc -l )" != "0" ];then  

	# Verifico que el archivo sea de tipo comun, de texto.
	validar_tipo	

	# Obtengo la cantidad de archivos validos e invalidos en $ARRIDIR
	patron_validos=$"^.\{1,3\}-[0-9]\{1,2\}-[0-9]\{4\}-[0-9]\{1,2\}$"
	cant_arri_invalidos=$(ls -p "$GRUPO$ARRIDIR" | grep -v $patron_validos | wc -l)
	cant_arri_validos=$(ls -p "$GRUPO$ARRIDIR" | grep -x $patron_validos | wc -l)

	# Envío los rechazados a $RECHDIR
	for i in $(seq 1 $cant_arri_invalidos);
	do
     	   nombre=$(ls -1p "$GRUPO$ARRIDIR" | grep -v $patron_validos |  tail -n 1) 
	   GlogX.sh -c "DetectaX" -t I -m "RECHAZADO: Nombre del archivo con formato invalido" 
           MoverX.sh "$GRUPO$ARRIDIR/$nombre" "$GRUPO$RECHDIR/" "DetectaX"
	done

	# Valido que los archivos que cumplan el patrón válido, tengan formato válido
	for j in $(seq 1 $cant_arri_validos);
	do
	   nombre=$(ls -1p "$GRUPO$ARRIDIR" | grep -x $patron_validos | head -n 1)
	   validar_formato $nombre
	done
	
	# Verifico que existan archivos en el directorio $ACEPDIR
	if [ $(ls -p $GRUPO$ACEPDIR | wc -l ) -gt 0 ];then
	   echo "Existen archivos en el directorio $GRUPO$ACEPDIR"
	   iniciar_interprete
	else
	   echo "No existen archivos en el directorio $GRUPO$ACEPDIR"
	fi
	
fi
        # Como DetectaX todavía no alcanzó la cantidad de ciclos duermo TESPERA minutos
        sleep "$TESPERA"m
done
