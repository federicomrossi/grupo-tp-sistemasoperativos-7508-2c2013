#!/usr/bin/perl

# 
#############################################################################
# Trabajo práctico N°1
# Grupo 10
# 75.08 - Sistemas Operativos
# Facultad de Ingeniería
# Universidad de Buenos Aires
# #############################################################################
#
# COMANDO IMPRIMIR_B --------- Opcion i ---------------
#

# DEBUG: Se deben modificar estas variables por las de entorno
$REPODIR = "../listados";
$PROCDIR = "../procesados";

# Variable que contiene los eventos candidatos
%candidatos;

# Se busca en el archivo 'reservas.ok' los registros que contienen referencia interna
open(reservas_ok, "<$PROCDIR/reservas.ok") or die "Couldn't open file $PROCDIR/reservas.ok, $!";

while(<reservas_ok>){
   print "$_";
}