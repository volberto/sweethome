#!/usr/bin/env bash
# Arquivo de Instalação/Configuração do SweetHome
# Volberto Cavazzotto

{ # Script de instalação SweetHome #

### ---------- Configuracao de viariaveis --------------- ###
USERNAME="sweethome"
PASSWORD="sweethome"
GROUP="root"
APPNAME="sweethome"
IPADDRESS="192.168.0.10"
DIRBKP="/opt/BackupConfsInstall/"

IFS='.'
read -ra IP <<< "$IPADDRESS"


### ---------- Configuracao da pasta de Backup --------------- ###
mkdir ${DIRBKP}
chmod 777 ${DIRBKP}



reboot
} # this ensures the entire script is downloaded #
