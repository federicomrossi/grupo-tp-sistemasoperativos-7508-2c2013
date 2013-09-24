package functions;

use strict;
use Exporter;
use Switch 'Perl5', 'Perl6';
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(LoguearU MirarU);
%EXPORT_TAGS = ( DEFAULT => [qw(&LoguearU &MirarU)],
                 All     => [qw(&LoguearU &MirarU)]);

# Tabla de mensajes de error (y codigos)
my %log_messages=(1          => "Arhivo inexistente",
                  2          => "Permiso Denegado",
                  3          => "No se pudo leer el archivo",
                  "no_found" => "Tipo de mensaje no encontrado",
                 );

my $root_dir = 'grupo10';

#    @command: 
#    @msg_type: 
#    @msg_number: 
#    @msg_text: 
#    @log_file: 
sub LoguearU
{
    my $message = '';
    my $log_size = 0;
    my $log_size_max = 0;
    my $log_line = '';
    my $log_dir = '';
    my $log_file_name = '';
    my $log_file_ext = '';
    my $log_full_file_path = '';

    my @passed_params = @_;
    if (! ($passed_params[0])) {
        # Sin argumentos
        return 1;
    }
    else {
        $log_size_max = get_config_value('LOGSIZE');

        if ($passed_params[4]) {
            $log_full_file_path = $passed_params[4];
        }
        else {
            # Leo configuracion
            $log_dir = get_config_value('LOGDIR');
            $log_file_ext = get_config_value('LOGEXT');

            # Chequeo existencia de archivo (y directorios)
            ensure_path($log_dir);

            # Genero el nombre del archivo de log
            $log_full_file_path = $log_dir . $passed_params[0]
                                  . $log_file_ext;
        }
        given ($passed_params[2]) {
            when(0) {
                $message = $passed_params[4] . "\n";
            }
            when(1) {
                $message = $log_messages{1} . "\n";
            }
            when(2) {
                $message = $log_messages{2} . "\n";
            }
            when(3) {
                $message = $log_messages{3} . "\n";
            }
            default {
                $message = $log_messages{no_found} . "\n";
            }
        };
    }

    $log_line = get_date()
                . " - " .getlogin()
                . " - " . $passed_params[0]
                . " - " . $passed_params[1]
                . " - (" . $passed_params[2]
                . ") " . $message;

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

sub MirarU
{
    #use Getopt::Std;

    #my $opt_tring = 'hf:';
    #getopts();
}

sub MoverU
{
    use File::Copy;
    my $error = 0;
    my $dir_orig = '';
    my $dir_dest = '';
    my $file_orig = '';
    my $file_dest = '';

    my @passed_params = @_;
    #print "count: " . @passed_params . "\n";

    # Chequeo la cantidad de parametros. Como el origen y el destino
    # son obligatorios, como minimo tengo que tener 2 parametros.
    if (@passed_params < 2) {
        return 1;
    }
    else {
        $dir_orig = get_file_path($passed_params[0]);
        $file_orig = get_file_name($passed_params[0]);
        $dir_dest = get_file_path($passed_params[1]);
        $file_dest = get_file_name($passed_params[1]);

        #print "dir_orig: $dir_orig\n";
        #print "file_orig: $file_orig\n";
        #print "dir_dest: $dir_dest\n";
        #print "file_dest: $file_dest\n";

        move($passed_params[0], $passed_params[1]);
    }

    return 0;
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

sub get_config_value
{
    my $root_path = get_root_path();
    my $line = '';
    my $value = '';

    # Leer archivo de configuracion "confdir/Instalar.U.conf"
    # Trato de abrir el archivo de configuracion.
    #
    open(CONFIG_FILE,"<$root_path/confdir/InstalarU.conf") || return 1;

    while ($line = <CONFIG_FILE>) {
        if ($line =~ m/$_[0]/) {
            $line =~ m/^$_[0]=(.*)=.*=.*/;
            $value = $1;
        }
    }
    close(CONFIG_FILE);

    return $value;
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
    print FILE_LOG get_date() . " - Log Excedido\n";

    close(FILE_LOG_TMP);
    close(FILE_LOG);

    # Finalmente, borro el archivo temporal.
    unlink("$_[0].tmp");

    return 0;
}

sub get_root_path
{
    my $curr_pwd = '';
    my $root_path = '';

    use Cwd qw( abs_path );
    use File::Basename qw( dirname );
    $curr_pwd = dirname(abs_path($0));

    $curr_pwd =~ m/(.*$root_dir)/;
    $root_path = $1;

    return $root_path;
}

sub get_file_path
{
    use File::Basename;
    my ($name, $path) = fileparse($_[0]);
    return $path;
}

sub get_file_name
{
    use File::Basename;
    my ($name) = fileparse($_[0]);
    return $name;
}

1;
