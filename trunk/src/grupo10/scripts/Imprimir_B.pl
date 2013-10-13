# #############################################################################
# Trabajo práctico N°1
# Grupo 10
# 75.08 - Sistemas Operativos
# Facultad de Ingeniería
# Universidad de Buenos Aires
# #############################################################################
#
# FUNCIÓN IMPRIMIR_B
# 
# Comando que se encarga de ...
#
#
# Parámetros
# ##########
#
#
# Códigos de retorno
# ##################
#
# 0: La acción se llevó a cabo con éxito;
# 1: 
#


#!/usr/bin/perl 
use warnings;
use Getopt::Std;

require 'libs/lib_utilities.pl';


################################## HARDCODEO

$PROCDIR = "../procesados/";
$RESERVASOK = "reservas.ok";
$REPODIR = "./";

################################## END HARDCODEO



### CONFIGURACIÓN

# Cantidad total de puestos en el ranking
$RANK_CANT_PUESTOS = 10;
$RANK_NOMBRE_ARCHIVO = "ranking";

### FIN CONFIGURACION




# Variable que contiene el display de la ayuda
$ayuda = "\n** Ayuda Imprimir_B **\n
Uso: Imprimir_B [OPCION]
o: Imprimir_B -w [OPCION]

Imprime en pantalla o graba en archivo (utlilzando -w) la informacion 
correspondiente a OPCION.

Nota: Todos las opciones pueden ser combinadas con -w, salvo en caso
de que sea especificado lo contrario.

OPCION:
  -a 			Muestra esta ayuda. No puede ser combinado con -w.
  -d 			Genera una lista de disponibilidades para una
  				obra o una sala.
  -i 			Genera una lista de invitados a un evento.
  -r 			Genera un ranking con los 10 principales 
  				solicitantes de reservas.
  -t 			Genera un listado de tickets a imprimir.

Para ver la documentacion completa, correr: ..\n
** Fin Ayuda Imprimir_B **\n\n";

# Variable que contiene el mensaje de error para el caso en que no se han
# especificado parámetros de entrada.
$errorCantidadNulaDeParametros = "-> No se han especificado parámetros de entrada. Para mas información ejecute
Imprimir_B.pl -a\n";

# Variable que contiene el mensaje de error de combinacion de opciones
$errorCombinacionOpciones = "
-> Ha ingresado una combinacion de opciones incorrecta. Por favor, verifique que el comando ingresado 
   sea correcto y vuelva a intentarlo.
-> Para ver la ayuda, ingrese: perl Imprimir_B -a.\n\n";

# Variable que contiene el mensaje de error de repeticion de opciones
$errorRepeticion = "
-> Ha ingresado una o varias opciones repetidas. Por favor, verifique que el comando ingresado sea correcto y vuelva a intentarlo.
-> Para ver la ayuda, ingrese: perl Imprimir_B -a.\n\n";


sub disponibilidad{

	# $string = "The time is: 12:31:02 on 4/12/00";
	# print "$string\n";
	# $string =~ /:\s+/g;
	# ($time) = ($string =~ /\G(\d+:\d+:\d+)/);
	# $string =~ /.+\s+/g;
	# ($date) = ($string =~ m{\G(\d+/\d+/\d+)});
	# print "Time: $time, Date: $date\n";

	# Abre el archivo de combos.dis
	open(COMBOS, "<combos.dis") or die "Couldn't open file combos.dis, $!";

	# Lee una linea
	$linea = <COMBOS>;

	while ($linea != null) {
		# Compara con el formato buscado, si es, lo imprime
		if ($linea =~ m[(\d+;2;(\d+)\/(\d+)\/(\d+);(\d+):(\d+);\d+;\d+;\d+);\w+])	{
			$linea = $1;
			$linea =~ s/;/-/g;
			print "$linea\n";
		}
		# Lee una linea
		$linea = <COMBOS>;
	}
}


# Subrutina que se encarga de mostrar el ranking de los diez principales
# solicitantes de reservas. Este imprime por pantalla el ranking, y de ser
# especificado, también lo imprimira sobre un archivo de salida ranking.nnn.
# PRE: el único parámetro se refiere a si se desea grabar en un archivo el
# ranking. De ser deseado este comportamiento, debe pasarse un valor distinto
# de cero como parámetro o cero en su defecto.
# POST: Si se ha especificado grabar en un archivo este se llamará ranking.nnn
# siendo nnn un número de tres dígitos que evita sobreescribir rankings
# antiguos.
# CODIGOS DE ERROR:
#	0: Se efectuó la operación con éxito;
#	1: El archivo de reservas no pudo ser abierto;
#	2: No se pudo generar el archivo de rankings. Cantidad de rankings máxima;
#	3: El archivo de rankings a generar no pudo ser creado.
sub rankingDeSolicitantes {

	# Leemos valores de los argumentos
	$correspondeImprimir = $_[0];

	# Array con solicitantes mas rankeados
	my @rank = ();

	# Hash con emails de solicitantes y sus solicitudes
	my %solicitudes = ();

	# Abrimos el archivo de reservas
	open FILE, "$PROCDIR$RESERVASOK" or return 1;

	# Iteramos sobre las líneas del archivo
	while(<FILE>)
	{
		# Levantar los campos email y cantidad de butacas solicitadas
		@dataLinea = split(";", $_);
		$email_solicitante = $dataLinea[10];
		$cant_butacas_solicitadas = $dataLinea[9];

		# Contabilizamos la reserva
		$solicitudes{$email_solicitante} += $cant_butacas_solicitadas;
	}

	close(FILE);


	# Procesamos cada solicitante para armar el ranking
	for(keys %solicitudes) {
		# Insertamos par en array
		push(@rank, $_, [$solicitudes{$_}]);

		# Ordenamos el array
		@rank = sort {$a->[1] cmp $b->[1]} @rank;

		# Si hay mas de los que necesitamos en el ranking, quitamos el menor
		if((scalar @rank) > $RANK_CANT_PUESTOS) {
			shift(@rank);
		}
	}


	# Escribimos sobre un archivo de ser necesario
	if($correspondeImprimir)
	{
		$cantRepetidos = 1;

		# Contabilizamos la cantidad de archivos con el mismo nombre
		foreach(grep(/^($RANK_NOMBRE_ARCHIVO).(\d){3}$/, 
			readdir($REPODIR)))
		{
			$cantRepetidos += 1;
		}

		# Si la cantidad de digitos supera el máximo de 999 rankings
		# retornamos error.
		if($cantRepetidos >= 999) {
			return 2;
		}

		# Armamos nombre para el archivo de ranking
		$nombreArchivo = $REPODIR.$RANK_NOMBRE_ARCHIVO.
			numberPadding($cantRepetidos, 3);

		open(FILEHANDLER, "+>$nombreArchivo") or return 3;

		# Escribimos encabezados
		print FILEHANDLER "Ranking de 10 principales solicitantes de reservas.\n\n\n";
		print FILEHANDLER "CORREO ELECTRÓNICO\t\t\tCANTIDAD\n\n";

		# Imprimimos el ranking
		for($i = ((scalar @rank) - 1); $i >= 0; $i--) {
			print FILEHANDLER "@rank->[$i]->[0]\t\t\t\t\t@rank->[$i]->[1]\n";
		}

		close(FILEHANDLER);
	}


	# Imprimimos por pantalla el ranking
	print "Ranking de 10 principales solicitantes de reservas.\n\n\n";
	print "CORREO ELECTRÓNICO\t\t\tCANTIDAD\n\n";

	for($i = ((scalar @rank) - 1); $i >= 0; $i--) {
		print "@rank->[$i]->[0]\t\t\t\t\t@rank->[$i]->[1]\n";
	}

	return 0;
}





# ############################# #
# MAIN							#
# ############################# #


# Se obtiene la cantidad inicial de argumentos
my $cantArg = scalar @ARGV;

if($cantArg == 0) {
	print "$errorCantidadNulaDeParametros";
	exit 1;
}

# Se obtienen las opciones insertadas en linea de comandos
$ok = getopts('awidrt', \%Opciones);

if($ok) {

	# Se obtiene el tamanio del hash
	@claves = keys %Opciones;
	$tamanio = @claves;

	# Si hay mas de 2 opciones, se ingresaron mal los parametros
	if ($tamanio > 2) {
		print "$errorCombinacionOpciones";

	}

	# Si se repite alguna opcion, tambien hay un error
	elsif (($tamanio == 1 && $cantArg > 1) || ($tamanio == 2 && $cantArg > 2))
	{
		print "$errorRepeticion";	
	}

	# Si hay exactamente 2 opciones, se busca que exista -w.
	# Si hay una opcion, se busca que no exista ni -w ni -a
	elsif (($tamanio == 2 && exists $Opciones{'w'}) || ($tamanio == 1 && !exists $Opciones{'w'} && !exists $Opciones{'a'})) {
		if(exists $Opciones{'i'}) {
			print "Elegi i\n"; 
		}
		elsif (exists $Opciones{'d'}) {
			print "Elegi d \n"; 
			disponibilidad();
		}
		elsif (exists $Opciones{'r'}) {
			if (exists $Opciones{'w'}) {
				rankingDeSolicitantes(1);
			}
			else {
				rankingDeSolicitantes(0);
			}
		}
		elsif (exists $Opciones{'t'}) {
			print "Elegi t \n"; 
		}
		else {
			# Se ingreso la opcion -w en conjunto con la opcion -a
			print "$errorCombinacionOpciones";				
		}
	}

	# Si el tamanio es 1 y pidieron la ayuda
	elsif ($tamanio == 1 && exists $Opciones{'a'}) {
		#print $ayuda; 
		print `cat Ayuda`;
	}

	# Se ingresaron otra lista de opciones incorrectas
	else {
		print "$errorCombinacionOpciones";	
	}
}
else {
	print "$errorCombinacionOpciones";
}
