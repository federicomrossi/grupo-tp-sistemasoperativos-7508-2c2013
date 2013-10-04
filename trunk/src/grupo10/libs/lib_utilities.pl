# LIBRERÍA UTILITIES
#
# Librería de funciones y subrutinas de propósito general.
#

#!/usr/bin/perl 
use warnings;



# Subrutina que separa el nombre de archivo del directorio de precedencia.
# Devuelve dos strings: el directorio y el nombre de archivo por separado.
sub obtenerDir {
	$path = $_[0];
	$max = 0;

	for($i = length($path); $i >= 0; $i--) {
		if(substr($path, $i, 1) eq "/"){
			$max = $i;
			last;
		}
	}

	if($max == 0) {
		return ("/", $path);
	}

	return(substr($path, 0, $max + 1), substr($path, $max + 2, length($path)));
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
