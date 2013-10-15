# LIBRERÍA UTILITIES
#
# Librería de funciones y subrutinas de propósito general.
#

#!/usr/bin/perl 
use warnings;


# Definicion de un caracter sin '/'
my $CHAR_SIN_B = "[\x00-\x2E|\x30-\xFF]";



# Subrutina que separa el nombre de archivo del directorio de precedencia.
# Devuelve dos strings: el directorio y el nombre de archivo por separado.
sub obtenerDir {
	$path = $_[0];
	$nombre = $_[0];

	# Se parsea el string para devolver el directorio y el nombre del archivo
	$path =~ s:^/?(($CHAR_SIN_B+/)*)($CHAR_SIN_B+)$:$1:;
	$nombre =~ s:^/?($CHAR_SIN_B+/)*($CHAR_SIN_B+)$:$2:;

	return ($path, $nombre);
}


# Realiza el padding sobre un número.
# PRE: debe recibir el número a rellenar y la cantidad de ceros con que debe
# rellenado en el orden que se describe.
# POST: devuelve una cadena.
sub numberPadding {
	$number = $_[0];
	$padding = $_[1];
	$numberPaddinged = "$number";

	for($i = 0; $i < ($padding - length($number)); $i++)
	{
		$numberPaddinged = "0" . $numberPaddinged;
	}

	return $numberPaddinged;
}

1;
