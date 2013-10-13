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
use Scalar::Util qw(looks_like_number);

require 'lib_utilities.pl';


################################## HARDCODEO

$PROCDIR = "../procesados/";
$RESERVASOK = "reservas.ok";
$COMBOSDIS = "combos.dis";
$REPODIR = "./";

################################## END HARDCODEO



### CONFIGURACIÓN

# Cantidad total de puestos en el ranking
$RANK_CANT_PUESTOS = 10;
# Nombre de archivo para el ranking
$RANK_NOMBRE_ARCHIVO = "ranking";

# Extensión para el archivo de tickets
$TICKET_EXT_ARCHIVO = ".tck";

# Extension para el archivo de disponibilidades
$DISPON_EXT_ARCHIVO = ".dis";

### FIN CONFIGURACION



### CONSTANTES PARA LOS TEXTOS DE ERRORES

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



### SUBRUTINAS


# Subrutina que imprime la ayuda por la salida estandar.
sub ayuda {
	print `cat Ayuda`;
}



# Subrutina que permite generar un listado de disponibilidades. Esta interactua
# con el usuario solicitandole ciertas especificaciones para poder procesar
# los combos. Este imprime por pantalla el listado, y de ser especificado, 
# también lo imprimira sobre un archivo siendo el nombre de este especificado
# por el usuario cuando el menú lo solicite.
# PRE: el único parámetro se refiere a si se desea grabar en un archivo el
# listado. De ser deseado este comportamiento, debe pasarse un valor distinto
# de cero como parámetro o cero en su defecto.
sub disponibilidad {

	# Leemos valores de los argumentos
	$correspondeImprimir = $_[0];

	# Preguntamos al usuario el criterio de busqueda
	print "Elija que desea buscar para generar el listado: \n\n";
	print "1- Por ID de OBRA\n";
	print "2- Por ID de SALA\n";
	print "3- Por rango de ID de OBRA\n";
	print "4- Por rango de ID de SALA\n\n";

	$esValido = 0;
	$numOpcion = 0;

	while(!$esValido)
	{
		print "Ingrese el número de opción: ";
		$numOpcion = <STDIN>;
		chomp($numOpcion);

		# Si se ingreso una opción válida salimos
		if(($numOpcion eq 1) || ($numOpcion eq 2) || ($numOpcion eq 3)
			|| ($numOpcion eq 4)){
			$esValido = 1;
			next;
		}

		print "Opción inválida. ";
	}



	# Variables auxiliares
	$campoDeBusqueda = 0;
	$esValido = 0;
	@ids = ();
	@combos = ();

	while(1)
	{
		# Opción 1 y 2
		if(($numOpcion eq 1) || ($numOpcion eq 2))
		{
			# Seleccionamos el campo sobre el que se hará la búsqueda
			if($numOpcion eq 1) { $campoDeBusqueda = 1 }
			elsif($numOpcion eq 2) { $campoDeBusqueda = 4 }

			# Solicitamos el ID
			while(1) {
				print "\nIngrese el ID: ";
				$id = <STDIN>;
				chomp($id);
				
				# Si no es un número, volvemos a solicitar el id
				if(!looks_like_number($id)) { 
					print "El valor ingresado es inválido. ";
					next;
				}

				# Insertamos el id para ser procesado luego
				push(@ids, $id);
				last;
			}
		}
		# Opción 3 y 4
		elsif(($numOpcion eq 3) || ($numOpcion eq 4))
		{
			# Seleccionamos el campo sobre el que se hará la búsqueda
			if($numOpcion eq 3) { $campoDeBusqueda = 1 }
			elsif($numOpcion eq 4) { $campoDeBusqueda = 4 }

			# Solicitamos al usuario el rango de IDs
			while(1) {
				print "\nIngrese el rango de IDs utilizando un guion como separador de los extremos (e.g. 3-10): ";
				$id = <STDIN>;
				chomp($id);

				@rango = split("-", $id);

				# Si se recibieron mas de 3 valores como rango, volvemos a pedir
				if((scalar @rango) > 2) {
					print "El rango ingresado es inválido. ";
					next;
				}
				# Si no es un número, volvemos a solicitar el id
				elsif(!looks_like_number($rango[0]) || 
					!looks_like_number($rango[1])) { 
					print "El rango ingresado es inválido. ";
					next;
				}
				elsif(int($rango[0]) > int($rango[1])){
					print "El rango ingresado es inválido. ";
					next;
				}

				# Insertamos el id para ser procesado luego
				for($i = $rango[0]; $i <= $rango[1]; $i++)
				{
					push(@ids, $i);
				}

				last;
			}
		}


		## Procesamos los combos

		# Abrimos el archivo de combos
		open FILE, "$PROCDIR$COMBOSDIS" or return 1;

		# Iteramos sobre las líneas del archivo
		while(<FILE>)
		{
			@dataLinea = split(";", $_);

			for($i = 0; $i < (scalar @ids); $i++)
			{
				if($ids[$i] eq $dataLinea[$campoDeBusqueda])
				{
					# Insertamos linea en array
					push(@combos, join(" - ", $dataLinea[0], $dataLinea[1],
						$dataLinea[2], $dataLinea[3], $dataLinea[4],
						$dataLinea[5], $dataLinea[6]));
				}
			}
		}

		close(FILE);


		# Si se encontraron registros con el id del combo, salimos del bucle
		if((scalar @combos) > 0) { 
			last;
		}
		else {
			# Volvemos a solicitar un número de ID del combo
			print "\nEl ID o rango de IDs ingresado no existe.";
		}
	}

	
	# Si corresponde imprimir solicitamos al usuario el nombre del archivo	
	if($correspondeImprimir) {
		
		my $nombreArchivo = "";

		while(1) {
			print "\nIngrese un nombre de archivo para el listado: ";
			$nombreArchivo = <STDIN>;
			chomp($nombreArchivo);

			if(!($nombreArchivo eq "") and (index($nombreArchivo, "/") eq -1))
			{
				last;
			}

			print "\nEl nombre de archivo ingresado no es válido.";
		}
		
		$nombreArchivo = $REPODIR.$nombreArchivo.$DISPON_EXT_ARCHIVO;

		open(FILEHANDLER, "+>$nombreArchivo") or die "No se pudo crear el archivo.";

		# Escribimos encabezados
		foreach (@combos) {
			print FILEHANDLER "$_\n";
		}

		close(FILEHANDLER);
	}


	# Imprimimos por pantalla
	foreach (@combos) {
		print "$_\n";
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
# a solicitar hasta validar la existencia del mismo. Este imprime por pantalla
# el listado, y de ser especificado, también lo imprimira sobre un archivo.
# PRE: el único parámetro se refiere a si se desea grabar en un archivo los
# tickets. De ser deseado este comportamiento, debe pasarse un valor distinto
# de cero como parámetro o cero en su defecto.
# POST: se genera un archivo cuyo nombre será ID_DEL_COMBO.tck y donde sus
# sus registros poseeran como primer campo el Tipo de comprobante y los
# restantes poseen la información de la obra y el solicitante.
sub listadoDeTickets {

	# Leemos valores de los argumentos
	$correspondeImprimir = $_[0];

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

	# Escribimos sobre un archivo de ser necesario
	if($correspondeImprimir)
	{
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

	# Imprimimos tickets por pantalla
	for($i = 0; $i < (scalar @reservas); $i++) {
		
		# Caso en que la reserva no cuenta con confirmaciones
		if($reservas[$i][0] == 0){
			next;
		}
		# Caso en que la reserva cuenta con una sola confirmacion
		elsif($reservas[$i][0] == 1) {
			print "VALE POR 1 ENTRADA;$reservas[$i][1]\n";
		}
		# Caso en que la reserva cuenta con dos confirmaciones
		elsif($reservas[$i][0] == 2) {
			print "VALE POR 2 ENTRADAS;$reservas[$i][1]\n";
		}
		# Caso en que la reserva cuenta con mas de dos confirmaciones
		elsif($reservas[$i][0] > 2) {

			# Imprimimos para dos entradas
			for($k = 0; $k < int($reservas[$i][0] / 2); $k++){
				print "VALE POR 2 ENTRADAS;$reservas[$i][1]\n";
			}

			# Si queda un remamente de una entrada para completar, lo
			# generamos como un vale para una entrada.
			if(int($reservas[$i][0] % 2) > 0) {
				print "VALE POR 1 ENTRADA;$reservas[$i][1]\n";
			}
		}
	}
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
		
		# Evaluamos si va a escribirse en archivo
		if (exists $Opciones{'w'}) { $escribir = 1; }
		else { $escribir = 0; }

		if(exists $Opciones{'i'}) {
			print "Elegi i\n"; 
		}
		elsif (exists $Opciones{'d'}) {
			disponibilidad($escribir);
		}
		elsif (exists $Opciones{'r'}) {
			rankingDeSolicitantes($escribir);
		}
		elsif (exists $Opciones{'t'}) {
			listadoDeTickets($escribir);
		}
		else {
			# Se ingreso la opcion -w en conjunto con la opcion -a
			print "$errorCombinacionOpciones";				
		}
	}

	# Si el tamanio es 1 y pidieron la ayuda
	elsif ($tamanio == 1 && exists $Opciones{'a'}) {
		ayuda();
	}

	# Se ingresaron otra lista de opciones incorrectas
	else {
		print "$errorCombinacionOpciones";	
	}
}
else {
	print "$errorCombinacionOpciones";
}
