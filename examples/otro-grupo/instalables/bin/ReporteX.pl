#!/usr/bin/perl -w

sub separador{
	for (my $i = 0; $i < (split(/ /,`/bin/stty size`))[1]/4; $i+=1){ print "----"; };
	for (my $i = 0; $i < (split(/ /,`/bin/stty size`))[1]%4; $i+=1){ print "-"; };
	print "\n";
}

sub mostrarAyuda{
	separador();
	print "ReporteX: El propósito de este comando es resolver, mostrar y, eventualmente, grabar consultas.\n";
	print "Opciones:\n";
	print "\t-a\t\tMuestra el menu de ayuda\n";
	print "\t-g\t\tPermita grabar el resultado de la consulta.\n";
	separador();
	exit 0;
}

sub menuPrincipal{
	separador();
	print "ReporteX: El propósito de este comando es resolver, mostrar y, eventualmente, grabar consultas.\n";
	print "Consultas:\n";
	print "\ta:\t\tComparación para el recalculo.\n";
	print "\tb:\t\tDiferencia (en valor absoluto) mayor cierto porcentaje.\n";
	print "\tc:\t\tDiferencia (en valor absoluto) mayor cierto monto.\n";
	print "\tz:\t\tSalir.\n";
	separador();
	
	print "\nIngrese una opción: ";
	$entrada = <STDIN>;
	chomp($entrada);	
	print "\n"; 
	
	#Loop infinito hasta que se ingrese opcion valida
	while( !($entrada =~ m/[a b c z]/i) || (length($entrada) > 1) ){
		print "Opcion incorrecta. Intente nuevamente\n";
		$entrada = <STDIN>;
		chomp($entrada);		
	}
	return $entrada;
}

sub validarPais{
	my $existe = 0;

	opendir(DIR, $PROCDIR) or die $!;
	my $codigoPais = getCodigo($pais, 1);   
	while (my $file = readdir(DIR)) {
		if($file eq "$PRESPAIS"."$codigoPais"){
			$existe = 1;
		}
    }
    closedir(DIR);
	return $existe;
}
sub esAnio{
	my $anio = shift;
	return($anio =~ m/^\d+$/ && $anio < 2014 && $anio > 0);
}

sub esMes{
	my $mes = shift;
	return($mes =~ m/^\d+$/ && $mes < 13 && $mes > 0);
}

sub esPeriodo{
	my $anioDesde = shift(@_);
	my $mesDesde = shift(@_);
	my $anioHasta = shift(@_);
	my $mesHasta = shift(@_);
	
	if(!esAnio($anioDesde) || !esMes($mesDesde) || !esAnio($anioHasta) || !esMes($mesHasta)){
		print "No es un periodo valido";		
		return 0;	
	} else {
		if($anioDesde < $anioHasta){
		return 1;	
		} elsif ($anioDesde == $anioHasta && $mesDesde <= $mesHasta){
			return 1;		
		}
	}
	print "No es un periodo valido";
	return 0;
}

sub validarPeriodo{
	my @array_periodo = split(" - ",$periodo);	
	my %periodo = (SoloAnio => 0, AnioYMes => 0, Periodo => 0, Fecha => \@array_periodo);	
	if(scalar @array_periodo > 0){
		if(exists($array_periodo[0]) && exists($array_periodo[1]) && exists($array_periodo[2]) && exists($array_periodo[3])){
			$periodo{Periodo} = 1;
			if (esPeriodo(@array_periodo)){
				return %periodo;	
			}
		} elsif(exists($array_periodo[0]) && exists($array_periodo[1]) && !exists($array_periodo[2]) && !exists($array_periodo[3])){
			$periodo{AnioYMes} = 1;
			if (esAnio($array_periodo[0]) && esMes($array_periodo[1])){
				return %periodo;	
			}				
		} elsif(exists($array_periodo[0]) && !exists($array_periodo[1]) && !exists($array_periodo[2]) && !exists($array_periodo[3])){
			$periodo{SoloAnio} = 1;
			if (esAnio($array_periodo[0])){
				return %periodo;	
			}		
		}			
	}
	return 0;		
}

sub validarPorcentaje{
	my $porcentaje = shift(@_);
	return ($porcentaje =~ /^[+-]?\d+(\.\d+)?$/ && $porcentaje >= 0);
}

sub validarMonto{
	my $monto = shift(@_);
	return ($monto =~ /^[+-]?\d+(\.\d+)?$/ && $monto >= 0);
}	

sub ingresarPais{
	print "Ingresar un nombre de país para seleccionar el archivo de presupuesto a usar en la consulta.\n";

	$pais = <STDIN>;
	chomp($pais);
	while (!validarPais($pais)){
		print $pais. " no es un pais correcto. Ingrese otro pais.\n";
		$pais = <STDIN>;
		chomp($pais);	
	}
	return $pais;
}

sub ingresarPorcentaje{
	print "Ingrese el porcentaje de comparacion.\n";

	$porcentaje = <STDIN>;
	chomp($porcentaje);
	while (!validarPorcentaje($porcentaje)){
		print $porcentaje. " no es un porcentaje valido. Ingrese otro porcentaje.\n";
		$porcentaje = <STDIN>;
		chomp($porcentaje);	
	}
	return $porcentaje;
}

sub ingresarMonto{
	print "Ingrese el monto de comparacion.\n";

	$monto = <STDIN>;
	chomp($monto);
	while (!validarMonto($monto)){
		print $monto. " no es un porcentaje valido. Ingrese otro porcentaje.\n";
		$monto = <STDIN>;
		chomp($monto);	
	}
	return $monto;
}

sub ingresarSistema{
	print "Ingrese el sistema (si desea filtrar por todos los sistemas, ingrese TODOS).\n";	
	
	$sistema = <STDIN>;
	chomp($sistema);
	return $sistema;
}

sub ingresarPeriodo{
	print "Ingrese el periodo sobre el cual desea filtrar. Debe ingresar AñoDesde, MesDesde, AñoHasta, MesHasta.\n";
	print "En caso de ingresar solo AñoDesde se filtrará por ese año completo.\n";
	print "En caso de ingresar solo AñoDesde y MesDesde se filtrará por ese año y mes completo.\n";
	print "En caso de ingresar todos los parametros se filtrará por dicho periodo.\n";
	print "En caso de no ingresar nada se filtrará para cualquier fecha.\n";
	print "Debe ingresar el periodo de la forma: AñoDesde - MesDesde - AñoHasta - MesHasta.\n"; 	
	print "Ejemplo de uso: 1991 - 5 - 2001 - 3.\n"; 

	$periodo = <STDIN>;
	chomp($periodo);

	while (!validarPeriodo($periodo)){
		print "Periodo invalido. Ingrese nuevamente.\n";
		print "Debe ingresar el periodo de la forma: AñoDesde - MesDesde - AñoHasta - MesHasta.\n"; 	
		print "Ejemplo de uso: 1991 - 5 - 2001 - 3.\n"; 
		$periodo = <STDIN>;
		chomp($periodo);
	}
	return validarPeriodo($periodo);
}

sub getCodigo{
	my $valor = shift(@_);
	my $posicion = shift(@_);
	my @regs;
	if (-e $MAEDIR.$MAEPS) {
		open(FILE, $MAEDIR.$MAEPS) or die "Falla al abrir ".$MAEDIR.$MAEPS;
		$ifs = "-";	
		while($reg=<FILE>){			
			@regs  = split($ifs, $reg);
			chomp(@regs);
			if($valor eq $regs[$posicion]){
				return $regs[$posicion-1];
			}
		}
		close(FILE);
	}else{
		print "El archivo de maestro de paises sistemas es inexistente.\n";
		exit;	
	}
	return 0;
}

sub getCodigoSistema{
	my $sistema = shift(@_);
	if($sistema eq "TODOS"){
		return $sistema;
	}else{
		return getCodigo($sistema, 3);	
	}
}

sub recalculoPorSmor{
	my $recalculo_maestro = shift(@_);
	my $recalculo_prestamos = shift(@_);
	if($recalculo_maestro eq "SMOR" && $recalculo_prestamos ne "SMOR"){
		return 1;
	}
	return 0;
}

sub ingresarParametrosA{
	my $pais = ingresarPais();	
	my $sistema = ingresarSistema();
	my %periodo = ingresarPeriodo();

	my $codigoPais = getCodigo($pais, 1);
	if(!$codigoPais){
		print "Pais inexistente en archivo maestro.\n";	
	}
	
	my $codigoSistema = getCodigoSistema($sistema);
	if(!$codigoSistema){
		print "Sistema inexistente en archivo maestro.\n"
	}

	my %parametros = (CodigoPais => $codigoPais, CodigoSistema => $codigoSistema, Periodo => \%periodo);
	return %parametros;
}

sub ingresarParametrosB{
	my $pais = ingresarPais();	
	my $sistema = ingresarSistema();
	my $porcentaje = ingresarPorcentaje();
	my %periodo = ingresarPeriodo();

	my $codigoPais = getCodigo($pais, 1);
	if(!$codigoPais){
		print "Pais inexistente en archivo maestro.\n";	
	}
	
	my $codigoSistema = getCodigoSistema($sistema);
	if(!$codigoSistema){
		print "Sistema inexistente en archivo maestro.\n"
	}

	my %parametros = (CodigoPais => $codigoPais, CodigoSistema => $codigoSistema, Periodo => \%periodo);
	return %parametros;
}

sub ingresarParametrosC{
	my $pais = ingresarPais();	
	my $sistema = ingresarSistema();
	my $monto = ingresarMonto();
	my %periodo = ingresarPeriodo();

	my $codigoPais = getCodigo($pais, 1);
	if(!$codigoPais){
		print "Pais inexistente en archivo maestro.\n";	
	}
	
	my $codigoSistema = getCodigoSistema($sistema);
	if(!$codigoSistema){
		print "Sistema inexistente en archivo maestro.\n"
	}

	my %parametros = (CodigoPais => $codigoPais, CodigoSistema => $codigoSistema, Periodo => \%periodo);
	return %parametros;
}

sub filtrarPorPais{
	my $codigoPais = shift(@_);
	my $periodo_ref = shift(@_);
	my @result; #array de lineas coincidentes con filtros
	my $i = 0; #iterador
	
	open(FILE, $MAEDIR.$MAEPPI) or die "Falla al abrir ".$MAEDIR.$MAEPPI;
	$ifs = ";";	

	while($reg=<FILE>){ 
		my @regs  = split($ifs, $reg);		
		chomp(@regs);
		if(${$periodo_ref}{SoloAnio}){
			my $anio = ${$periodo_ref}{Fecha}[0];
			if($regs[0] eq $codigoPais && $regs[2] == $anio){
				$result[$i] = $reg;
				$i++;	
			}		
		}elsif(${$periodo_ref}{AnioYMes}){
			my $anio = ${$periodo_ref}{Fecha}[0];
			my $mes = ${$periodo_ref}{Fecha}[1];
			if($regs[0] eq $codigoPais && $regs[2] == $anio && $regs[3] == $mes){
				$result[$i] = $reg;
				$i++;	
			}		
		}elsif(${$periodo_ref}{Periodo}){
			my $anioDesde = ${$periodo_ref}{Fecha}[0];
			my $mesDesde = ${$periodo_ref}{Fecha}[1];
			my $anioHasta = ${$periodo_ref}{Fecha}[2];
			my $mesHasta = ${$periodo_ref}{Fecha}[3];
			my $dentroPeriodo = 0;
			if($regs[2] >= $anioDesde && $regs[2] <= $anioHasta){
				$dentroPeriodo = 1;
			}elsif($regs[2] == $anioDesde && $regs[2] == $anioHasta){
				if($regs[3] >= $mesDesde && $regs[3] <= $mesHasta){
					$dentroPeriodo = 1;
				}
			}			
			if($regs[0] eq $codigoPais && $dentroPeriodo){
				$result[$i] = $reg;
				$i++;	
			}
		}		
	}
	close(FILE);
	return @result;
}

sub filtrarPorPaisYSistema{
	my $codigoPais = shift(@_);
	my $codigoSistema = shift(@_);
	my $periodo_ref = shift(@_);
	my @result; #array de lineas coincidentes con filtros
	my $i = 0; #iterador
	
	open(FILE, $MAEDIR.$MAEPPI) or die print "Falla al abrir ".$MAEDIR.$MAEPPI;
	$ifs = ";";	

	while($reg=<FILE>){ 
		my @regs  = split($ifs, $reg);		
		chomp(@regs);
		if(${$periodo_ref}{SoloAnio}){
			my $anio = ${$periodo_ref}{Fecha}[0];
			if($regs[0] eq $codigoPais && $regs[1] eq $codigoSistema && $regs[2] == $anio){
				$result[$i] = $reg;
				$i++;	
			}		
		}elsif(${$periodo_ref}{AnioYMes}){
			my $anio = ${$periodo_ref}{Fecha}[0];
			my $mes = ${$periodo_ref}{Fecha}[1];
			if($regs[0] eq $codigoPais && $regs[1] eq $codigoSistema && $regs[2] == $anio && $regs[3] == $mes){
				$result[$i] = $reg;
				$i++;	
			}		
		}elsif(${$periodo_ref}{Periodo}){
			my $anioDesde = ${$periodo_ref}{Fecha}[0];
			my $mesDesde = ${$periodo_ref}{Fecha}[1];
			my $anioHasta = ${$periodo_ref}{Fecha}[2];
			my $mesHasta = ${$periodo_ref}{Fecha}[3];
			my $dentroPeriodo;		
			if($regs[2] >= $anioDesde && $regs[2] <= $anioHasta){
				$dentroPeriodo = 1;
			}elsif($regs[2] == $anioDesde && $regs[2] == $anioHasta){
				if($regs[3] >= $mesDesde && $regs[3] <= $mesHasta){
					$dentroPeriodo = 1;
				}
			}
			if($regs[0] eq $codigoPais && $regs[1] eq $codigoSistema && $dentroPeriodo){			
				$result[$i] = $reg;
				$i++;	
			}
		}		
	}
	close(FILE);
	return @result;
}

sub obtenerRegistrosMaestroAComparar{
	my $parametros_ref = shift(@_);
	my $codigoPais = ${$parametros_ref}{CodigoPais};
	my $codigoSistema = ${$parametros_ref}{CodigoSistema};
	my @regs;

	if($codigoPais){
		if($codigoSistema eq "TODOS"){
			@regs = filtrarPorPais($codigoPais, \%{${$parametros_ref}{Periodo}});			
		}elsif($codigoSistema){
			@regs = filtrarPorPaisYSistema($codigoPais, $codigoSistema, \%{${$parametros_ref}{Periodo}});					
		}
	}
	return @regs;
}

sub calcularMontoMaestro{
	my $registro = shift(@_);		
	
	my $ifs = ";";
	my @linea  = split($ifs, $registro);
		
	#CONVIERTO LOS NUMEROS SEPARADOS POR COMMA EN SEPARADOS POR PUNTO PARA Q ME LOS TOME COMO NUMEROS
	$linea[9] =~ s/,/./;
	$linea[10] =~ s/,/./;
	$linea[11] =~ s/,/./;
	$linea[12] =~ s/,/./;
	$linea[13] =~ s/,/./;

	return $linea[9] + $linea[10] + $linea[11] + $linea[12] - $linea[13];
}

sub comparadorFechas{
	my $fecha1 = shift(@_);
	my $fecha2 = shift(@_);
	
	@f1 = split("/", $fecha1);
	@f2 = split("/", $fecha2);
	
	if($f1[0] > $f2[0]){
		return 1;
	}elsif($f1[0] == $f2[0]){
		if($f1[1] > $f2[1]){
			return 1;
		}elsif($f1[1] == $f2[1]){
			if($f1[2] > $f2[2]){
				return 1;
			}
		}
	}
	return 0;
}

sub elegirRegistro{
	my $registros = shift(@_);
	my $i = 0;
	my $index = 0;
	my $diaMax = 0;
	my $fechaGrabacionMax = 0;
	my $ifs = ";";

	foreach $reg (@{$registros}){
		@linea_prestamos = split($ifs, $reg);
		if($linea_prestamos[3] > $diaMax){
			$diaMax = $linea_prestamos[3];
			$index = $i;		
		} elsif($linea_prestamos[3] == $diaMax) {
			if(comparadorFechas($linea_prestamos[14],$fechaGrabacionMax)){
				$fechaGrabacionMax = $linea_prestamos[14];
				$index = $i; 
			}	
		}
		$i++;
	}
	return ${$registros}[$index];
}

sub obtenerRegistrosComparables{
	my $registros = shift(@_);
	my @registrosParaComparar;

	my $codigoPais = getCodigo($pais,1);
	my $j = 0;
	foreach $reg_maestro (@{$registros}){
		if (-e $PROCDIR.$PRESPAIS.$codigoPais) {	
			open(FILE, $PROCDIR.$PRESPAIS.$codigoPais) or die "Falla al abrir ".$PROCDIR.$PRESPAIS.$codigoPais;
			my $ifs = ";";	
		
			my $i = 0;
			my @comparables;
			while($reg_pais=<FILE>){
				@linea_maestro = split($ifs, $reg_maestro);
				@linea_pais = split($ifs, $reg_pais);
				if($linea_maestro[7] eq $linea_pais[5] && $linea_maestro[2] == $linea_pais[1] && $linea_maestro[3] == $linea_pais[2]) {
					$comparables[$i] = $reg_pais;
					$i++;
				}	
			}
			if(scalar(@comparables) > 1){
				$registroAComparar = elegirRegistro(\@comparables);	
				$registrosParaComparar[$j]{Maestro} = $reg_maestro;
				$registrosParaComparar[$j]{Pais} = $registroAComparar;
				$j++;
			}elsif(scalar(@comparables) == 1){
				$registrosParaComparar[$j]{Maestro} = $reg_maestro;
				$registrosParaComparar[$j]{Pais} = $comparables[0];
				$j++;
			}
			close(FILE);		
		}else{
			print "Archivo inexistente";
			exit;
		}
	}
	return @registrosParaComparar;	
}

#CON ESTA FUNCION EVITO PROBLEMOS PARA COMPARAR FLOATS
sub esIgual{
	$montoMaestro = shift(@_);
	$montoPrestamos = shift(@_);
	if(abs($montoMaestro - $montoPrestamos) < 0.001){
		return 1;	
	}
	return 0;
}

sub obtenerValorRecomendacionEImprimirResultados{
	my $registros = shift(@_);
	my $parametros_ref = shift(@_);
	my $ifs = ";";

	#LIMPIO PANTALLA POR PROLIJIDAD	
	print $clear_string;

	my $id = $$;
	#GRABO RESULTADOS DE REPORTE EN ARCHIVO	
	if($grabar){
		#VALIDO QUE NO HAYA OTRO ARCHIVO CON EL MISMO NOMBRE GENERO UN ID UNICO		
		while(-e $REPODIR."ReporteX.".$pais.$id){
			$id++;
		}		
		open(FILE, '>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al crear ".$REPODIR."ReporteX.".$pais.$id;
		print FILE "RESULTADOS CONSULTA: A - COMPARACION PARA RECALCULO \n";
		print FILE "Parametros Ingresados:\n";
		print FILE "Pais: ".$pais."\n";
		print FILE "Sistema: ".$sistema."\n";
		
		if(${$parametros_ref}{Periodo}{SoloAnio}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		}elsif(${$parametros_ref}{Periodo}{Periodo}){
			print FILE "Periodo desde ";	
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
			print FILE " hasta ";
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
		}
		print FILE "\n\n";
		
		close(FILE);	
	}

	#IMPRIMO RESULTADOS POR PANTALLA
	print "RESULTADOS CONSULTA: A - COMPARACION PARA RECALCULO \n";
	print "Parametros Ingresados:\n";
	print "Pais: ".$pais."\n";
	print "Sistema: ".$sistema."\n";
	
	if(${$parametros_ref}{Periodo}{SoloAnio}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
	}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
	}elsif(${$parametros_ref}{Periodo}{Periodo}){
		print "Periodo desde ";	
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		print " hasta ";
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
	}
	print "\n\n";

	$i = 0;
	$j = 0;
	my @registros_recalculo;
	foreach $reg (@{$registros}){
		@linea_maestro = split ($ifs, ${$reg}{Maestro});
		@linea_pais = split ($ifs, ${$reg}{Pais});
		my $recomendacion = "BUENO";
		
		$montoMaestro = calcularMontoMaestro(${$reg}{Maestro});
		$linea_pais[11] =~ s/,/./;
		chomp($linea_maestro[13]);

		if(recalculoPorSmor($linea_maestro[5], $linea_pais[4])||($montoMaestro < $linea_pais[11] && !esIgual($montoMaestro,$linea_pais[11]))){	
			$recomendacion = "RECALCULO";
			$registros_recalculo[$j] = $linea_maestro[1].";".$linea_maestro[2].";".$linea_maestro[3].";".$linea_pais[3].";".$linea_maestro[5].";".$linea_maestro[7].";".$linea_maestro[9].";".$linea_maestro[10].";".$linea_maestro[11].";".$linea_maestro[12].";".$linea_maestro[13].";".$montoMaestro.";".$linea_pais[12].";".$linea_pais[13].";".$linea_pais[14].";".$linea_pais[15];
			$j++;
		}
				
		if($grabar){
			open(FILE, '>>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al abrir ".$REPODIR."ReporteX.".$pais.$id;
			print FILE "Codigo del Prestamo: ".$linea_pais[5]."\n";
			print FILE "Codigo del Cliente: ".$linea_pais[12]."\n";
			print FILE "Estado contable del maestro: ".$linea_maestro[5]."\n";
			print FILE "Estado contable del pestamos.".$pais.": ".$linea_pais[4]."\n";
			print FILE "Monto restante del maestro: ".$montoMaestro."\n";
			print FILE "Monto restante del pestamos.".$pais.": ".$linea_pais[11]."\n";
			print FILE "Recomendacion: ".$recomendacion."\n";
			print FILE "\n"; 
			close(FILE);		
		}	

		print "Codigo del Prestamo: ".$linea_pais[5]."\n";
		print "Codigo del Cliente: ".$linea_pais[12]."\n";
		print "Estado contable del maestro: ".$linea_maestro[5]."\n";
		print "Estado contable del pestamos.".$pais.": ".$linea_pais[4]."\n";
		print "Monto restante del maestro: ".$montoMaestro."\n";
		print "Monto restante del pestamos.".$pais.": ".$linea_pais[11]."\n";
		print "Recomendacion: ".$recomendacion."\n";
		$i++;
		print "\n"; 
	}
	print "CANTIDAD DE REGISTROS LISTADOS: ".$i."\n";
	
	return @registros_recalculo;
}

sub imprimirResultadosComparacionPorcentaje{
	my $registros = shift(@_);
	my $parametros_ref = shift(@_);
	my $ifs = ";";

	#LIMPIO PANTALLA POR PROLIJIDAD		
	print $clear_string;
	
	my $id = $$;	
	#GRABO RESULTADOS DE REPORTE EN ARCHIVO
	if($grabar){
		
		#VALIDO QUE NO HAYA OTRO ARCHIVO CON EL MISMO NOMBRE GENERO UN ID UNICO		
		while(-e $REPODIR."ReporteX.".$pais.$id){
			$id++;
		}
		
		open(FILE, '>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al crear ".$REPODIR."ReporteX.".$pais.$id;
		print FILE "RESULTADOS CONSULTA: B - DIFERENCIA EN VALOR ABSOLUTO MAYOR AL ".$porcentaje."%\n";
		print FILE "Parametros Ingresados:\n";
		print FILE "Pais: ".$pais."\n";
		print FILE "Sistema: ".$sistema."\n";
	
		if(${$parametros_ref}{Periodo}{SoloAnio}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		}elsif(${$parametros_ref}{Periodo}{Periodo}){
			print FILE "Periodo desde ";	
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
			print FILE " hasta ";
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
		}
		print FILE "\n\n";
		close(FILE);	
	}	
	print "RESULTADOS CONSULTA: B - DIFERENCIA EN VALOR ABSOLUTO MAYOR AL ".$porcentaje."%\n";
	print "Parametros Ingresados:\n";
	print "Pais: ".$pais."\n";
	print "Sistema: ".$sistema."\n";
	
	if(${$parametros_ref}{Periodo}{SoloAnio}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
	}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
	}elsif(${$parametros_ref}{Periodo}{Periodo}){
		print "Periodo desde ";	
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		print " hasta ";
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
	}
	print "\n\n";
	
	my $first = 1; 		
	foreach $reg (@{$registros}){
		@linea_maestro = split ($ifs, ${$reg}{Maestro});
		@linea_pais = split ($ifs, ${$reg}{Pais});

		$montoMaestro = calcularMontoMaestro(${$reg}{Maestro});
		$linea_pais[11] =~ s/,/./;		
	
		my $porcentajeCalculado = calcularPorcentaje($montoMaestro, $linea_pais[11]);
		if($porcentajeCalculado > $porcentaje){
			if($first){
				print "Prestamo\t\tMaestro\t\tPais\t\tDiferencia\n";
				if($grabar){
					open(FILE, '>>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al abrir ".$REPODIR."ReporteX.".$pais.$id;
					print FILE "Prestamo\t\tMaestro\t\tPais\t\tDiferencia\n";
					close(FILE);				
				}
				$first = 0;			
			}
			if($grabar){
				open(FILE, '>>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al abrir ".$REPODIR."ReporteX.".$pais.$id;
				print FILE $linea_maestro[7]."\t\t".$montoMaestro."\t\t".$linea_pais[11]."\t\t".$porcentajeCalculado."%"."\n";
				close(FILE);			
			}				
			print $linea_maestro[7]."\t\t".$montoMaestro."\t\t".$linea_pais[11]."\t\t".$porcentajeCalculado."%"."\n";
		}		
	}
	print "\n";
	if($first == 1){
		print "NO HAY NINGUN REGISTRO PARA LISTAR.\n";
	}
}

sub imprimirResultadosComparacionMonto{
	my $registros = shift(@_);
	my $parametros_ref = shift(@_);
	my $ifs = ";";

	#LIMPIO PANTALLA POR PROLIJIDAD		
	print $clear_string;
	
	my $id = $$;
	if($grabar){
		#VALIDO QUE NO HAYA OTRO ARCHIVO CON EL MISMO NOMBRE GENERO UN ID UNICO		
		while(-e $REPODIR."ReporteX.".$pais.$id){
			$id++;
		}

		open(FILE, '>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al crear ".$REPODIR."ReporteX.".$pais.$id;
		print FILE "RESULTADOS CONSULTA: B - DIFERENCIA EN VALOR ABSOLUTO MAYOR A \$".$monto."\n";
		print FILE "Parametros Ingresados:\n";
		print FILE "Pais: ".$pais."\n";
		print FILE "Sistema: ".$sistema."\n";
	
		if(${$parametros_ref}{Periodo}{SoloAnio}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		}elsif(${$parametros_ref}{Periodo}{Periodo}){
			print FILE "Periodo desde ";	
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
			print FILE " hasta ";
			print FILE "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
			print FILE " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
		}
		print FILE "\n\n";
		close(FILE);	
	}	
	print "RESULTADOS CONSULTA: B - DIFERENCIA EN VALOR ABSOLUTO MAYOR A \$".$monto."\n";
	print "Parametros Ingresados:\n";
	print "Pais: ".$pais."\n";
	print "Sistema: ".$sistema."\n";
	
	if(${$parametros_ref}{Periodo}{SoloAnio}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
	}elsif(${$parametros_ref}{Periodo}{AnioYMes}){
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
	}elsif(${$parametros_ref}{Periodo}{Periodo}){
		print "Periodo desde ";	
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[0];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[1];
		print " hasta ";
		print "Año: ".${$parametros_ref}{Periodo}{Fecha}[2];
		print " Mes: ".${$parametros_ref}{Periodo}{Fecha}[3];
	}
	print "\n\n";
	
	my $first = 1;
	foreach $reg (@{$registros}){
		@linea_maestro = split ($ifs, ${$reg}{Maestro});
		@linea_pais = split ($ifs, ${$reg}{Pais});

		$montoMaestro = calcularMontoMaestro(${$reg}{Maestro});
		$linea_pais[11] =~ s/,/./;		
	
		my $diferencia = calcularDiferencia($montoMaestro, $linea_pais[11]);
		if($diferencia > $monto){
			if($first){
				print "Prestamo\t\tMaestro\t\tPais\t\tDiferencia\n";
				if($grabar){
					open(FILE, '>>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al abrir ".$REPODIR."ReporteX.".$pais.$id;
					print FILE "Prestamo\t\tMaestro\t\tPais\t\tDiferencia\n";
					close(FILE);				
				}
				$first = 0;			
			}
			if($grabar){
				open(FILE, '>>'.$REPODIR."ReporteX.".$pais.$id) or die "Falla al abrir ".$REPODIR."ReporteX.".$pais.$id;
				print FILE $linea_maestro[7]."\t\t".$montoMaestro."\t\t".$linea_pais[11]."\t\t"."\$".$diferencia."\n";				
				close(FILE);			
			}				
			print $linea_maestro[7]."\t\t".$montoMaestro."\t\t".$linea_pais[11]."\t\t"."\$".$diferencia."\n";
		}		
	}
	print "\n";
	if($first == 1){
		print "NO HAY NINGUN REGISTRO PARA LISTAR.\n";
	}
}


sub realizarOtraConsulta(){
	print "¿Desea realizar otra consulta? Y/N\n";
	
	$entrada = <STDIN>;
	chomp($entrada);	
	print "\n"; 
	
	#Loop infinito hasta que se ingrese opcion valida
	while(!($entrada =~ m/[Y N y n]/i)){
		print "Opcion incorrecta. Intente nuevamente\n";
		$entrada = <STDIN>;
		chomp($entrada);		
	}
	if($entrada eq "Y" || $entrada eq "y"){
		print $clear_string;
		inicio();
	}
}

sub calcularPorcentaje{
	my $montoMaestro = shift(@_);
	my $montoPais = shift(@_);
	my $porcentajeCalculado;
	
	$montoMaestro = sprintf("%.2f",$montoMaestro);
	$montoPais = sprintf("%.2f",$montoPais);
	
	$diferencia = $montoMaestro - $montoPais;
	if($montoMaestro > 0){
		$porcentajeCalculado = $diferencia / $montoMaestro * 100;		
		if($porcentajeCalculado < 0){
			$porcentajeCalculado = $porcentajeCalculado*-1;
		}
		$porcentajeCalculado = sprintf("%.2f",$porcentajeCalculado);
		return $porcentajeCalculado;	
	}	
	return 0;
}

sub calcularDiferencia{
	my $montoMaestro = shift(@_);
	my $montoPais = shift(@_);
	my $diferencia;
	
	$montoMaestro = sprintf("%.2f",$montoMaestro);
	$montoPais = sprintf("%.2f",$montoPais);
	
	$diferencia = $montoMaestro - $montoPais;
	if($diferencia < 0){
		$diferencia = $diferencia*-1;
	}
	$diferencia = sprintf("%.2f",$diferencia);
	return $diferencia;
}

sub deseaGrabarArchivo{
	print "\n¿Desea grabar archivo de recalculo? Y/N\n";
	
	$entrada = <STDIN>;
	chomp($entrada);	
	print "\n"; 
	
	#Loop infinito hasta que se ingrese opcion valida
	while(!($entrada =~ m/[Y N y n]/i)){
		print "Opcion incorrecta. Intente nuevamente\n";
		$entrada = <STDIN>;
		chomp($entrada);		
	}
	if($entrada eq "Y" || $entrada eq "y"){
		return 1;
	}else{
		return 0;
	}
}

sub grabarArchivo{
	$registros_recalculo = shift(@_);
	
	my $codigoPais = getCodigo($pais,1);
	if (!-e $REPODIR.$RECALCULO.$codigoPais) {	
		open(FILE,'>'.$REPODIR.$RECALCULO.$codigoPais) or die "Falla al crear ".$REPODIR.$RECALCULO.$codigoPais;
		close(FILE);
	}
	
	if (-e $REPODIR.$RECALCULO.$codigoPais) {	
		open(FILE,'>>'.$REPODIR.$RECALCULO.$codigoPais) or die "Falla al abrir ".$REPODIR.$RECALCULO.$codigoPais;
		foreach $linea (@{$registros_recalculo}){
			print FILE $linea;		
		}		
		close(FILE);
	}
}

sub procesarConsulta{
	my $entrada = shift(@_);
	my %parametros;
	my $montoMaestro;
	my @registros_maestro;
	my @registros;
	
	if ($entrada eq "a"){
		%parametros = ingresarParametrosA();
		@registros_maestro = obtenerRegistrosMaestroAComparar(\%parametros);
		@registros = obtenerRegistrosComparables(\@registros_maestro);
		@registros_recalculo = obtenerValorRecomendacionEImprimirResultados(\@registros, \%parametros);
		
		if(deseaGrabarArchivo()){	
			grabarArchivo(\@registros_recalculo);
		}
		realizarOtraConsulta();
	}
	elsif ($entrada eq "b"){
		%parametros = ingresarParametrosB();
		@registros_maestro = obtenerRegistrosMaestroAComparar(\%parametros);
		@registros = obtenerRegistrosComparables(\@registros_maestro);
		imprimirResultadosComparacionPorcentaje(\@registros, \%parametros);
		realizarOtraConsulta();
	}
	elsif ($entrada eq "c"){
		%parametros = ingresarParametrosC();
		@registros_maestro = obtenerRegistrosMaestroAComparar(\%parametros);
		@registros = obtenerRegistrosComparables(\@registros_maestro);
		imprimirResultadosComparacionMonto(\@registros, \%parametros);
		realizarOtraConsulta();
	}
	elsif ($entrada eq "z" ) {
		return;
	}
	
}

sub inicio{
	my $opcion = menuPrincipal();
	procesarConsulta($opcion);
}

#CONSTANTES
$MAEPPI = "PPI.mae";
$MAEPS = "p-s.mae";
$PRESPAIS = "prestamos.";
$RECALCULO = "recalculo.";

#TOMO LAS RUTA DEL CONFIG
sub inicializarRutas{
	if (-e "../conf/InstalX.conf") {	
		open(FILE, "../conf/InstalX.conf") or die print "Error al abrir InstalX.conf";
		while($reg=<FILE>){
			my @regs = split("=", $reg);
			chomp(@regs);
			if($regs[0] eq "MAEDIR"){
				$MAEDIR = "../".$regs[1]."/";
			}elsif($regs[0] eq "PROCDIR"){
				$PROCDIR = "../".$regs[1]."/";
			}elsif($regs[0] eq "REPODIR"){
				$REPODIR = "../".$regs[1]."/";
			}
		}
		close(FILE);
	}else{
		print "Archivo de configuracion inexistente.\n"
	}
}

#sub verificarAmbienteInicializado{
#	$PROCDIR = "$ENV{'PROCDIR'}";
#	$MAEDIR = "$ENV{'PROCDIR'}";
#	$REPODIR = "$ENV{'PROCDIR'}";
#	if(!defined $PROCDIR || !defined $MAEDIR || !defined $REPODIR){
#		print "Ambiente no inicializado";
#		exit;
#	}
#}

#almacena el PID de este proceso
sub guardarPID{
	if (-e 'PidFile') {	
		open(FILE,'>>'.'PidFile') or die "Falla al abrir PidFile";
		print FILE $$."\n";		
		close(FILE);
	}else{
		print "Archivo de PID inexistente";
	}
}

sub recuperarPID{
	if (!-e 'PidFile') {	
		open(FILE,'>'.'PidFile') or die "Falla al crear PidFile";
		close(FILE);
		return 0;
	}
	if(-z 'PidFile'){
		return 0;
	}	
	if (-e 'PidFile') {
		open(FILE,'PidFile') or die "Falla al abrir PidFile";
		my @lines = <FILE>;
		close(FILE);
		@lines = reverse(@lines);
		return $lines[0];
	}
}

sub estaCorriendo{
	$pid = recuperarPID();
	if($pid){
		$exists = kill 0, $pid;
		if($exists){
			return 1;
		}else{
			return 0;
		}
	}else{
		return 0;
	}
}

use Getopt::Std;
$clear_string = `clear`;

#VERIFICAR SI EL PROCESO DE REPORTE ESTA CORRIENDO
if(estaCorriendo()){
	#SI TIENE EL MISMO PID ENTONCES CIERRO EL PROCESO
	print "ReporteX.pl ya esta corriendo.\n";	
	exit;
}else{
	guardarPID();
}



#INICIALIZO LAS RUTAS DESDE EL CONFIG
inicializarRutas();

#VERIFICAR QUE EL AMBIENTE ESTE INICIALIZADO
#verificarAmbienteInicializado();

#VARIABLE GLOBAL PARA GRABAR REPOTE
$grabar = 0;

# Declaracion de las opciontes del comando perl que se permiten.
my %opt=();
getopts("ag", \%opt);

mostrarAyuda() if defined $opt{a};
if($opt{g}) {
	$grabar = 1;
}
inicio();

