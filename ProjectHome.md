# Sistema de reservas #
Sistemas Operativos (75.08) - Facultad de Ingeniería, Universidad de Buenos Aires




### AUTORES ###

  * Belén Beltrán (belubeltran@gmail.com)
  * Fiona González Lisella (fgonzalezlisella@gmail.com)
  * Alejandro Olivera (aa.olivera@hotmail.com)
  * Marcos Forlenza (mnforlenza@gmail.com)
  * Federico Rossi (federicomrossi@gmail.com)



---

## DESCARGA ##


Obtenga la última versión del programa haciendo [CLICK AQUÍ](http://ubuntuone.com/0LQ3VZsmGpboVWC8E0zZhy)




---

## GUÍA DE INSTALACIÓN ##


  1. Insertar el dispositivo de almacenamiento con el contenido del sistema. Desde ahora < origen >
  1. Crear en el directorio corriente un directorio de trabajo. Desde ahora < dir\_instalacion >
  1. Copiar el archivo TPGRUPO10.tar.gz en el directorio de trabajo. (cp < origen >/TPGRUPO10.tar.gz < dir\_instalacion >).
  1. Descomprimir el archivo TPGRUPO10.tar.gz del directorio actual < dir\_instalacion > (tar -xvzf < dir\_instalacion >/TPGRUPO10.tar.gz).
  1. Se generará un directorio llamado grupo10. Puede borrar si desea el archivo .tar.gz (rm < dir\_instalacion >/TPGRUPO10.tar.gz).
  1. Entrar en el directorio < dir\_instalacion >/grupo10 y ejecutar el script Intalar\_TP.sh.  (Se deberá dar permisos de ejecución de ser necesario)

La instalación le pedirá que ingrese los distintos directorios para los ejecutables, archivos maestros, archivos externos,
archivos externos aceptados, archivos externos rechazados, listados de salida, archivos procesados, archivos de log.
A su vez también deberá definir la extensión de los archivos de log, el tamaño máximo del log y el tamaño mínimo para el arribo de archivos externos.
La instalación creará los directorios ingresados por el usuario y copiará los archivos maestros, ejecutables y de procesamiento.

El único requisito para poder ejecutar el sistema RESER\_B es contar con una versión de Perl superior a la 5.



---

## GUÍA DE USO ##


Una vez que se complete la instalación podrá iniciar la ejecución del sistema RESER\_B simplemente ejecutando el script Iniciar\_B.sh.

NOTA: Se deberá correr el script de la siguiente forma " . Iniciar\_B.sh"