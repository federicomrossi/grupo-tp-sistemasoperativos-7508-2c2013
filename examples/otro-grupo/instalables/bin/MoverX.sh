#!/bin/bash
# Funcion MoverX
# Funcion que se encarga de mover un archivo de un directorio a otro,
# contemplando archivos duplicados.
#
# Opciones y parametros
# Parametro 1 (Obligatorio): Archivo Input de origen
# Parametro 2 (Obligatorio): Archivo Output de destino
# Parametro 3 (Opcional): Comando que lo invoca.
#
#   Códigos de retorno del comando
# 	0: Movimiento de archivo exitoso
#	1: Cantidad incorrecta de parametros
#	2: Directorio o archivo inexistente
#	3: Directorio de entrada y de salida iguales


file_input="$1"
file_output="$2"
log="$3"
cant_par="$#"
pathorigen="${1%/*}"
pathdestino="${2%/*}"
archorigen="${1##*/}"
	
function verificar_parametros() {
  if [ $cant_par -gt 3 ]; then
      GlogX.sh -c $log -t E -m "MoverX: Cantidad Invalida de parametros. No puede ingresar mas de 3 parámetros"
      exit 1
  fi
  if [ $cant_par -lt 2 ]; then 
      GlogX.sh -c $log -t E -m "MoverX: Cantidad Invalida de parametros. No puede ingresar menos de 2 parámetros"
      exit 1 
  fi
}

function verificar_existencia_directorios() {
  if [ ! -f "$file_input" ]; then 
	if [ $cant_par -eq 3 ]; then
	   GlogX.sh -c $log -t E -m "MoverX: El archivo de origen $1 no existe" 
        fi
    exit 2
  fi
  if [ ! -d "$file_output" ]; then 
	if [ $cant_par -eq 3 ]; then
	   GlogX.sh -c $log -t E -m "MoverX: El directorio destino $pathdestino no existe" 
    	fi
    exit 2
  fi
}

function verificar_son_iguales() {
  if [ "$pathorigen"  == "$pathdestino" ]; then
	if [ $cant_par -eq 3 ]; then 
	    GlogX.sh -c $log -t E -m "MoverX: El directorio de origen y de destino son iguales" 
	fi
     exit 3
  fi
}

function mover_archivo () {

# Verifico si es un archivo duplicado
  if [ -f "$pathdestino/$archorigen" ]; then 

	  if [ ! -d "$pathdestino/dup" ];then  # Si no existe el directorio de duplicados lo crea
	     mkdir "$pathdestino/dup"
	  fi

	  # Verifico que no exista en el directorio de duplicados el mismo archivo. Si existe obtengo el numero de secuencia
	  nnn=$(ls "$pathdestino/dup" | grep "^$archorigen.[0-9]\{1,3\}$" | sort -r | sed s/$archorigen.// | head -n 1) 
	
	  if [ "$nnn" == "" ]; then  # Si no existen duplicados entonces le asigno a nnn 0
	      nnn=0
	  fi
 	  # Incremento el numero de secuencia para los archivos duplicados
	  nnn=$(echo $nnn + 1 | bc -l )
 	  mv "$file_input" "$pathdestino/dup/$archorigen.$nnn" 

	  if [ $cant_par -eq 3 ]; then
	     GlogX.sh -c $log -t I -m "MoverX: El archivo que intenta mover ya existe. Se copió al directorio de duplicados" 
	  fi
  else # Copio el archivo al directorio destino
       mv "$file_input" "$pathdestino"
	  if [ $cant_par -eq 3 ];then	
	     GlogX.sh -c $log -t I -m "MoverX: Operacion Existosa. El archivo se ha movido sin errores" 
	    
	  fi
       exit 0
  fi
}

	################### Funcion MoverX ######################
	
	# Verifico que la cantidad de parametros sea correcta
		verificar_parametros 
	# Verifico la existencia de los directorios pasados por parametro.
		verificar_existencia_directorios 
	# Verifico si el directorio origen y el destino son iguales
		verificar_son_iguales
	# Muevo el archivo al directorio correspondiente
		mover_archivo	
