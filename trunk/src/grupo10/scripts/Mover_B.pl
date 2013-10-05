# #############################################################################
# Trabajo práctico N°1
# Grupo 10
# 75.08 - Sistemas Operativos
# Facultad de Ingeniería
# Universidad de Buenos Aires
# #############################################################################
#
# COMANDO MOVER_B
# 
# Comando que se encarga de mover archivos desde un directorio origen hacia un
# directorio destino. Si en el directorio destino ya se encuentra un archivo
# el mismo nombre, se crea una carpeta de duplicados para luego mover la
# versión menos reciente del archivo hacia allí y así realizar posteriormente
# el movimiento del archivo nuevo.
#
# Parámetros
# ##########
#
# Parametro 1 (Obligatorio): Path de origen del archivo, incluyendo el nombre
# 							 del archivo a mover. (ej: /origen/mi_archivo.txt).
# Parametro 2 (Obligatorio): Path destino hacia donde debe moverse el archivo. 
#							 (ej; destino/).
# 
# Códigos de retorno
# ##################
#
# 0: La acción se llevó a cabo con éxito;
# 1: El directorio de origen no existe;
# 2: El directorio de destino no existe;
#


#!/usr/bin/perl 
use warnings;
use File::Copy 'move';

require 'libs/lib_utilities.pl';




# Almacenamos parámetros de entrada
$origen = $ARGV[0];
$destino = $ARGV[1];
$comando;

# Comprobamos si existe un tercer parametro con el nombre del comando invocante.
# En el transcurso del programa, se utiliza para grabar en el log si el comando
# invocante lo hace.
if ($ARGV[2]) {
	$comando = $ARGV[2];
}

# Directorio de archivos duplicados
$dirDuplicados = $destino . "/dup/";


# Verificamos si el origen existe
open($origen, $origen) or (grabarSiCorresponde($comando, 1) and exit 1);
close $origen;

# Verificamos si el directorio destino existe. De ser así, lo dejamos abierto.
opendir($destino, $destino) or (grabarSiCorresponde($comando, 2) and exit 2);
# Cerramos el directorio
closedir $destino;

# Verificamos si el origen es igual al destino en cuyo caso ya se movió el
# archivo
($pathOrigen, $nombreArchivo) = obtenerDir($origen);
(grabarSiCorresponde($comando, 0) and exit 0) if($pathOrigen eq $destino);

# Verificamos la existencia de archivos duplicados
opendir($destino, $destino) or (grabarSiCorresponde($comando, 2) and exit 2);

# Buscamos si algún archivo posee el mismo nombre.
foreach(grep(/^($nombreArchivo)$/, readdir($destino)))
{	
	# Abrimos directorio "dup" o lo creamos en caso de no existir
	if(!opendir($dirDuplicados, $dirDuplicados))
	{
		mkdir($dirDuplicados);
		opendir($dirDuplicados, $dirDuplicados);
	}

	$cantRepetidos = 1;

	# Contabilizamos la cantidad de archivos con el mismo nombre
	foreach(grep(/^($nombreArchivo).(\d){3}$/, readdir($dirDuplicados)))
	{
		$cantRepetidos += 1;
	}

	# Movemos el archivo que se encontraba originalmente en destino hacia la
	# carpeta de duplicados (dup/) con el número de secuencia correspondiente.
	move $destino.$nombreArchivo, ($dirDuplicados.$nombreArchivo."."
		.numberPadding($cantRepetidos, 3));

	# Cerramos el directorio
	closedir $dirDuplicados;
}

# Movemos el archivo
$error = move $origen, $destino;

# Devolvemos el codigo de error
grabarSiCorresponde($comando, $error);

closedir $destino;
