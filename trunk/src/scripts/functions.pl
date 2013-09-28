package functions;


use constant ROOT_DIR => 'grupo10';


#    @command: command to log
#    @msg_type: type of message (I,W,E,SE)
#    @msg: 
#    @msg_number: 
#    @log_file:
sub Grabar_L 
{
	my $message = '';
	my @params = @_;

	if(!($params[0])){
		return 0;
	}
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
    if ( open(CONFIG_FILE,"<$root_path/confdir/InstalarU.conf") ) {
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