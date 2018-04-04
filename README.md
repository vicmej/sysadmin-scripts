<h1> sysadmin-scripts </h1>
Scripts en bash para administración de servidores Linux.

# backup.sh
Script que permite realizar respaldos diferenciales e incrementales de la carpeta seleccionada por el usuario
y realiza rotación de archivos. La rotación se realiza de la siguiente manera:
1. Cada día genera un respaldo.
2. Al llegar al fin de mes genera un respaldo del mes y borra los demás respaldos de cada uno de los días del mes.
3. Al llegar al fin de año genera un respaldo anual de todos los meses y borra los respaldo del mes.

# monamictlan.sh
Script que obtiene direcciones IP's que están verificando aplicaciones web mal configurada por el puerto 80 pero 
el puerto se está usando para conexiones ssh.
