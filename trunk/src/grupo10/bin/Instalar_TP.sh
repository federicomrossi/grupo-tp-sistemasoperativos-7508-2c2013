#! /bin/bash

#Sistemas Operativos
#Modulo Instalador
#Nombre: Instalar_TP.sh
#Autor: Grupo 10

#Definicion variables y constantes
BIN=`pwd`
CONFDIR="$BIN/../confdir"
log="$CONFDIR/Instalar_TP.log"



log (){
	perl -I$BIN -Mfunctions -e "functions::Grabar_L('Grabar_L', '$1', '$2', '$log')"	
}
log I "hola como va buey"
exit 0