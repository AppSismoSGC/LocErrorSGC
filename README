# Pasos a seguir para realizar simulacion de disenio de estaciones.

1. Ejecutar el script 'gen_rand_st.py' para generar listado de estaciones con posiciones aleatorias. Se crea un archivo llamado 'station.dat'
2. Ejecutar el script 'gen_events.py' para generar archivo de eventos. Se puede modificar el parametro 'ds' de espaciamiento deseado en kilometros de la grilla, asi como los limites de la grilla en x y en y. Se crea un archivo llamado 'events.dat'
3. Crear un nuevo directorio 'Resol_#' donde iran los resultados de la simulacion
4. Copiar el contenido del directorio 'loc_error' dentro del nuevo directorio creado
5. Copiar el archivo 'disp_res.py' al directorio creado
6. Remplazar los archivos 'station.dat' y 'events.dat' copiados desde 'loc_error', por los archivos creados en los puntos 1 y 2.
7. Dentro del directorio creado, abrir matlab en modo consola: $ matlab -nodesktop
7.1. Ejecutar los siguientes programas en matlab:
	>> create_COL_FRACK # genera modelo de velocidad ---> se corre una vez
	>> synthetic_create # genera sinteticos ---> para simular mas de un sismo por sitio y cambiar profundidades a simular, modificar archivo 'synthetic.pf'
	>> locate_eq # localiza sismos
8. Para ejecutar los scripts de matlab desde la terminal:
        $matlab -nosplash -r synthetic_create
	$nohup matlab -nojvm -r locate_eq -logfile lognohup.out </dev/null &
9. Ejecutar el script 'disp_res.py' para visualizar los resultados.

Para el caso en que se quiera utilizar el Hypocenter para localizar los eventos sinteticos:
10. Copiar station2hypo.py, arrival2nordic.py y gen_locout.py al directorio de trabajo.

11. Copiar el archivo STATION0.HYP que se encuentra en /bd/seismo/WOR/DisenoRedesMonitoreo al
    directorio de trabajo y verificar que, bajo la linea con la palabra 'RELOC' se encuentra la 
    la palabra 'Inter'.

12. Ejecutar el comando que modifica el STATION0.HYP:
    $python station2hypo.py station.dat STATION0.HYP

13. Ejecutar el script para crear archivos en formato nordico (S-FILES):
    $python arrival2nordic.py arrival.dat

14. Crear un directorio y mover los s-file a esa ruta. Mover el STATION0.HYP a este directorio:
    $mkdir SFILE; mv *L.S* SFILE/; cp STATION0.HYP SFILE/

15. Ir al nuevo directorio y ejecutar Hypocenter
    $cd SFILE/
    $time update
16. Generar el archivo de salida loc_out.dat:
    $python gen_locout.py
17. Mover el archivo loc_out.dat al directorio anterior y generar graficas con resultados.
