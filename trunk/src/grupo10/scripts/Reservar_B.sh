#!/bin/sh
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

# DEBUG: Se debe cambiar el path ingresado por la variable de entorno:
# FILES = "$ACEPDIR"
FILES=./*


# Iteramos sobre los archivos del directorio
for f in $FILES
do
	# Procesamos solo los que son archivos
	if [ -f $f ]; then

		# Verificamos si ya ha sido procesado el archivo anteriormente
		`ls -l -lp Mover_B.pl &> /dev/null`
		res=$?

		# Si se encontró el archivo, está duplicado
		if [ "$res" -eq "0" ]; then

			# Movemos archivo a $RECHDIR
			'perl ./Mover_B.pl $f $RECHDIR Reservar_B'

			# Generamos entrada nueva en el log informando la situación
			echo "LOG: Se rechaza el archivo por estar DUPLICADO."

		# Caso en que no se encontró el archivo duplicado        
		else
			# Movemos archivo a $PROCDIR
			'perl ./Mover_B.pl $f $PROCDIR Reservar_B'
		fi
	fi
done

