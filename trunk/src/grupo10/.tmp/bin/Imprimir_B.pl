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
# Comando que se encarga de Imprimir listados por pantalla (o grabarlos en archivo 
# si corresponde): Ranking de solicitantes, listado de disponibilidades
# listado de invitados a cierto evento o impresión de tickets.
#



#!/usr/bin/perl 
use warnings;
use Getopt::Std;
use Scalar::Util qw(looks_like_number);
use Switch;

require 'lib_utilities.pl';

$RESERVASOK = "$ENV{'PROCDIR'}/reservas.ok";
$COMBOSDIS = "$ENV{'PROCDIR'}/combos.dis";

# Variable que representa caracteres ascii y no ascii, salvo el delimitador ';'
$CHAR_SIN_PC="[\x00-\x3A|\x3C-\xFF]";
# Variable que representa caracteres ascii y no ascii, salvo el delimitador '.'
$CHAR_SIN_P="[\x00-\x2D|\x2F-\xFF]";


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



# Variable que contiene el mensaje de error para el caso en que no se han
# especificado parámetros de entrada.
$errorCantidadNulaDeParametros = "No se han especificado parámetros de entrada. Para mas información ejecute: Imprimir_B.pl -a\n";

# Variable que contiene el mensaje de error de combinacion de opciones
$errorCombinacionOpciones = "
Ha ingresado una combinacion de opciones incorrecta. Por favor, verifique que el comando ingresado 
sea correcto y vuelva a intentarlo.
Para ver la ayuda, ingrese: perl Imprimir_B -a.\n\n";

# Variable que contiene el mensaje de error de repeticion de opciones
$errorRepeticion = "
Ha ingresado una o varias opciones repetidas. Por favor, verifique que el comando ingresado sea correcto y vuelva a intentarlo.
Para ver la ayuda, ingrese: perl Imprimir_B -a.\n\n";



### SUBRUTINAS


# Subrutina que imprime la ayuda por la salida estandar.
sub ayuda {
	# print `cat .Ayuda`;	
	system("less .Ayuda");
}

# Subrutina que genera un menu interactivo para el usuario
sub displayMenu {
	$opcion = 2;
	# Variable que guarda si debe guardar en archivo
	$debeGuardarArchivo = 0;
	do {
		if ( grep(/^p?[23456]$/, $opcion) ){
			# Se imprime el menu
			print `cat .MenuImprimir`;
		}
		else {
			print "N° de Opción: ";
		}
		# Se obtiene la opción
		$opcion = <STDIN>;
		# Se elimina el \n
		chop($opcion);
		# Se modifica si debe guardar en archivo
		$debeGuardarArchivo = 0;
		# - Si presiono '6'-> salir.
		if ( grep(/^6$/, $opcion) ) {
			print "Adiós!\n";
			# Se retorna de la función con un 1
			return 1;
		}
		# - Si presionó '1', mostrar ayuda
		elsif ( grep(/^1$/, $opcion) ) {
			ayuda();
		}
		# Si empieza con 'p', se busca que este entre 2 y 5 la opción
		elsif ( grep(/^p?[2-5]$/, $opcion) ) {
			if ( grep(/^p/, $opcion) ) {
				$debeGuardarArchivo = 1;
				$opcion = `echo $opcion | grep -o [2-5]`;
				chop($opcion);
			}
			switch ($opcion) {
				case 2 { print "\nDISPONIBILIDADES\n"; disponibilidad($debeGuardarArchivo); }
				case 3 { print "\nINVITADOS\n"; invitadosAEvento($debeGuardarArchivo); }
				case 4 { print "\nRANKING\n"; rankingDeSolicitantes($debeGuardarArchivo); }
				case 5 { print "\nTICKETS\n"; listadoDeTickets($debeGuardarArchivo); }
			}
		}
		# Sino, se eligió una opción incorrecta
		else {
			print "Ud. eligió la opción \"$opcion\" y es incorrecta. Por favor vuelva a intentarlo.\n";
		}
		
	} while(1)
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

		print "Opción inválida. \n";
	}

	print "\n(Recuerde que los ID Obra son números impares y los ID Sala son números pares).";

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
		open FILE, "$COMBOSDIS" or die "No existe el archivo 'combos.dis' o no es posible abrirlo.\n";

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
			print "\nIngrese un nombre de archivo para el listado sin su extensión (no puede ser 'combos'): ";
			$nombreArchivo = <STDIN>;
			chomp($nombreArchivo);

			if(!($nombreArchivo eq "") and (index($nombreArchivo, "/") eq -1) and !($nombreArchivo eq "combos") )
			{
				last;
			}

			print "\nEl nombre de archivo ingresado no es válido.";
		}
		
		$nombreArchivo = $ENV{'REPODIR'}."/".$nombreArchivo.$DISPON_EXT_ARCHIVO;

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
	open FILE, "$RESERVASOK" or die "No existe el archivo 'reservas.ok' o no es posible abrirlo\n";

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
		if(!opendir(DIR, $ENV{'REPODIR'})) { return 1; }

		foreach(grep(/^($RANK_NOMBRE_ARCHIVO).(\d){3}$/, 
			readdir(DIR)))
		{
			$cantRepetidos += 1;
		}

		closedir DIR;

		# Si la cantidad de digitos supera el máximo de 999 rankings
		# retornamos error.
		if($cantRepetidos >= 999) {
			return 2;
		}

		# Armamos nombre para el archivo de ranking
		$nombreArchivo = $ENV{'REPODIR'}."/".$RANK_NOMBRE_ARCHIVO.".".
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
		open FILE, "$RESERVASOK" or return 1;

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
		$nombreArchivo = $ENV{'REPODIR'}."/".$idCombo.$TICKET_EXT_ARCHIVO;

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
 
## Subrutinas correspondientes a la opción i de Imprimir ##

# Subrutina que guarda en la tabla de candidatos el evento correspondiente
sub guardarEnCandidatos {
	# Se guardan los parametros
	my $ref_int = $_[0];
	my $combo = $_[0];
	my $butacas = $_[0];
	
	# Se obtiene el valor de la referecia interna
	$ref_int =~ s/^($CHAR_SIN_PC+;){8}($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){4}$/$2/;

	# Se obtiene el valor del combo
	$combo =~ s/^(($CHAR_SIN_PC+;){5}($CHAR_SIN_PC+))(;$CHAR_SIN_PC+;)($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){5}$/$5;$1/;

	# Se obtiene la cantidad de butacas reservadas
	$butacas =~ s/^($CHAR_SIN_PC+;){9}($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){3}$/$2/;

	# Para cada uno, se chequea si existe un archivo RI.inv
	my @validos = grep(/^$ref_int.inv$/, @archivos);

	# Si encontro algun archivo, lo guarda en la tabla
	if (@validos) {
		# Se guarda el valor del nombre del archivo
		my $valor = $validos[0];

		# Si ya existe una entrada para este combo, se añade a la lista
		if ( exists($candidatos{$combo}) ) {
			# Se chequea para no duplicar la entrada
			if ( !grep(/^$valor$/, @{$candidatos{$combo}}) ) {
				# Se agrega a la tabla la referencia interna
				push (@{$candidatos{$combo}}, $validos[0]);
			}
		}
		# Sino, se inserta una nueva entrada
		else {
			# Inserto en la tabla
			@{$candidatos{$combo}} = $validos[0];
		}
		# Se agrega la cantidad de butacas confirmadas por esa referencia interna
		# Si existe el valor en la tabla, entonces se suma, sin se lo agrega.
		if ( exists($cant_reservas_ok{$ref_int}) ) {
			$cant_reservas_ok{$ref_int} += $butacas;
		}
		else {
			$cant_reservas_ok{$ref_int} = $butacas;
		}
	}
}

# Subrutina que procesa la opcion ingresara por el usuario
# Recibe como parametros: 1- El numero maximo de opción, 2- Si debe guardar en archivo
sub procesarOpcion {
	# DEBUG
	my $opcion = "";
	my $mayor_opcion = $_[0];
	my $debeGuardarArchivo = $_[1];

	# Se lee la opcion provista por el usuario
	do {
		print "Número o código de evento (Si desea salir, presione 'S'):  ";
		
		# Se lee una opcion
		$opcion = <STDIN>;

		# Se elimina el \n o \r
		chop($opcion);

		print "\n";

		# Se comprueba que sea correcta:
		# - Si presiono 's' o 'S' -> salir.
		if ( grep(/^[sS]$/, $opcion) ) {
			print "Ud. decidió salir. Adiós!\n";
			# Se retorna de la función con un 1
			return 1;
		}
		# - Si empieza con 'C', se chequea que sea un evento valido
		elsif ( grep(/^C/, $opcion) ){
			# Si existe -> imprimir lista y salir.
			foreach ( keys %candidatos ) {
				if ( grep(/^$opcion;/, $_) ) {
					print "Ud. ingresó el código: \"$opcion\"\n";
					# Se imprime la lista de invitados pasandole el combo por parametros
					imprimirLista($_, $debeGuardarArchivo);
					# Se retorna de la función con un 1
					return 0;
				}
			}
			# Si no existe -> pedir nuevo ingreso
			print "Ud. ingresó \"$opcion\" y es una opción incorrecta. Intente nuevamente:\n";
		}
		elsif ($opcion le $mayor_opcion && $opcion ge 0) {
			print "Ud. ingresó el número de evento: \"$opcion\"\n";
			# Se imprime la lista de invitados pasandole el combo por parametros
			imprimirLista($claves_i[$opcion - 1], $debeGuardarArchivo);
			# Se cambia el flag
			return 0;
		}
		else {
			print "Ud. ingresó \"$opcion\" y es una opción incorrecta. Intente nuevamente:\n";
		}
	} while (1);
}


# Subrutina que imprime la lista de invitados a cierto evento.
# Se recibe por parametros: 1- Combo, 2- Si debe imprimir en archivo
sub imprimirLista {
	my $combo = $_[0];
	my $ok = $_[1];
	my $evento = $combo;
	my $obra = $combo;
	my $sala = $combo;
	my $fecha = $combo;
	my $referencia;
	my $num_referencia;
	my $cant_invitados;
	my $total_invitados;
	my $invitado;

	# Se obtiene la lista de referencias internas para el evento
	my @listaRef = @{$candidatos{$combo}};

	# Se obtienen los elementos a imprimir
	$evento =~ s/^($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){6}/$1/;
	$obra =~ s/^($CHAR_SIN_PC+);($CHAR_SIN_PC+);($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){4}/$2-$3/;
	$fecha =~ s/^($CHAR_SIN_PC+;){3}($CHAR_SIN_PC+);($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){2}/$2-$3/;
	$sala =~ s/^($CHAR_SIN_PC+;){5}($CHAR_SIN_PC+);($CHAR_SIN_PC+)$/$2-$3/;

	# Se crea el archivo a escribir si corresponde (si existe, se lo vacia)
	if ( $ok ) {
		open(ARCH, ">$ENV{'REPODIR'}/$evento.inv") or die "No se pudo crear el archivo '$evento.inv\n";
	}
	else {
		open(VACIO, ">/dev/null");
	}

	# Se los imprime
	print "Evento: $evento. Obra: $obra. Fecha y Hora: $fecha Hs. Sala: $sala.\n";
	print { $ok ? ARCH : VACIO } "Evento: $evento. Obra: $obra. Fecha y Hora: $fecha Hs. Sala: $sala.\n";

	# Para el id combo seleccionado, se imprime la lista de invitados
	foreach ( @{$candidatos{$combo}} )  {
		# Se resetea el valor acumulado de cantidad de invitados
		$total_invitados = 0;

		# Se le quita la extension '.inv' que contiene la referencia interna
		$referencia = $_;
		$num_referencia = $_;
		$num_referencia =~ s/^($CHAR_SIN_P+).inv/$1/;

		# Se imprime la referencia actual
        print "Referencia: $num_referencia\n";
        print { $ok ? ARCH : VACIO } "Referencia: $num_referencia\n";
        
        # Si el archivo de invitados se encuentra vacio, se imprime mensaje correspondiente
        if (-z "$referencia" ) {
        	print "Sin listado de invitados.\n";
        	print { $ok ? ARCH : VACIO } "Sin listado de invitados.\n";
        }
        else {
	        # Se abre el archivo y se imprimen los invitados correspondientes
	        my @imprimir = split("\n|\n\r|\r\n", `cat $ENV{'REPODIR'}/$referencia`);
	        foreach (@imprimir) {
	        	$invitado = $_;
	        	$cant_invitados = $_;

	        	# Se queda con el nombre del invitado
	        	$invitado =~ s/^($CHAR_SIN_PC+)(;$CHAR_SIN_PC*);($CHAR_SIN_PC*)/$1/;

	        	# Se queda solamente con la cantidad de acompañantes
	        	$cant_invitados =~ s/^($CHAR_SIN_PC+)(;$CHAR_SIN_PC*);($CHAR_SIN_PC*)/$3/;

	        	# Si el campo de cantidad de acompañantes existia, entonces se lo suma al total y se imprime
	        	if ( $cant_invitados ) {
		        	# Se acumula al total de invitados lo recien calculado
		        	$total_invitados += $cant_invitados + 1;
	        	}
	        	# Si ese campo no estaba, se le guarda el valor de 0
	        	else {
	        		# Se le guarda un 0
	        		$cant_invitados = 0;
	        		# Se le suma uno a la cantidad total de invitados
	        		$total_invitados += 1;
	        	}

	        	# Se imprime el mensaje al usuario
	        	print "\t- $invitado, $cant_invitados, $total_invitados\n";
	        	print { $ok ? ARCH : VACIO } "\t- $invitado, $cant_invitados, $total_invitados\n";
	        }
		}
		# Se imprime la cantidad de butacas confirmadas
		print "\t* Cantidad de reservas confirmadas: $cant_reservas_ok{$num_referencia}\n";
		print { $ok ? ARCH : VACIO } "\t* Cantidad de reservas confirmadas: $cant_reservas_ok{$num_referencia}\n";
		print "\t* Total acumulado de invitados: $total_invitados\n";
		print { $ok ? ARCH : VACIO } "\t* Total acumulado de invitados: $total_invitados\n";
    }

	# Si corresponde, se cierar el archivo
	if ( $ok ) {
		close(ARCH);
	}
	else {
		close VACIO;
	}
}

# Recibe por parametros si debe guardar en archivo o no
sub invitadosAEvento {
	my $debeGuardarArchivo = $_[0];

	# Variable que contiene los eventos candidatos
	our %candidatos;
	# Guarda la cantidad de reservas aceptadas por cada referencia interna
	our %cant_reservas_ok;
	our @claves_i;
	my $linea;
	my $k = 1;
	my $i = 1;

	# Se busca en el archivo 'reservas.ok' los registros que contienen referencia interna
	open(reservas_ok, "<$ENV{'PROCDIR'}/reservas.ok") or die "No se pudo abrir el archivo 'reservas.ok'";

	# Se lee una linea
	$linea = <reservas_ok>;

	# Se obtiene la lista de archivos en REPODIR '.inv' separados con coma
	my $lista_archivos=`ls -mp $ENV{'REPODIR'}`;

	# Se guarda la lista en un array, salteando los caracteres de separador
	our @archivos = split(", |,\n", $lista_archivos);

	# Para cada linea, se toma la que tenga referencia interna del solicitante
	while($linea){

		# Si la linea contiene el campo opcional de la ref interna del solicitante,
		if ($linea =~ m[($CHAR_SIN_PC+;){12}$CHAR_SIN_PC+]) {

			# Se guardan los campos en la tabla de candidatos
			guardarEnCandidatos $linea;
		}

		# Se lee otra linea
		$linea = <reservas_ok>;
	}
	# Se cuenta la cantidad de claves que hay
	@claves_i = keys %candidatos;
	$tam = @claves_i;

	my $codigo_evento="";

	# Se emite un mensaje al usuario
	if ($tam == 0) {
		print "Lo lamentamos, no hay eventos candidatos a imprimir.\n";
	}
	else {
		print "Hay $tam evento/s candidato/s y es/son:\n";

		# Se le presenta al usuario el listado de candidatos
		for ($k = 0; $k < $tam; $k++) {
			$i = $k + 1;
			# Se guarda el codigo evento y se lo edita para obtener solamente 'C[0-9]+'
			$codigo_evento = $claves_i[$k];
			$codigo_evento =~ s/^($CHAR_SIN_PC+)(;$CHAR_SIN_PC+){6}$/$1/;

			# Se imprime un mensaje al usuario
			print "\t- Evento $i con código: $codigo_evento\n";
			# print "- Evento $i con código: $codigo_evento tiene los siguientes valores: \n";
			# foreach (@{$candidatos{$claves_i[$k]}}) {
			# 	print "\t- $_\n";
			# }
		}

		# Se emite mensaje al usuario
		print "NOTA: Para seleccionar algún evento a imprimir, por favor seleccione por número de evento o por código.\n";

		# Se procesa la opcion ingresada por el usuario
		# Se le pasa ademas si debe imprimir o no en archivo
		procesarOpcion $i, $debeGuardarArchivo;
	}

	# Se cierra el archivo de reservas ok
	close(reservas_ok);
}




# ############################# #
# MAIN							#
# ############################# #

# Variables
my %Opciones;
# Se obtiene la cantidad inicial de argumentos
my $cantArg = scalar @ARGV;

# Si no esta Inicializado el AMBIENTE sale con retorno 1 y no ejecuta el comando
if ( -z $ENV{'GRUPO'} ) {
        print "ERROR: Falta inicializar Ambiente";
        exit 1;
}

# Verifico que Imprimir no se encuentre en ejecución
my $proceso_viejo=`pgrep -o "Imprimir_B.pl"`;
my $proceso_nuevo=`pgrep -n "Imprimir_B.pl"`;
if ( $proceso_viejo ne $proceso_nuevo ) {
        print "ERROR: Ya se encuentra corriendo un Imprimir_B.pl";
        exit 2;
}

# Si no hay argumentos,
if($cantArg == 0) {
	print "$errorCantidadNulaDeParametros";
	exit 1;
}


# Se obtienen las opciones insertadas en linea de comandos
$ok = getopts('awidrtm', \%Opciones);

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
	# Si hay una opcion, se busca que no exista ni -w ni -a ni -m
	elsif (($tamanio == 2 && exists $Opciones{'w'}) || ($tamanio == 1 && !exists $Opciones{'w'} && !exists $Opciones{'a'} && !exists $Opciones{'m'})) {
		
		# Evaluamos si va a escribirse en archivo
		if (exists $Opciones{'w'}) { $escribir = 1; }
		else { $escribir = 0; }

		if(exists $Opciones{'i'}) {
			invitadosAEvento($escribir);
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

	# Si el tamanio es 1 y pidieron el menu interactivo
	elsif ($tamanio == 1 && exists $Opciones{'m'}) {
		displayMenu();
	}

	# Se ingresaron otra lista de opciones incorrectas
	else {
		print "$errorCombinacionOpciones";	
	}
}
else {
	print "$errorCombinacionOpciones";
}
