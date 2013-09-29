package functions;

use strict;
use Exporter;
use Switch 'Perl5', 'Perl6';

use constant ROOT_DIR => 'grupo10';
use constant LOG_SIZE => 102400; # 100 KB
use constant LOG_DIR => 'logdir/';
use constant LOG_EXT => '.log';


#    @command: command to log
#    @msg_type: type of message (I,W,E,SE)
#    @msg: 
#    @log_file:
sub Grabar_L 
{
	my $message = '';
	my $log_full_file_path= '';
    my $log_size = 0;
    my $log_size_max = 0;
    my $log_line = '';	
    my @params = @_;
    my $log_dir = '';
    my $log_file_name = '';
    my $log_file_ext = '';
    my $log_full_file_path = '';

	if(!($params[0])){
		return 1;
	}

	$log_size_max = get_log_max_size();
	if ( $params[3]){
		# El log se escribe en un archivo distinto al por defecto
		$log_full_file_path = $params[3];
        print $log_full_file_path;
	} else {
            $log_dir = get_log_dir();
            $log_file_ext = get_log_extension();

            # Chequeo existencia de archivo (y directorios)
            ensure_path($log_dir);

            # Genero el nombre del archivo de log
            $log_full_file_path = $log_dir . $params[0]
                                  . $log_file_ext;
    }


    $log_line = get_date()
                . " - " . get_username()
                . " - " . $params[0]
                . " - " . $params[1]
                . " - (" . $params[2]
                . ") " . $message . "\n";

    open (LOG_FILE, ">>$log_full_file_path");
    print LOG_FILE $log_line;
    close(LOG_FILE);

    # Chequeo que el log no supere el tamaño maximo.
    $log_size = -s $log_full_file_path;

    if ($log_size > $log_size_max) {
        # Trunco el archivo de log a la mitad.
        truncate_file($log_full_file_path);
    }

    return 0;
}

sub get_log_max_size
{
    my $size = 0;
    $size = get_config_value('LOGSIZE');

    if ( ! $size ) {
        # Seteo el default
        $size = LOG_SIZE;
    }

    return $size;
}

sub get_config_value
{
    my $root_path = get_root_path();
    my $line = '';
    my $value = '';

    # Leer archivo de configuracion "confdir/Instalar.U.conf"
    # Trato de abrir el archivo de configuracion.
    #
    if ( open(CONFIG_FILE,"<$root_path/confdir/Instalar_TP.conf") ) {
        while ($line = <CONFIG_FILE>) {
            if ($line =~ m/$_[0]/) {
                $line =~ m/^$_[0]=(.*)=.*=.*/;
                $value = $1;
            }
        }
        close(CONFIG_FILE);
    }

    return $value;
}

sub get_root_path
{
    my $root_dir = ROOT_DIR;
    my $curr_pwd = '';
    my $root_path = '';

    use Cwd qw( abs_path );
    use File::Basename qw( dirname );
    $curr_pwd = dirname(abs_path($0));

    $curr_pwd =~ m/(.*$root_dir)/;
    $root_path = $1;
    $root_path = $root_path . "/";

    return $root_path;
}

# Crea el path del archivo de log si no existe.
sub ensure_path
{
    use File::Path;

    eval { mkpath($_[0]) };
    if ($@) {
        return $@;
    } else {
        return 0;
    }
}

sub get_log_dir
{
    my $log_dir = '';
    $log_dir = get_config_value('LOGDIR');

    if ( ! $log_dir ) {
        # Seteo el default
        $log_dir = LOG_DIR;
    }
    else {
        $log_dir =~ m/(\/)$/;
        my $slash = $1;
        if ( ! $slash) {
            $log_dir .= "/";
        }
    }

    return $log_dir;
}

sub get_log_extension
{
    my $log_file_ext = '';
    $log_file_ext = get_config_value('LOGEXT');

    if ( ! $log_file_ext ) {
        # Seteo el default
        $log_file_ext = LOG_EXT;
    }
    else {
        if ( index($log_file_ext, ".") != 0 ) {
            # La extension no tiene un punto al comienzo; lo agrego.
            $log_file_ext = "." . $log_file_ext;
        }
    }

    return $log_file_ext;
}

sub get_username
{
    my $username = `whoami`;
    chomp($username);
    return $username;
}

sub get_date
{
    my $date='';
    my $sec = 0;
    my $min = 0;
    my $hour = 0;
    my $day = 0;
    my $mon = 0;
    my $year = 0;

    ($sec,$min,$hour,$day,$mon,$year) = localtime;
    $year += 1900;
    $mon = sprintf '%02d', $mon + 1;
    $day = sprintf '%02d', $day;
    $hour = sprintf '%02d', $hour;
    $min = sprintf '%02d', $min;
    $sec = sprintf '%02d', $sec;
    $date = "$year-$mon-$day $hour:$min:$sec";

    return $date;
}

sub truncate_file
{
    use POSIX;
    use File::Copy;

    my $line = '';
    my $new_line_num = 0;
    my $line_num = 0;
    my $no_lof_line = 0;

    # Copio el log en un archivo temporal
    copy("$_[0]", "$_[0].tmp") or die "Copy failed: $!";

    # Elimino el contenido del archivo de log (lo abro para escritura).
    open (FILE_LOG, ">$_[0]");
    open (FILE_LOG_TMP, "<$_[0].tmp");

    # Obtengo el numero de lineas del archivo.
    $no_lof_line = `wc -l <$_[0].tmp`;
    # La nueva cantidad de lineas, sera la mitad.
    $new_line_num = floor($no_lof_line / 2);

    while ($line = <FILE_LOG_TMP>) {
        $line_num++;
        if ($line_num > $new_line_num) {
            print FILE_LOG $line;
        }
    }

    # Finalente, copio que el log fue truncado en el log.
    print FILE_LOG get_date() . " - " . get_username()
          . " - LoguearU - I - Log Excedido\n";

    close(FILE_LOG_TMP);
    close(FILE_LOG);

    # Finalmente, borro el archivo temporal.
    unlink("$_[0].tmp");

    return 0;
}

1;