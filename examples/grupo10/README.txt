TP SO7508 1mer cuatrimestre 2012. Tema x Copyright © Grupo 10

README
------

Este archivo readme incluye información sobre la instalación y ejecución de la
aplicación


AUTORES
-------

Grupo 10 está conformado por:
Emiliano Suárez
Federico Rodriguez Ramos
Juan Ignacio Jodra
Leticia Casarreal Ramirez 
Luciano Lattes


PREREQUISITOS
-------------

- Se debe tener permiso de escritura en el directorio donde se llevará a cabo la
instalación
- Debe estar instalado Perl 5 o superior


INSTALACIÓN
-----------

1- Crear un directorio con nombre 'grupo10'

2- Descomprimir y desempaquetar el archivo 'TP_grupo10.tgz' en el directorio 
grupo10

3- Ejecutar el script 'InstalarU.sh' para comenzar con el proceso de instalación

4- A continuacion el programa de instalación realizará una verificación en busca
de posibles instalaciones previas

4.1- Si no se detecta ninguna instalación previa se continuará con la 
instalación completa del sistema
4.2- Si se detecta una instalación previa completa se abortará el proceso de
instalación, dejando la instalación existente intacta
4.3- Si se detecta una instalación previa incompleta (falta algún componente) se
instalarán solo los componentes faltantes

5- Componentes que se deberán definir para la instalación

5.1- Directorio donde se instalarán los ejecutables y programas auxiliares
5.2- Directorio donde se instalarán los archivos maestros
5.3- Directorio para la recepción de archivos externos (nuevas instalaciones)
5.4- Directorio donde se grabarán los archivos rechazados
5.5- Directorio donde se grabarán los logs de auditoría
5.6- Directorio donde se grabarán los reportes
5.7- Espacio mínimo libre en disco para el arribo de archivos externos
5.8- Tamaño máximo para los archivos de log
5.9- Extensión para los archivos de log

6- Al finalizar la instalación se habrán creado los directorios según lo 
especificado. Esta sería una posible estructura de directorios, suponiendo que 
se hayan elegido todos los valores por defecto:

.
├── arribos
├── bin
│   ├── DetectarU.sh
│   ├── functions.pm
│   ├── GrabarParqueU.sh
│   ├── IniciarU.sh
│   ├── ListarU.pl
│   ├── LoguearU.pl
│   ├── MirarU.pl
│   ├── MoverU.pl
│   ├── StartD.sh
│   ├── StopD.sh
│   └── VerificarInstalacion.sh
├── clean.sh
├── confdir
│   ├── InstalarU.conf
│   └── InstalarU.log
├── InstalarU.sh
├── log
├── mae
│   ├── cli.mae
│   ├── prod.mae
│   └── sucu.mae
├── README.txt
├── rechazos
└── reportes


EJECUCIÓN Y UTILIZACION
-----------------------

1. Una vez instalado el sistema ejecutar el script 'IniciarU.sh'. Esto pondrá a
correr el programa
2. Miestras el programa se esté ejecutando un proceso scaneará constantemente el
directorio de arribos archivos externos, detectando cuando haya nuevos archivos
de instalaciones para procesar
3. Para realizar consultas sobre los datos procesados, se cuenta con el comando 
ListarU.sh. Ver la documentación del comando para más detalles 
4. A cada paso de la ejecución se guardan mensajes en los archivos de log 
correspondientes. Para consultar estos registros se cuenta con el comando 
MirarU.pl. Ver la documentación del comando para más detalles
5. Para terminar la ejecucion habrá que ejecutar el script StopD.sh

