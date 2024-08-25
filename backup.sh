###################################################################
# Programa:
# Descripcion:
#		Realiza respaldo diferenciales/incremental de la carpeta a 
#     respaldar.
# Autor: Victor J. Mejia Lara
# Licencia: GPL V3
#				https://www.gnu.org/licenses/gpl-3.0.en.html
####################################################################
# Uso del script para generar respaldos incrementas y diferenciales
# backup.sh DIRECTORIO_RESPALDAR UBICACION_RESPALDO
#! /bin/bash -w

DATE=`/usr/bin/date +%d_%m_%y`
DAY=`/usr/bin/date +%d`
TAR='/usr/bin/tar cvf'
TARINC='/usr/bin/tar -uvf'
TARDIF='/usr/bin/tar -A'
GZIP='/usr/bin/gzip'
ANTIVIRUS=`which clamscan`
BACKUPDIR=""
DEVICE="/tmp"

if [ -z $ANTIVIRUS ]; then
	echo "NO FOUND CLAMSCAN"
else
	echo $ANTIVIRUS 
fi


scanvirus() {
	echo "Starting scanning..."
	`$ANTIVIRUS -l /tmp/scanresult.txt -i -r --remove=yes $BACKUPDIR > /dev/null`
	
	if [ $? -ne 0 ]; then
		echo "Error: clamscan"
		exit 1
	fi
}

backupFile() {
	cd $DEVICE
	FINDTAR=`find ./ -type f -name "backupKradnet_??_??_??.tar" | tail -1`
	DAYTAR=`echo $FINDTAR | cut -d '_' -f 2`
	MONTHTAR=`echo $FINDTAR | cut -d '_' -f 3`
	YEARTAR=`echo $FINDTAR | cut -d '_' -f 4 | cut -d '.' -f 1`

###############################################################
#	Crear el respaldo en caso de que no existiera uno anterior #
###############################################################
	echo "------$FINDTAR"
	if [ -z $FINDTAR ]; then
		echo "Starting backup..."
		BACKUPFILE="$DEVICE/backupKradnet_$DATE.tar"

		$TAR $BACKUPFILE $BACKUPDIR

##############################################################
# Realiza un respaldo anual de todos los archivos.           #
##############################################################
	elif [ $YEARTAR -lt $(date +%y) ]; then
		echo "Year"

		rsync -ar $DEVICE/$FINDTAR $DEVICE/backuprKradnet_$(date +%y).tar
      $GZIP $DEVICE/backupKradnet_$(date +%y).tar

		rm -f $DEVICE/backupKradnet_$YEARTAR*
		sleep 1
		rm -f $DEVICE/backupKradnet_??_$MONTHTAR*

#############################################################
# Realiza un respaldo mensual de todos los archivox         #
#############################################################
	elif [ $MONTHTAR -lt $(date +%m) ]; then
		echo "Month"
		rsync -ar $DEVICE/$FINDTAR $DEVICE/backupKradnet_$(date +%m_%y).tar
		$GZIP $DEVICE/backupKradnet_$(date +%m_%y).tar

		rm -f $DEVICE/backupKradnet_??_$MONTHTAR*

#############################################################
# Realiza respaldos diarios                                 #
#############################################################
	elif [ $DAYTAR -lt $(date +%d) ]; then
		MONTHYEAR=`/usr/bin/date +%m_%y`

		#Se agregan los archivos que se hayn modificado en las ultimas 24hrs.
		echo -e "\e[1;34mAgregando archivos \e[1;33mmodificados \e[1;34mal respaldo\e[0m"
		find $BACKUPDIR -mtime -1 -exec tar rvf $DEVICE/backupKradnet_$DAY"_"$MONTHYEAR.tar {} \;

		sleep 5
		if [ $? -ne 0 ]; then
			echo "Error al actualizar el respaldo"
			exit 0
		fi

		echo "Comprimiendo...."
		$GZIP $DEVICE/$FINDTAR
		if [ $? -ne 0 ]; then
			echo "Error al comprimir el archivo backupKradnet_$DATE"
		fi
	else
		echo "No new"
	fi
}

if [ $# -eq 0 ]; then
	echo "Backup $PWD"
	BACKUPDIR=$PWD
else
	BACKUPDIR=$1
fi

if [ ! -z $ANTIVIRUS ]; then
#	scanvirus
echo ""
fi

if [ ! -z $2 ]; then
	DEVICE=$2
fi

backupFile
