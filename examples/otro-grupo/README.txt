################################################################################################################################################
	
	FIUBA- 75.08 - Sistemas Operativos - Primer Cuatrimestre 2013 
	   GRUPO N° 9
	      	# Casal, Romina
	      	# Lucero, Emmanuel
		# Mazzara, Ignacio
		# Origone, Agustín 
		# Pérez Dittler, Ezequiel
		# Werffeli, Alex

################################################################################################################################################
				Pasos a seguir en la instalación y ejecución del programa CONTROLX
################################################################################################################################################

	1- Insertar el dispositivo de almacenamiento con el contenido del tp (pen drive, cd, etc).

	2- Crear en el directorio corriente del usuario un directorio al que llamaremos[directorio_instalacion].

	3- Copiar el archivo TPGrupo09.tar.gz en el directorio creado en el paso anterior. Puede usar para copiar
	el siguiente comando: "cp [ruta_dispositivo]/TPGrupo09.tar.gz [directorio_instalacion]

	4- Descomprimir el archivo TPGrupo09.tar.gz en el [directorio_instalacion].
	Para esto, ejecutar en el terminal el siguiente comando:

	$ tar xvzf TPGrupo09.tar

	5. Luego del paso 4, todos los archivos necesarios para la instalacion se encontraran en el directorio [directorio_instalacion]/instalables
	Para comenzar la instalacion ejecutar desde el directorio [directorio_instalacion] el comando InstalX.

	$  cd [directorio_instalacion]
	$  ./InstalX.sh

	6. Una vez realizada la instalacion, si esta termino correctamente, dirigirse al directorio definido para los archivos binarios.
	A modo de ejemplo, utilizamos el directorio por default /bin

	$ cd bin

	7. Una vez ahi, inicializamos el sistema llamando al comando InicioX

	$ . IniciarX.sh

	8. Si el usuario decide detener la ejecucion del demonio, debera ejecutar el siguiente script:

	$ StopX.sh

	9. Si el usuario  quisiera volver a ejecutar el demonio bastará con ejecutar el siguiente script:

	$ StartX.sh
 
##################################################################################################################################################
	Aclaraciones al usuario:
		# El signo $ de cada items no forma parte del comando
		# El [directorio_instalacion] es una referencia al directorio que el usuario crea en el items 2
		# En el Items 7 debe notar que el comando tiene un espacio entre el .(punto) y el nombre del comando
##################################################################################################################################################
