#!/bin/bash
#Script de Instalacion del TP-Grupo 9 Sistemas Operativos - FIUBA
#
#Autor: Alex Werffeli

#Variables iniciales
CONFDIR="conf"   #siempre debe estar en conf
BINDIR=""
MAEDIR=""
ARRIDIR=""
RECHDIR=""
ACEPDIR=""
PROCDIR=""
REPODIR=""
LOGDIR=""
LOGEXT=""
LOGSIZE=""
DATASIZE=""


#funcion para logear
function log {
    msg=$1
    type=$2
    if [ "$type" = "" ]
    then
        type="I"
    fi
    script="InstalX"
    instalables/bin/GlogX.sh -c "$script" -t "$type" -m "$msg"
}

function fileExist {
	declare -a arch=$1
	if [ ! -e "${arch}" ]; then
		return 0
	fi
	return 1
}

function filesExist {
	declare -a directorio=$1
	declare -a archivos=("${!2}")
	for file in "${archivos[@]}"
	do
		fileExist "${directorio}/${file}"
		result=$?
		if [ $result -eq 0 ]; then
            echo "El archivo ${arch} no existe"
			return 0
		fi
	done
	return 1
}

function checkInstalablesIntegrity {
    INSTALDIR=instalables
    INSTALBINDIR=bin
    INSTALCONFDIR=conf
    INSTALMAEDIR=mae
    # Verifico si esta el directorio de instalables
    if [ ! -d $INSTALDIR ]; then
        echo "No existe el directorio $INSTALDIR con los archivos necesarios para instalar ControlX"
        log "No existe el directorio $INSTALDIR con los archivos necesarios para instalar ControlX" "SE"
        return 1
    fi
    # Verifico si esta el directorio bin
    if [ ! -d "$INSTALDIR/${INSTALBINDIR}" ]; then
        echo "No existe el directorio $INSTALDIR/$INSTALBINDIR con los archivos necesarios para instalar ControlX"
        log "No existe el directorio $INSTALDIR/$INSTALBINDIR con los archivos necesarios para instalar ControlX" "SE"
        return 1
    fi
    # Verifico si esta el directorio conf
    if [ ! -d "$INSTALDIR/$INSTALCONFDIR" ]; then
        echo "No existe el directorio $INSTALDIR/$INSTALCONFDIR con los archivos necesarios para instalar ControlX"
        log "No existe el directorio $INSTALDIR/$INSTALCONFDIR con los archivos necesarios para instalar ControlX" "SE"
        return 1
    fi
    # Verifico si esta el directorio mae
    if [ ! -d "$INSTALDIR/$INSTALMAEDIR" ]; then
        echo "No existe el directorio $INSTALDIR/$INSTALMAEDIR con los archivos necesarios para instalar ControlX"
        log "No existe el directorio $INSTALDIR/$INSTALMAEDIR con los archivos necesarios para instalar ControlX" "SE"
        return 1
    fi
    ## COMANDOS
    local GETPID="getPID.sh" 
    local INICIOX="InicioX.sh"
    local DETECTAX="DetectaX.sh"
    local INTERPRETE="Interprete.sh"
    local REPORTEX="ReporteX.pl" 
    local MOVERX="MoverX.sh" 
    local GLOGX="GlogX.sh"
    local VLOGX="VlogX.sh"
    local STARTX="StartX.sh"
    local STOPX="StopX.sh"
    ## ARCHIVOS DE CONFIGURACION
    local T1="T1.tab"
    local T2="T2.tab"
    ## ARCHIVOS MAESTROS
    local PSMAE="p-s.mae"
    local PPIMAE="PPI.mae"

    local result

    local comandos=($GETPID $INICIOX $DETECTAX $INTERPRETE $REPORTEX $MOVERX $GLOGX $VLOGX $STARTX $STOPX)
    local maestros=($PSMAE $PPIMAE)
    local config=($INSTALX $T1 $T2)

    filesExist "${INSTALDIR}/${INSTALBINDIR}" comandos[@]
    result=$?
    if [ $result -eq 0 ]; then
        echo "Faltan archivos en el directorio ${INSTALDIR}/${INSTALBINDIR}. No se puede instalar ControlX"
        log "Faltan archivos en el directorio ${INSTALDIR}/${INSTALBINDIR}. No se puede instalar ControlX" "SE"
        return 1
    fi

    filesExist "${INSTALDIR}/${INSTALMAEDIR}" maestros[@]
    result=$?
    if [ $result -eq 0 ]; then
        echo "Faltan archivos en el directorio ${INSTALDIR}/${INSTALMAEDIR}. No se puede instalar ControlX"
        log "Faltan archivos en el directorio ${INSTALDIR}/${INSTALMAEDIR}. No se puede instalar ControlX" "SE"
        return 1
    fi

    filesExist "${INSTALDIR}/${INSTALCONFDIR}" config[@]
    result=$?
    if [ $result -eq 0 ]; then
        echo "Faltan archivos en el directorio ${INSTALDIR}/${INSTALCONFDIR}. No se puede instalar ControlX"
        log "Faltan archivos en el directorio ${INSTALDIR}/${INSTALCONFDIR}. No se puede instalar ControlX" "SE"
        return 1
    fi

    return 0
}

#retorna uno si el valor contiene nomas letras y numeros o es vacio
function isValidDirectoryName {
    dir_value=$1
    
    if [ "$dir_value" == "" ]
    then
        return 1
    fi
    if [[ $dir_value =~ ^-?[0-9a-zA-Z]+$ ]]
    then
        return 1
    fi
    return 0
}

#una funcion para preguntar al usario y lo forca a escribir si o no
#en addicion todo es logeado
function promtComplete {
    COMPLETAR="null"
    echo $1
    log "$1"
    while [[ $COMPLETAR != "Si" ]] && [[ $COMPLETAR != "No" ]]
    do
        read -e COMPLETAR
        log "El usario ingresó: $COMPLETAR" "I"
        if [[ $COMPLETAR == "Si" ]]
            then
                return 1
            else 
                if [[ $COMPLETAR == "No" ]]
                then
                    return 0
                fi
        fi
        echo "Por Favor escribe Si o No (case sensitive)"
        log "Por Favor escribe Si o No (case sensitive)" "I"
    done
}

function createAllDirs {
    #crear directorias en el caso que no existen
    mkdir -p $INSTALL_PATH$ARRIDIR
    log "Creando $INSTALL_PATH$ARRIDIR" "I"
    mkdir -p $INSTALL_PATH$RECHDIR
    log "Creando $INSTALL_PATH$RECHDIR" "I"
    mkdir -p $INSTALL_PATH$ACEPDIR
    log "Creando $INSTALL_PATH$ACEPDIR" "I"
    mkdir -p $INSTALL_PATH$PROCDIR
    log "Creando $INSTALL_PATH$PROCDIR" "I"
    mkdir -p $INSTALL_PATH$LOGDIR
    log "Creando $INSTALL_PATH$LOGDIR" "I"
    mkdir -p $INSTALL_PATH$REPODIR
    log "Creando $INSTALL_PATH$REPODIR" "I"
}

function isPerlInstalled {
if perl < /dev/null > /dev/null 2>&1  ; then
       return 1
    else
       return 0
   fi
}

function getPerlVersion {
    PERL_VERSION=`perl -v | grep '(v[0-9].*.*)' | sed 's/This is perl //'`
    if [ -z "${PERL_VERSION}" ]; then
        PERL_VERSION=`perl -v | grep 'v[0-9].*.*' | sed 's/This is perl, v//'`
    fi
    #echo "VERSION PERL: ${PERL_VERSION:0:1}"
    return ${PERL_VERSION:0:1}
}

function printInstallationInfo {
    echo ""
    echo "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 9"
    echo "Libreria del Sistema: $CONFDIR"
    echo "Ejecutables: $BINDIR"
    echo "Archivos maestros: $MAEDIR"
    echo "Directorio de arribo de archivos externos: $ARRIDIR"
    echo "Espacio mínimo libre para arribos: $DATASIZE MB"
    echo "Archivos externos aceptados: $ACEPDIR"
    echo "Archivos externos rechazados: $RECHDIR"
    echo "Archivos procesados: $PROCDIR"
    echo "Reportes de salida: $REPODIR"
    echo "Logs de auditoria del Sistema: $LOGDIR/<comando>$LOGEXT"
    echo "Tamaño máximo para los archivos de log del sistema: $LOGSIZE KB"

    log "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 9" "I"
    log "Libreria del Sistema: $CONFDIR" "I"
    log "Ejecutables: $BINDIR" "I"
    log "Archivos maestros: $MAEDIR" "I"
    log "Directorio de arribo de archivos externos: $ARRIDIR" "I"
    log "Espacio mínimo libre para arribos: $DATASIZE MB" "I"
    log "Archivos externos aceptados: $ACEPDIR" "I"
    log "Archivos externos rechazados: $RECHDIR" "I"
    log "Archivos procesados: $PROCDIR" "I"
    log "Reportes de salida: $REPODIR" "I"
    log "Logs de auditoria del Sistema: $LOGDIR/<comando>$LOGEXT" "I"
    log "Tamaño máximo para los archivos de log del sistema: $LOGSIZE KB" "I"
}

function readConfigValues {
if [ -f $CONFIG_PATH ];
then
    #INSTALL_PATH=`grep 'GRUPO=*' $CONFIG_PATH | sed 's/GRUPO=//1 '`
    #CONFDIR=`grep 'CONFDIR=*' $CONFIG_PATH | sed 's/CONFDIR=//1 '`
    CONFDIR="conf"   #siempre debe estar en conf
    BINDIR=`grep 'BINDIR=*' $CONFIG_PATH | sed 's/BINDIR=//1'`
    MAEDIR=`grep 'MAEDIR=*' $CONFIG_PATH | sed 's/MAEDIR=//1'`
    ARRIDIR=`grep 'ARRIDIR=*' $CONFIG_PATH | sed 's/ARRIDIR=//1'`
    RECHDIR=`grep 'RECHDIR=*' $CONFIG_PATH | sed 's/RECHDIR=//1'`
    ACEPDIR=`grep 'ACEPDIR=*' $CONFIG_PATH | sed 's/ACEPDIR=//1'`
    PROCDIR=`grep 'PROCDIR=*' $CONFIG_PATH | sed 's/PROCDIR=//1'`
    REPODIR=`grep 'REPODIR=*' $CONFIG_PATH | sed 's/REPODIR=//1'`
    LOGDIR=`grep 'LOGDIR=*' $CONFIG_PATH | sed 's/LOGDIR=//1'`
    LOGEXT=`grep 'LOGEXT=*' $CONFIG_PATH | sed 's/LOGEXT=//1'`
    LOGSIZE=`grep 'LOGSIZE=*' $CONFIG_PATH | sed 's/LOGSIZE=//1'`
    DATASIZE=`grep 'DATASIZE=*' $CONFIG_PATH | sed 's/DATASIZE=//1'`

    return 1
else
    return 0
fi
}

function getDefaultInstallationValues {
    GRUPO_DEFAULT="`pwd`/"
    CONFDIR_DEFAULT=conf
    BINDIR_DEFAULT=bin
    MAEDIR_DEFAULT=mae
    ARRIDIR_DEFAULT=arri
    RECHDIR_DEFAULT=rech
    ACEPDIR_DEFAULT=acep
    PROCDIR_DEFAULT=proc
    REPODIR_DEFAULT=repo
    LOGDIR_DEFAULT=log
    LOGEXT_DEFAULT=.log
    LOGSIZE_DEFAULT=4096
    DATASIZE_DEFAULT=4
}

# DEPRECATED: la funcion crea el config si no existe, si ya existe graba los valores nuevos
function writeConfigValues {
if [ -f CONFIG_PATH ];
then
    rm $CONFIG_PATH
fi
    echo "GRUPO=`pwd`/" > $CONFIG_PATH
    echo "CONFDIR=$CONFDIR" >> $CONFIG_PATH
    echo "BINDIR=$BINDIR" >> $CONFIG_PATH
    echo "MAEDIR=$MAEDIR" >> $CONFIG_PATH
    echo "ARRIDIR=$ARRIDIR" >> $CONFIG_PATH
    echo "RECHDIR=$RECHDIR" >> $CONFIG_PATH
    echo "ACEPDIR=$ACEPDIR" >> $CONFIG_PATH
    echo "PROCDIR=$PROCDIR" >> $CONFIG_PATH
    echo "REPODIR=$REPODIR" >> $CONFIG_PATH
    echo "LOGDIR=$LOGDIR" >> $CONFIG_PATH
    echo "LOGEXT=$LOGEXT" >> $CONFIG_PATH
    echo "LOGSIZE=$LOGSIZE" >> $CONFIG_PATH
    echo "DATASIZE=$DATASIZE" >> $CONFIG_PATH    
}

#si valor ya existe en el config actualizar lo
function writeSpecificConfigValue {
    VARIABLE=$1
    VALUE=$2

    TMP_FILE=$CONFIG_PATH"_tmp"
    
    if [ -f $CONFIG_PATH ];
    then
        #leer el valor
        checkValueAlreadyExistsInConfig $VARIABLE $VALUE
        retval=$?
        if [ "$retval" == 1 ];
        then
            return 0
        fi
        
        TEST=`grep "$VARIABLE=.*" $CONFIG_PATH | sed "s/$VARIABLE=//1 "`
    else
        TEST=""
    fi
    if [[ $TEST == "" ]];
    then
        #si variable no existe agregar
        echo "$VARIABLE=$VALUE" >> $CONFIG_PATH
    else
        #si existe actualizar valor
        #usamos sed con "," envez de "/" por las baras en los paths
        sed "s,$VARIABLE=.*,$VARIABLE=$VALUE,g" $CONFIG_PATH > $TMP_FILE
        mv $TMP_FILE $CONFIG_PATH
    fi
    return 1
}

#retorna 1 si valor ya existe sino retorna 0
function checkValueAlreadyExistsInConfig {
    conf_var=$1
    conf_val=$2

    VAR="BINDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi
    
    VAR="MAEDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="ARRIDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="RECHDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="ACEPDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$confval" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="PROCDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="REPODIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi

    VAR="LOGDIR"
    if [[ "$conf_var" != "$VAR" ]];
    then
        VAL=`retrieveSpecificConfigValue $VAR`
        if [ "$VAL" != "" -a "$conf_val" == "$VAL" ];
        then
            return 1
        fi
    fi
    
    return 0
}

function retrieveSpecificConfigValue {
    VARIABLE=$1
    RETURNVAL=`grep "$VARIABLE=*" $CONFIG_PATH | sed "s/$VARIABLE=//1 "`
    echo $RETURNVAL
}

function checkIfModulesComplete {
    lIST_MISSING_MODULES=();

    #si Modulo falta en el config o la carpeta no existe lo pone en el array
    # trabajo con elif porque sino me da un error en caso que checkeo si existe carpeta y le doy un parametro vacio
    if [ "$BINDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "BINDIR")
    elif [ ! -d $INSTALL_PATH$BINDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "BINDIR")
    fi
    if [ "$MAEDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "MAEDIR")
    elif [ ! -d $INSTALL_PATH$MAEDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "MAEDIR")
    fi
    if [ "$ARRIDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "ARRIDIR")
    elif [ ! -d $INSTALL_PATH$ARRIDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "ARRIDIR")
    fi
    if [ "$ACEPDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "ACEPDIR")
    elif [ ! -d $INSTALL_PATH$ACEPDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "ACEPDIR")
    fi    
    if [ "$RECHDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "RECHDIR")
    elif [ ! -d $INSTALL_PATH$RECHDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "RECHDIR")
    fi
    if [ "$PROCDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "PROCDIR")
    elif [ ! -d $INSTALL_PATH$PROCDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "PROCDIR")
    fi
    if [ "$LOGDIR" == "" ];
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "LOGDIR")
    elif [ ! -d $INSTALL_PATH$LOGDIR ]
    then
        lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "LOGDIR")
    fi
    
    checkIfFilesComplete

}

function checkIfFilesComplete {
     ## COMANDOS
    local GETPID="getPID.sh" 
    local INICIOX="InicioX.sh"
    local DETECTAX="DetectaX.sh"
    local INTERPRETE="Interprete.sh"
    local REPORTEX="ReporteX.pl" 
    local MOVERX="MoverX.sh" 
    local GLOGX="GlogX.sh"
    local VLOGX="VlogX.sh"
    local STARTX="StartX.sh"
    local STOPX="StopX.sh"
    ## ARCHIVOS DE CONFIGURACION
    local T1="T1.tab"
    local T2="T2.tab"
    ## ARCHIVOS MAESTROS
    local PSMAE="p-s.mae"
    local PPIMAE="PPI.mae"

    local comandos=($GETPID $INICIOX $DETECTAX $INTERPRETE $REPORTEX $MOVERX $GLOGX $VLOGX $STARTX $STOPX)
    local maestros=($PSMAE $PPIMAE)
    local config=($INSTALX $T1 $T2)

    checkIfFileInstalled "${BINDIR}" comandos[@]

    checkIfFileInstalled "${MAEDIR}" maestros[@]

    checkIfFileInstalled "${CONFDIR}" config[@]

}

function checkIfFileInstalled {
    declare -a directorio=$1
	declare -a archivos=("${!2}")
    local return_val=1
	for file in "${archivos[@]}"
	do
		fileExist "${directorio}/${file}"
		result=$?
		if [ $result -eq 0 ]; then
            lIST_MISSING_MODULES=("${lIST_MISSING_MODULES[@]}" "${directorio}/${file}")
			return_val=0
		fi
	done
	return $return_val
}


#Función para la memoria del valor.
function updateValue {
    DIR=$1
    NEW_VALUE=$2

    if [ "$DIR" == "BINDIR" ]; then
	BINDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "MAEDIR" ]; then
	MAEDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "ARRIDIR" ]; then
	ARRIDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "RECHDIR" ]; then
	RECHDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "ACEPDIR" ]; then
	ACEPDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "PROCDIR" ]; then
	PROCDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "REPODIR" ]; then
	REPODIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "LOGDIR" ]; then
	LOGDIR_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "LOGEXT" ]; then
	LOGEXT_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "LOGSIZE" ]; then
	LOGSIZE_DEFAULT=$NEW_VALUE
    elif [ "$DIR" == "DATASIZE" ]; then
	DATASIZE_DEFAULT=$NEW_VALUE
    fi

}

function processDir {
    DIR=$1
    DEFAULT_VALUE=$2
    TEXT=$3
    retval=$(retrieveSpecificConfigValue $DIR)

    #nomas preguntar si carpeta no existe o el valor no esta en la config
    #Si FORCE_PROMPT=1 se pregunta otravez todos los valores
    if [ "$retval" == "" -o $FORCE_PROMPT == 1 ];
    then
        echo $TEXT
        log "$TEXT" "I"

        while true
        do
            read -e VALUE_TEMP
            isValidDirectoryName $VALUE_TEMP
            ISVALIDDIRECTORYNAME=$?
            if [ "$ISVALIDDIRECTORYNAME" == 0 ]
            then
                echo "El valor ingresado es invalido. Nomas puede contener letras [a-z] o [A-Z] o numeros [0-9]"
                log "El valor ingresado es invalido. Nomas puede contener letras [a-z] o [A-Z] o numeros [0-9]" "A"
                continue
            elif [[ $VALUE_TEMP != "" ]]
            then
                VALUE=$VALUE_TEMP
                updateValue $DIR $VALUE_TEMP
                log "El usario ingreso: $VALUE_TEMP" "I"
            else
                VALUE=$DEFAULT_VALUE
                log "El usario no ingreso nada, el systema va a assumir el valor $DEFAULT_VALUE por defecto" "I"
            fi
            writeSpecificConfigValue $DIR $VALUE
            write_sucess=$?
            if [[ "$write_sucess" == 1 ]];
            then
                break
            else
                echo "Por favor ingrese otro valor ese directorio ya existe"
                log "Por favor ingrese otro valor ese directorio ya existe" "A"
            fi
        done
    fi
}

function processValue {
    SUBJECT=$1
    DEFAULT_VALUE=$2
    TEXT=$3
    retval=$(retrieveSpecificConfigValue $SUBJECT)
    if [[ $retval == "" ]];
    then
        echo $TEXT
        log "$TEXT" "I"
        read -e VALUE_TEMP
        
        if [[ $VALUE_TEMP != "" ]]
        then
            VALUE=$VALUE_TEMP
            updateValue $SUBJECT $VALUE
            log "El usario ingreso: $VALUE_TEMP" "I"
        else
            VALUE=$DEFAULT_VALUE
            log "El usario no ingreso nada, el sistema va a asumir el valor ${DEFAULT_VALUE} por defecto" "I"
        fi
        writeSpecificConfigValue $SUBJECT $VALUE
    fi
}

function processLogSize {
    SUBJECT=$1
    DEFAULT_VALUE=$2
    TEXT=$3
    retval=$(retrieveSpecificConfigValue $SUBJECT)
    if [ "$retval" == "" -o $FORCE_PROMPT == 1 ];
    then
        echo $TEXT
        log "$TEXT" "I"
        while true
        do
            read -e VALUE_TEMP
            isNumeric $VALUE_TEMP
            ISNUMERIC=$?
            if [ "$ISNUMERIC" == 0 ]
            then
                echo "Por favor ingrese un valor numerico"
                log "Por favor ingrese un valor numerico" "A"
                continue
            elif [[ $VALUE_TEMP != "" ]]
            then
                VALUE=$VALUE_TEMP
                log "El usario ingreso: $VALUE_TEMP" "I"
                updateValue $SUBJECT $VALUE
                break
            else
                VALUE=$DEFAULT_VALUE
                log "El usario no ingreso nada, el systema va a assumir el valor $DEFAULT_VALUE por defecto" "I"
                break
            fi
        done
        writeSpecificConfigValue $SUBJECT $VALUE
    fi
}

function processDataSize {
    #Si DATASIZE ya esta en el config no hay que preguntar de nuevo
    retval=$(retrieveSpecificConfigValue "DATASIZE")
    if [ "$retval" == "" -o $FORCE_PROMPT == 1 ];
    then

    while true
    do

        echo "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (En caso de dejar vacio este campo el sistema asume el valor $DATASIZE_DEFAULT MB por defecto):"

        log "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (En caso de dejar vacio este campo el sistema asume el valor $DATASIZE_DEFAULT MB por defecto):" "I"

        read -e DATASIZE_TEMP
        isNumeric $DATASIZE_TEMP
        ISNUMERIC=$?
        if [ "$ISNUMERIC" == 0 ]
        then
            echo "Por favor ingrese un valor numerico"
            log "Por favor ingrese un valor numerico" "A"
            continue
        elif [[ $DATASIZE_TEMP != "" ]]
        then
            DATASIZE=$DATASIZE_TEMP
            log "El usario ingreso: $VALUE_TEMP" "I"
            updateValue "DATASIZE" $DATASIZE
            break
        else
            DATASIZE=$DATASIZE_DEFAULT
            log "El usario no ingreso nada, el systema va a assumir el valor $DEFAULT_VALUE MB por defecto" "I"
            break
        fi
    done

    AVALIABLE_SPACE=`df -Phm / | tail -1 | awk '{print $4}'`

    while (("$DATASIZE" > "$AVALIABLE_SPACE" ))
    do
        echo "Insuficiente espacio en disco. Espacio disponible: $AVALIABLE_SPACE Mb."
        echo "Espacio requerido $DATASIZE Mb Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."
        echo "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (En caso de dejar vacio este campo el sistema asume el valor $DATASIZE_DEFAULT MB por defecto):"

        log "Insuficiente espacio en disco. Espacio disponible: $AVALIABLE_SPACE Mb." "SE"
        log "Espacio requerido $DATASIZE Mb Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor." "A"
        log "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (En caso de dejar vacio este campo el sistema asume el valor $DATASIZE_DEFAULT MB por defecto):" "I"

        read -e DATASIZE_TEMP
        isNumeric $DATASIZE_TEMP
        ISNUMERIC=$?
        if [ "$ISNUMERIC" == 0 ]
        then
            echo "Por favor ingrese un valor numerico"  
            log echo "Por favor ingrese un valor numerico" "I"
            continue
        elif [[ $DATASIZE_TEMP != "" ]]
        then
            DATASIZE=$DATASIZE_TEMP
            log "El usario ingreso: $VALUE_TEMP" "I"
            break
        else
            DATASIZE=$DATASIZE_DEFAULT
            log "El usario no ingreso nada, el systema va a assumir el valor $DEFAULT_VALUE por defecto" "I"
            break
        fi

        AVALIABLE_SPACE=`df -Phm $ARRIDIR | tail -1 | awk '{print $4}'`
    done
    writeSpecificConfigValue DATASIZE $DATASIZE
    fi
}

#retorna 1 si es numerico o vacio
function isNumeric {
    int_value=$1

    if [ "$int_value" == "" ]
    then
        return 1
    fi

    if [[ $int_value =~ ^-?[0-9]+$ ]]
    then
        return 1
    fi
    return 0
}

function saveConfigValuesToLog {
    log "Informaciones guardadas en el InstalX.conf:" "I"
    log "BINDIR=$BINDIR" "I"
    log "MAEDIR=$MAEDIR" "I"
    log "ARRIDIR=$ARRIDIR" "I"
    log "DATASIZE=$DATASIZE" "I"
    log "RECHDIR=$RECHDIR" "I"
    log "ACEPDIR=$ACEPDIR" "I"
    log "PROCDIR=$PROCDIR" "I"
    log "REPODIR=$REPODIR" "I"
    log "LOGDIR=$LOGDIR" "I"
    log "LOGEXT=$LOGEXT" "I"
    log "LOGSIZE=$LOGSIZE" "I"
    

}


function processAllData {

    processDir BINDIR $BINDIR_DEFAULT "Defina el directorio de instalación de los ejecutables (En caso de dejar vacio este campo el sistema asume el valor '$BINDIR_DEFAULT' por defecto):"

    processDir MAEDIR $MAEDIR_DEFAULT "Defina el directorio de instalación de los archivos maestros (En caso de dejar vacio este campo el sistema asume el valor $MAEDIR_DEFAULT por defecto):"

    processDir ARRIDIR $ARRIDIR_DEFAULT "Defina el directorio de arribo de archivos externos (En caso de dejar vacio este campo el sistema asume el valor $ARRIDIR_DEFAULT por defecto):"

    processDataSize

    processDir RECHDIR $RECHDIR_DEFAULT "Defina el directorio de grabación de los archivos externos rechazados (En caso de dejar vacio este campo el sistema asume el valor $RECHDIR_DEFAULT por defecto):"

    processDir ACEPDIR $ACEPDIR_DEFAULT "Defina el directorio de grabación de los archivos externos aceptados (En caso de dejar vacio este campo el sistema asume el valor $ACEPDIR_DEFAULT por defecto):"

    processDir PROCDIR $PROCDIR_DEFAULT "Defina el directorio de grabación de los archivos procesados (En caso de dejar vacio este campo el sistema asume el valor $PROCDIR_DEFAULT por defecto):"

    processDir REPODIR $REPODIR_DEFAULT "Defina  el  directorio  de  grabación  de  los  reportes  de  salida (En caso de dejar vacio este campo el sistema asume el valor $REPODIR_DEFAULT por defecto):"

    processDir LOGDIR $LOGDIR_DEFAULT "Defina el directorio de logs (En caso de dejar vacio este campo el sistema asume el valor $LOGDIR_DEFAULT por defecto):"

    processValue LOGEXT $LOGEXT_DEFAULT "Ingrese la extensión para los archivos de log: (En caso de dejar vacio este campo el sistema asume el valor $LOGEXT_DEFAULT por defecto)"

    processLogSize LOGSIZE $LOGSIZE_DEFAULT "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes (En caso de dejar vacio este campo el sistema asume el valor $LOGSIZE_DEFAULT Kbytes por defecto):"
}

function doInstallationProcess {

    isPerlInstalled
    is_perl_installed=$?

    getPerlVersion
    perl_version=$?

    if (("$is_perl_installed" == 0 || "$perl_version" < 5 ))
    then
        echo "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 09
            Para instalar el TP es necesario contar con Perl 5 o superior
            instalado. Efectúe su instalación e inténtelo nuevamente.
            Proceso de Instalación Cancelado"
        log "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 09
            Para instalar el TP es necesario contar con Perl 5 o superior
            instalado. Efectúe su instalación e inténtelo nuevamente.
            Proceso de Instalación Cancelado" "A"

        FINAL_MESSAGE="Installation finalizada"
        break
    else

        writeSpecificConfigValue GRUPO "`pwd`/"

        FORCE_PROMPT=0
        while true
        do
            echo "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 09 Perl Version: $perl_version"
            log "TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo 09 Perl Version: $perl_version" "I"

	    processAllData FORCE_PROMPT

            clear

            readConfigValues
            printInstallationInfo
            echo "Estado de la instalacion: LISTA"
            log "Estado de la instalacion: LISTA" "I"
            echo ""

            promtComplete "Quiere continuar la instalacion con estos valores? (Si-No)"
            retval=$?
            if [ "$retval" == 1 ]
            then
                break
            fi
            clear
            FORCE_PROMPT=1
        done

        promtComplete "Iniciando Instalación. Esta Ud. seguro? (Si-No)"
        retval=$?
        if [ "$retval" == 0 ]
        then
            FINAL_MESSAGE="Instalaction cancelada"
            break
        else
            echo "Creando Estructuras de directorio. . . ."
            log "Creando Estructuras de directorio. . . ." "I"
        fi

        readConfigValues
        createAllDirs

        #no es necesario actualizar la configuración en este punto de nuevo porque ya estan actualizado
        echo "Actualizando la configuración del sistema"
        log "Actualizando la configuración del sistema" "I"

        if [ ! -d "$INSTALL_PATH$MAEDIR"  ]; then
            mkdir $MAEDIR
        fi
        cp -Rf instalables/mae/* $INSTALL_PATH$MAEDIR/
        echo "Instalando Archivos Maestros"
        log "Instalando Archivos Maestros" "I"

        cp  -Rf instalables/conf/* $INSTALL_PATH$CONFDIR
        echo "Instalando Tablas de Configuración"
        log "Instalando Tablas de Configuración" "I"

        if [ ! -d "$INSTALL_PATH$BINDIR"  ]; then
            mkdir $BINDIR
        fi
        cp  -Rf instalables/bin/* $INSTALL_PATH$BINDIR/
        echo "Instalando Programas y Funciones"
        log "Instalando Programas y Funciones" "I"

        saveConfigValuesToLog

        FINAL_MESSAGE="Instalación concluida"
    fi
}

# Verifico la integridad del directorio de instalables
checkInstalablesIntegrity
if [ $? -ne 0 ]; then
    exit 1
fi

#Como el script se puede estar ejecutando por primera vez, verifico si existe el directorio "conf" y lo creo en caso de que no exista.
if [ ! -d "conf" ]
then
    mkdir conf
fi

# Variable definida para que el GlogX funcione correctamente.
GRUPO=""

# Establezco los permisos de ejecucion a GlogX
chmod 700 "instalables/bin/GlogX.sh"

while true
do

#INSTALL_PATH=$(retrieveSpecificConfigValue GRUPO)
INSTALL_PATH="`pwd`/"
getDefaultInstallationValues

CONFIG_PATH="conf/InstalX.conf"
LOG_PATH="conf/InstalX.log"

echo Inicio de Ejecución
echo Log del Comando InstalX: $LOG_PATH
echo Directorio de Configuración: $CONFIG_PATH

log "Inicio de Ejecucion" "I"
log "Log del Comando InstalX: $LOG_PATH" "I"
log "Directorio de Configuración: $CONFIG_PATH" "I"

#chequear si instalx.conf y todos los modules existen
if [ -f $CONFIG_PATH ];
then
    readConfigValues
    checkIfModulesComplete

    if [ "${lIST_MISSING_MODULES[0]}" == "" ];
    then
        printInstallationInfo
        instalation_status="COMPLETA"
        echo "Estado de la instalación: $instalation_status"
        echo "Proceso de Instalación Cancelado"
        log "Estado de la instalación: $instalation_status" "I"
        log "Proceso de Instalación Cancelado" "I"

    else
        #check if config is complete
        #if its complete, complete installation, if config has missing values promt missing values and finish installation
        echo "Componentes faltantes:"
        log "Componentes faltantes:" "E"
        for MISSING_MODULE in "${lIST_MISSING_MODULES[@]}"
        do
            echo $MISSING_MODULE
            log "$MISSING_MODULE" "E"
        done
        instalation_status="INCOMPLETA"
        echo "Estado de la instalación: $instalation_status"
        log "Estado de la instalación: $instalation_status" "I"
        promtComplete "Desea completar la instalación? (Si-No)"     #preguntar si desea continuar la instalación
        retval=$?
        if [ "$retval" == 0 ]
        then
            FINAL_MESSAGE="Installation finalizada"
            break
        else
            doInstallationProcess
        fi
    fi    
else      
            promtComplete 'TP SO7508 Primer Cuatrimestre 2013. Tema X Copyright © Grupo xx
                A T E N C I O N: Al instalar TP SO7508 Primer Cuatrimestre 2013 UD.
                expresa aceptar los términos y Condiciones del "ACUERDO DE LICENCIA DE
                SOFTWARE" incluido en este paquete.
                Acepta? Si – No'

                retval=$?
                if [ "$retval" == 0 ]
                then
                    FINAL_MESSAGE="Installation finalizada"
                    break
                else
                    touch conf/InstalX.conf
                    doInstallationProcess
                fi
fi

break
done

echo $FINAL_MESSAGE
log "$FINAL_MESSAGE" "I"
exit
