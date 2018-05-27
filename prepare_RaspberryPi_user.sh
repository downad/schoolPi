#!/bin/bash

# Version
#VERSION="0.1 - vom 1. Mai 2018" 
VERSION="0.2 - vom 1. Mai 2018"

# Initial

# Fingerprint of RaspberryPiMasterServerKey.gpg
# in this version this must put in by hand 
fprint="4DF6F07704F910FBD2D4622401CDF90F5F8D071F"

# path on the Pi 
PATH_schoolPi="/root/schoolPi"
# path on the RaspberryPiMasterServer
PATH_RaspberryPiMasterServer="schoolPi"

# File with the IP of the RaspberyPiMasterServers
RMS_IP_FILE="${schoolPiFolder}/RMS_IP"

# after prepare is done get this files on RaspberryPiMasterServer
FILE_TO_GET="init_script.tar.gz.gpg"
FILE_TO_EXTRACT="init_script.tar.gz"
FILE_TO_EXECTUTE="${schoolPiFolder}/init/prepare_step2.sh"

# File mit dem Public-Key
FILE_WITH_PUBLIC_KEY="RaspberryPiMasterServerKey.gpg"


get_RMS_path()
{
	# Userinput: Path on RaspberryPiMasterServers
	YANSWER="y"
	YORN="n"
	while [ "$YANSWER" != "$YORN" ]
	Path_RMS=${PATH_RaspberryPiMasterServer}
	do
   echo "aktuell ist der Pfad: ${Path_RMS} eingetragen."
	 echo "Stimmt das?  (yes/no/cancel) ?"
	 read ANSWER
	 YORN=`echo $ANSWER | tr [:upper:] [:lower:] | cut -c 1`
	 if [ "$YORN" = "n" ]; then
	 	read -p "Pfad zum RaspberryPiMAsterServer:" ${Path_RMS}
	 fi
	 if [ "$YORN" = "c" ]; then
	 	echo "Pfad zum RaspberryPiMAsterServer wurde nicth geändert."
	 fi
 	 if [ "$YORN" = "y" ]; then
	 	echo "Der Pfad zum RaspberryPiMAsterServer lautet: ${Path_RMS}"
	 	${PATH_RaspberryPiMasterServer}=${Path_RMS}
	 fi
	done 
}

get_file() 
{
	# von dieser http-Seite soll die Datei $1 abgeholt werden
  url="http://${RMS_IP}/${PATH_RaspberryPiMasterServer}/$1"

	if wget --spider ${url}; then
	wget --no-cache --quiet  ${url}
    echo "get_file: Der Download der Datei $1 war möglich."
    # echo "get_file: $1 - downloaded "
    return 0
	else
    echo "get_file: Das File oder der Server waren nicht erreichbar!"
    #echo "get_file: RMS or file not found."
		return 1
	fi
}
write_netrc()
{
	if [ ! -f ${RMS_IP_FILE} ]; then 
		echo "Keine IP für RaspberryPiMasterServer."
		# Erster Start des Scrips, lege Verteichnisse an
		get_RMS_IP
	else
		# wenn es eine RMS_IP gibt gehts weiter
		source ${RMS_IP_FILE} 
	fi
	
	# Userinput: login and Password für .htacess on RaspberryPiMasterServers
	YANSWER="y"
	YORN="n"
	echo "zu Testzwecken: login = r.weinert"
	echo "zu Testzwecken: password = 9!r7hP8_"
	
	while [ "$YANSWER" != "$YORN" ]
	do
   read -p  "Bitte Login für den .htacess eingetragen." ${login}
   read -p  "Das Passwort bitte." ${password}
	 
	 echo "Stimmt das?  (yes/no) ?"
	 read ANSWER
	 YORN=`echo $ANSWER | tr [:upper:] [:lower:] | cut -c 1`
	done
	# schreibe die .netrc
	# diese Datei speichert Zugangsdaten, das ist im Moment (Mai 2018) wichtig, da
	# RaspberryPiMasterServer auf einem Apache mit .htacces läuft

	# lösche die alte .netrc
	mv /root/.netrc /root/.netrc.bak

	# lege eine .netrc in /root an
	touch /root/.netrc
	chmod 600 /root/.netrc
	echo "machine ${RMS_IP} login ${login} password ${password}" >> /root/.netrc
}
get_RMS_IP()
{
	# Userinput: IP des RaspberryPiMasterServers
	YANSWER="y"
	YORN="n"
	while [ "$YANSWER" != "$YORN" ]
	do
	 read -p "IP vom RaspberryPiMaster: " RMS_IP
	 echo "Der RaspberryPiMasterServer hat die IP: ${RMS_IP}"
	 echo "Stimmt das?  (yes/no) ?"
	 read ANSWER
	 YORN=`echo $ANSWER | tr [:upper:] [:lower:] | cut -c 1`
	done

	
	# Folder $schoolPiFolder exist - no? then create it 
	if [ ! -d "$schoolPiFolder" ]; then
		mkdir ${schoolPiFolder}	
	fi
	
	# delete RMS_IP and rewrite it 
	# default /root/schoolPi/RMS_IP
	rm ${RMS_IP_FILE} 
	echo "RMS_IP=${RMS_IP}" >> ${RMS_IP_FILE} 
}

verify_signature() {
	local file=$1 out=
	if out=$(gpg --status-fd 1 --verify "$file" 2>/dev/null) &&
		 echo "$out" | grep -qs "^\[GNUPG:\] VALIDSIG $fprint "; then # &&
		 #echo "$out" | grep -qs "^\[GNUPG:\] TRUST_ULTIMATE\$"; then
		  return 0
	else
		  echo "$out" >&2
		  return 1
	fi
}

clear_files() 
{
	# remove File ${FILE_TO_GET}
	echo "Lösche ${FILE_TO_GET}"
	rm ${FILE_TO_GET}
	# remove public key file
	echo "Lösche ${FILE_WITH_PUBLIC_KEY}"
	rm ${FILE_WITH_PUBLIC_KEY}
	# remove the valide ${FILE_TO_GET} output
	echo "Lösche ${FILE_TO_EXTRACT}"
	rm ${FILE_TO_EXTRACT}
}

# wenn ein Parameter übergeben wurde muss das ausgewertet werden
if [ $# -gt 0 ] 
then
  switch=${1:1}
  case "$switch" in
    h)
      echo "## - ## - ## - ## - ## - ## - ## - ## - ##"
      echo "## SchoolPi - sript: prepareSchoolPi.sh ##"
      echo "## - ## - ## - ## - ## - ## - ## - ## - ##"
      echo "Aufruf: sudo ./prepareSchoolPi.sh [Optionen]" 
			echo "-h	  diese Seite."
			echo "-l 		Login für .htacces auf RMS setzen."
      echo "-n    IP für RaspberryPiMasterServer neu setzen."
      echo "-p  	Pfad auf RaspberryPiMasterServer neu setzen."
			echo "-v    Version des Scripts."
      exit 1
      ;;
    l)
      echo "Zugangsdaten für einen RMS mit .htacess"
      write_netrc
      exit 1
      ;;
    n)
      echo "Neue IP für RMS"
      get_RMS_IP
      exit 1
      ;;
    p)
      echo "Neuer RMS Pfad"
      get_RMS_path
      exit 1
      ;;     
    v)
			echo "Verion: $VERSION"
      exit 1
      ;;
    *)
      echo "Aufruf: sudo ./prepare_RaspberryPi_user.sh [-h|n|p|v]"
      exit 1
  esac
fi

#zu testzwecken
clear_files

# Prüfe ob prepare fertig ist - gibt es ein prepareDone?
if [ ! -f ${RMS_IP_FILE} ]; then 
  echo "Keine IP für RaspberryPiMasterServer."
  # Erster Start des Scrips, lege Verteichnisse an
  get_RMS_IP
else
  # wenn es eine RMS_IP gibt gehts weiter
  source ${RMS_IP_FILE} 
fi


# hole das init-Paket
# $Ready_for_the_firstrun=true
$Ready_for_the_firstrun=0
if get_file ${FILE_TO_GET} ; then
  echo "${FILE_TO_GET} geladen." 
  #hole das  Shellscript - firstrun
  if get_file ${FILE_WITH_PUBLIC_KEY} ; then
    echo "Public Key geladen" 
  else
    echo "public-key nicht gefunden!"
    #$Ready_for_the_firstrun=false
    $Ready_for_the_firstrun=1
  fi
else
  echo "Download von ${FILE_TO_GET} war nicht möglich."
  #$Ready_for_the_firstrun=false
  $Ready_for_the_firstrun=1
fi
    

if  $Ready_for_the_first_run ; then
	#importiere den Public Key
	# gpg --delete-key ralf.weinert@seewiesenschule.de 
	echo "Importiere den Public Key von RaspberryPiMasterServer"
	gpg --import ${FILE_WITH_PUBLIC_KEY}

	#prüfe ob die Datei von RaspberryPiMasterServer ist
	if verify_signature  ${FILE_TO_GET}; then
		echo "Die Signatur stimmt!"
		echo "Entpacke das gpg-File"
		gpg --output ${FILE_TO_EXTRACT} --decrypt  ${FILE_TO_GET}
		echo "Kopiere den Inhalt nach ${schoolPiFolder}."
		tar -zxvf ${FILE_TO_EXTRACT} -C  ${schoolPiFolder}

		# mache das Stratscript ausführbar
	  chmod +x ${FILE_TO_EXECUTE}
		
		# Starte das Skript
	  sh ${FILE_TO_EXECUTE}
	fi

fi
clear_files

# get hostname, IP and MAC
ifconfigValue=$(sudo ifconfig -a |sed -n "/^.*eth0/{n;p;n;p;n;p}") 

MyIP=$(echo  $ifconfigValue | awk '$1 == "inet"  {print $2}')
MyMAC=$(sudo ifconfig -a |sed -n "/^.*eth0/{n;p;n;p;n;p}" | awk '$1 == "ether" {print $2}')
MyHostname=$(hostname)
echo "ifconfig Rohdaten: $ifconfigValue"
echo "myhost: $MyHostname"
echo "myIP: $MyIP"
echo "myMAC: $MyMAC"

## scp ein ALL-Done to the RaspberyPiMasterServer
evlt. scp myValue 



