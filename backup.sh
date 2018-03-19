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
	FINDTAR=`find $DEVICE -type f -name "backupIntegra*.tar" | tail -1 | cut -d '/' -f 3`
	DAYTAR=`echo $FINDTAR | cut -d '_' -f 2`
	MONTHTAR=`echo $FINDTAR | cut -d '_' -f 3`
	YEARTAR=`echo $FINDTAR | cut -d '_' -f 4 | cut -d '.' -f 1`
	
	echo "------$FINDTAR"
	if [ -z $FINDTAR ]; then
		echo "Starting backup..."
		BACKUPFILE="$DEVICE/backupIntegra_$DATE.tar"

		$TAR $BACKUPFILE $BACKUPDIR

	elif [ $YEARTAR -lt $(date +%y) ]; then
		echo "Year"

		cp $DEVICE/$FINDTAR $DEVICE/backupIntegra_$(date +%y).tar
      $GZIP $DEVICE/backupIntegra_$(date +%y).tar

		rm -f $DEVICE/backupIntegra_$YEARTAR*

	elif [ $MONTHTAR -lt $(date +%m) ]; then
		echo "Month"
		cp $DEVICE/$FINDTAR $DEVICE/backupIntegra_$(date +%m_%y).tar
		$GZIP $DEVICE/backupIntegra_$(date +%m_5y).tar

		rm -f $DEVICE/backupIntegra_??_$MONTHTAR*

	elif [ $DAYTAR -lt $(date +%d) ]; then
		cp $DEVICE/$FINDTAR $DEVICE/backupIntegra_$DATE.tar

		echo -e "\e[1;34mAgregando archivos nuevos al respaldo\e[0m"

		#Se agregan los archivos nuevos al archivo de respaldo
		$TARINC $DEVICE/backupIntegra_$DATE.tar $BACKUPDIR

		if [ $? -ne 0 ]; then
			echo "Error al generar la actualizacion"
			exit 0
		fi

		#Se agregan los archivos que se hayn modificado en las ultimas 24hrs.
		echo -e "\e[1;34mAgregando archivos \e[1;33mmodificados \e[1;34mal respaldo\e[0m"
		find $BACKUPDIR -mtime -1 -exec tar rvf $DEVICE/backupIntegra_$DATE.tar {} \;

		sleep 5
		if [ $? -ne 0 ]; then
			echo "Error al actualizar el respaldo"
			exit 0
		fi

		echo "Comprimiendo...."
		$GZIP $DEVICE/$FINDTAR
		if [ $? -ne 0 ]; then
			echo "Error al comprimir el archivo backupIntegra_$DATE"
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
