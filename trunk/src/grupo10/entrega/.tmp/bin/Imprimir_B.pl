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

require 'lib_utilities.pl';


################################## HARDCODEO

$PROCDIR = "../procesados/";
$RESERVASOK = "reservas.ok";
$REPODIR = "./";

################################## END HARDCODEO



### CONFIGURACIÓN

# Cantidad total de puestos en el ranking
$RANK_CANT_PUESTOS = 10;
# Nombre de archivo para el ranking
$RANK_NOMBRE_ARCHIVO = "ranking";

# Extensión para el archivo de tickets
$TICKET_EXT_ARCHIVO = ".tck";

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


sub disponibilidad {

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

	while ($linea != undef) {
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
		$cant_butacas_solicitadas = $dataLinea[9] * 1;

		# Contabilizamos la reserva
		$solicitudes{$email_solicitante} += $cant_butacas_solicitadas;
	}

	close(FILE);


	# Procesamos cada solicitante para armar el ranking
	for(keys %solicitudes)
	{
		# Insertamos par en array
		push(@rank, [$_, $solicitudes{$_}]);

		# Ordenamos el array
		@rank = sort {$a->[1] <=> $b->[1]} @rank;

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
		if(!opendir($REPODIR, $REPODIR)) { return 1; }

		foreach(grep(/^($RANK_NOMBRE_ARCHIVO).(\d){3}$/, 
			readdir($REPODIR)))
		{
			$cantRepetidos += 1;
		}

		closedir $REPODIR;

		# Si la cantidad de digitos supera el máximo de 999 rankings
		# retornamos error.
		if($cantRepetidos >= 999) {
			return 2;
		}

		# Armamos nombre para el archivo de ranking
		$nombreArchivo = $REPODIR.$RANK_NOMBRE_ARCHIVO.".".
			numberPadding($cantRepetidos, 3);

		open(FILEHANDLER, "+>$nombreArchivo") or return 3;

		# Escribimos encabezados
		print FILEHANDLER "Ranking de 10 principales solicitantes de reservas.\n\n\n";
		print FILEHANDLER "CANTIDAD\t\tCORREO ELECTRÓNICO\n\n";

		for($i = ((scalar @rank) - 1); $i >= 0; $i--) {
			print FILEHANDLER "$rank[$i][1]\t\t\t$rank[$i][0]\n";
		}

		close(FILEHANDLER);
	}


	# Imprimimos por pantalla el ranking
	print "Ranking de 10 principales solicitantes de reservas.\n\n\n";
	print "CANTIDAD\t\tCORREO ELECTRÓNICO\n\n";

	for($i = ((scalar @rank) - 1); $i >= 0; $i--) {
		print "$rank[$i][1]\t\t\t$rank[$i][0]\n";
	}

	return 0;
}



# Subrutina que se encarga de generar los tickets. Esto lo realiza solicitando
# al usuario que ingrese un ID del Combo para el cual desea generar los tickets
# a través de la entrada estandar. De no encontrarse el ID del combo se volverá
# a solicitar hasta validar la existencia del mismo.
# POST: se genera un archivo cuyo nombre será ID_DEL_COMBO.tck y donde sus
# sus registros poseeran como primer campo el Tipo de comprobante y los
# restantes poseen la información de la obra y el solicitante.
sub listadoDeTickets {

	my @reservas = ();

	# Solicitamos al usuario el ID del Combo
	print "Por favor ingrese el ID del Combo: ";
	$idCombo = <STDIN>;
	chomp($idCombo);

	$laClaveNoExiste = 1;

	while($laClaveNoExiste > 0)
	{
		# Abrimos el archivo de reservas
		open FILE, "$PROCDIR$RESERVASOK" or return 1;

		# Iteramos sobre las líneas del archivo
		while(<FILE>)
		{
			@dataLinea = split(";", $_);

			if(lc($idCombo) eq lc($dataLinea[7]))
			{
				# Insertamos linea en array
				push(@reservas, [$dataLinea[9], join(";", $dataLinea[1], 
					$dataLinea[2], $dataLinea[3], $dataLinea[5], 
					$dataLinea[8], $dataLinea[10])]);
			}
		}

		close(FILE);

		# Si se encontraron registros con el id del combo, salimos del bucle
		if((scalar @reservas) > 0) { 
			$laClaveNoExiste = 0; 
		}
		else {
			# Volvemos a solicitar un número de ID del combo
			print "El ID ingresado no existe. Por favor vuelva a ingresar otro ID del Combo: ";

			$idCombo = <STDIN>;
			chomp($idCombo);
		}
	}


	# Generamos el archivo de tickets
	$nombreArchivo = $REPODIR.$idCombo.$TICKET_EXT_ARCHIVO;

	open(FILEHANDLER, "+>$nombreArchivo") or return 3;

	for($i = 0; $i < (scalar @reservas); $i++) {
		
		# Caso en que la reserva no cuenta con confirmaciones
		if($reservas[$i][0] == 0){
			next;
		}
		# Caso en que la reserva cuenta con una sola confirmacion
		elsif($reservas[$i][0] == 1) {
			print FILEHANDLER "VALE POR 1 ENTRADA;$reservas[$i][1]\n";
		}
		# Caso en que la reserva cuenta con dos confirmaciones
		elsif($reservas[$i][0] == 2) {
			print FILEHANDLER "VALE POR 2 ENTRADAS;$reservas[$i][1]\n";
		}
		# Caso en que la reserva cuenta con mas de dos confirmaciones
		elsif($reservas[$i][0] > 2) {

			# Imprimimos para dos entradas
			for($k = 0; $k < int($reservas[$i][0] / 2); $k++){
				print FILEHANDLER "VALE POR 2 ENTRADAS;$reservas[$i][1]\n";
			}

			# Si queda un remamente de una entrada para completar, lo
			# generamos como un vale para una entrada.
			if(int($reservas[$i][0] % 2) > 0) {
				print FILEHANDLER "VALE POR 1 ENTRADA;$reservas[$i][1]\n";
			}
		}
	}

	close(FILEHANDLER); 
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
			listadoDeTickets();
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
