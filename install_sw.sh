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


### ---------- Criando Backup Sources List --------------- ###
mkdir ${DIRBKP}apt
cp /etc/apt/sources.list ${DIRBKP}apt
mv /etc/apt/sources.list /etc/apt/sourcesBkpSW.list 

echo "# Sources List debian 11 ">sources.list
echo "deb http://deb.debian.org/debian/ bullseye main">>sources.list
echo "deb-src http://deb.debian.org/debian/ bullseye main">>sources.list
echo " ">>sources.list
echo "deb http://security.debian.org/debian-security/ bullseye-security main">>sources.list
echo "deb-src http://security.debian.org/debian-security/ bullseye-security main">>sources.list
echo " ">>sources.list
echo "deb http://deb.debian.org/debian/ bullseye-updates main">>sources.list
echo "deb-src http://deb.debian.org/debian/ bullseye-updates main">>sources.list

mv sources.list /etc/apt/

### ---------- Removendo programas nao utilizaveis --------------- ###
apt remove --purge  xscreensaver* libreoffice* xsane* lxmusic* goldendict* deluge* mpv* smplayer* Evince* -y
apt clean
apt autoremove -y

### ---------- Instalando programas necessarios --------------- ###
apt install wget vbetool xdotool motion build-essential libssl-dev curl git dkms samba clementine "linux-headers-$(uname -r)" -y
apt install --reinstall bash-completion

apt update
apt upgrade -y




### ---------- IAdiciona Usuario ao grupo do root e no arquivo sudoers --------------- ###
gpasswd -a ${USERNAME} ${GROUP}
echo "${USERNAME}	ALL=NOPASSWD:ALL" >>/etc/sudoers



### ---------- Iniciar sem senha --------------- ###

###  Criar backup do arquivo lightdm.conf  ###

mkdir ${DIRBKP}lightdm
cp /etc/lightdm/lightdm.conf ${DIRBKP}lightdm
mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdmBkpSW.conf

###  Setar configuracoes   ###
echo "[LightDM]">lightdm.conf
echo "[Seat:*]">>lightdm.conf
echo "autologin-user=${USERNAME}">>lightdm.conf

mv lightdm.conf /etc/lightdm/


### ------------------------------------------------------- Configuração de rede --------------------------------------------- ###

###  Criar backup do arquivo interfaces  ###

mkdir ${DIRBKP}network
cp /etc/network/interfaces ${DIRBKP}network
mv /etc/network/interfaces /etc/network/interfacesBkpSW

###  Setar configuracoes de ip ns interface de rede  ###

echo "## Configuração de rede ">interfaces
echo "auto lo">>interfaces
echo "iface lo inet loopback">>interfaces

echo "#Ip fixo">>interfaces
echo "auto enp3s0">>interfaces
echo "allow-hotplug enp3s0">>interfaces
echo "iface enp3s0 inet static">>interfaces
echo "	address ${IP[0]}.${IP[1]}.${IP[2]}.${IP[3]}">>interfaces
echo "	netmask 255.255.255.0">>interfaces
echo "	broadcast ${IP[0]}.${IP[1]}.${IP[2]}.255">>interfaces
echo "	network ${IP[0]}.${IP[1]}.${IP[2]}.0">>interfaces
echo "	gateway ${IP[0]}.${IP[1]}.${IP[2]}.1">>interfaces
echo "	 ">>interfaces
echo "	dns-nameservers ${IP[0]}.${IP[1]}.${IP[2]}.1 8.8.8.8">>interfaces

mv interfaces /etc/network/


###  Criar backup do arquivo resolv.conf  ###
cp /etc/resolv.conf ${DIRBKP}
mv /etc/resolv.conf /etc/resolvBkpSW.conf

###  Setar configuracoes de DNS  ###
echo "">resolv.conf
echo "nameserver ${IP[0]}.${IP[1]}.${IP[2]}.1">>resolv.conf
echo "nameserver 8.8.8.8">>resolv.conf

mv resolv.conf /etc/

###  Criar backup do arquivo Hostname  ###
cp /etc/hostname ${DIRBKP}
mv /etc/hostname /etc/hostnameBkpSW

###  Setar configuracoes de Hostname  ###
echo "${APPNAME}">hostname
mv hostname /etc/


###  Criar backup do arquivo Hosts  ###
cp /etc/hosts ${DIRBKP}
mv /etc/hosts /etc/hostsBkpSW

###  Setar configuracoes de Hosts  ###
echo "">hosts
echo "127.0.0.1	localhost">>hosts
echo "127.0.1.1	${APPNAME}.local">>hosts
echo "${IP[0]}.${IP[1]}.${IP[2]}.${IP[3]} ${APPNAME}.local">>hosts
echo " ">>hosts
echo "# The following lines are desirable for IPv6 capable hosts">>hosts
echo "::1     localhost ip6-localhost ip6-loopback">>hosts
echo "ff02::1 ip6-allnodes">>hosts
echo "ff02::2 ip6-allrouters">>hosts

mv hosts /etc/


### ---------- Configurar issue --------------- ###
###  Criar backup do arquivo issue.net  ###
cp /etc/issue.net ${DIRBKP}
mv /etc/issue.net /etc/issueBkpSW.net
###  Setar configuracoes de issue.net  ###
echo "Bem Vindo ao ${APPNAME}! ">issue.net
mv issue.net /etc/
###  Criar backup do arquivo issue ###
cp /etc/issue ${DIRBKP}
mv /etc/issue /etc/issueBkpSW
###  Setar configuracoes de issue  ###
echo "Bem Vindo ao ${APPNAME}! ">issue
mv issue /etc/


###  Criar backup do arquivo motd ###
cp /etc/motd ${DIRBKP}
mv /etc/motd /etc/motdBkpSW
###  Setar configuracoes de motd  ###
echo "Bem Vindo ao ${APPNAME}! ">motd
mv motd /etc/


###  Criar backup do arquivo issue ###
mkdir ${DIRBKP}ssh
cp /etc/ssh/sshd_config ${DIRBKP}ssh
mv /etc/ssh/sshd_config /etc/ssh/sshd_configBkpSW
###  Setar configuracoes de issue  ###
echo "PermitRootLogin yes">> /etc/ssh/sshd_config


### ---------- Gerar Shell Autostart --------------- ###

cd /opt/
echo "#!/bin/bash" >hass.sh
echo "/usr/bin/VBoxManage startvm hass –-type headless">>hass.sh
chmod +x hass.sh

echo "#!/bin/bash" >node-red.sh
echo "node-red">>node-red.sh
chmod +x node-red.sh

echo "#!/bin/bash" > mirror.sh
echo "cd /opt/MagicMirror/">> mirror.sh
echo "DISPLAY=:0 npm run server ">> mirror.sh
chmod +x mirror.sh

echo "#!/bin/bash" > motion.sh
echo "motion">> motion.sh
chmod +x motion.sh

echo "#!/bin/bash" > kioskMode.sh
echo "xset s noblank" >>kioskMode.sh
echo "xset s off" >>kioskMode.sh
echo "xset -dpms" >>kioskMode.sh
echo "firefox -kiosk --new-window http://${APPNAME}.local:8080 http://homeassistant.local:8123" >>kioskMode.sh
echo "" >>kioskMode.sh
echo "while true; do" >>kioskMode.sh
echo "xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;" >>kioskMode.sh
echo "sleep 35" >>kioskMode.sh
echo "done" >>kioskMode.sh
chmod +x kioskMode.sh

wget https://download.anydesk.com/linux/anydesk_6.2.0-1_amd64.deb
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
dpkg -i anydesk_6.2.0-1_amd64.deb
apt autoremove -y
apt --fix-broken install -y
rm -r anydesk_6.2.0-1_amd64.deb

wget https://sourceforge.net/projects/webadmin/files/webmin/1.999/webmin-1.999.tar.gz
tar xvfz webmin-1.999.tar.gz
cd webmin-1.999
./setup.sh /usr/local/webmin
rm "-r" webmin-1.999
rm "-r" webmin-1.999.tar.gz

apt update
apt install apache2 -y
apt install apache2 apache2-utils -y
a2enmod rewrite
a2enmod headers
apt install mariadb-server mariadb-client -y
apt install libapache2-mod-php php php-mysql php-cli php-pear php-gmp php-gd php-bcmath php-mbstring php-curl php-xml php-zip -y
systemctl restart apache2

apt install phpmyadmin -y


# Construct the MySQL query
readonly Q1="GRANT ALL PRIVILEGES ON *.* TO '${USERNAME}'@'localhost'  IDENTIFIED BY '${PASSWORD}' WITH GRANT OPTION;"
readonly Q2="FLUSH PRIVILEGES;"
readonly SQL="${Q1}${Q2}"

# Run the actual command
mysql -uroot -p -e "$SQL"





#nextcloud
wget https://download.nextcloud.com/server/releases/nextcloud-24.0.3.zip
unzip nextcloud-*.zip
mv nextcloud /var/www/html/
rm -r nextcloud-*.zip

# Construct the MySQL query
readonly Q1="CREATE DATABASE IF NOT EXISTS nextcloud;"
readonly Q2="GRANT ALL ON *.* TO '${USERNAME}'@'localhost' IDENTIFIED BY '${PASSWORD}';"
readonly Q3="FLUSH PRIVILEGES;"
readonly SQL="${Q1}${Q2}${Q3}"

# Run the actual command
mysql -uroot -p -e "$SQL"




echo "<VirtualHost *:1980>">nextcloud.conf
echo "     ServerAdmin admin@example.com">>nextcloud.conf
echo "     DocumentRoot /var/www/html/nextcloud">>nextcloud.conf
echo "     ServerName example.com">>nextcloud.conf
echo "     ServerAlias www.example.com">>nextcloud.conf
echo "">>nextcloud.conf
echo "     <Directory /var/www/html/nextcloud/>">>nextcloud.conf
echo "          Options FollowSymlinks">>nextcloud.conf
echo "          AllowOverride All">>nextcloud.conf
echo "          Require all granted">>nextcloud.conf
echo "     </Directory>">>nextcloud.conf
echo "">>nextcloud.conf
echo "     ErrorLog \${APACHE_LOG_DIR}/error.log">>nextcloud.conf
echo "     CustomLog \${APACHE_LOG_DIR}/access.log combined">>nextcloud.conf
echo "    ">>nextcloud.conf
echo "     <Directory /var/www/html/nextcloud/>">>nextcloud.conf
echo "            RewriteEngine on">>nextcloud.conf
echo "            RewriteBase /">>nextcloud.conf
echo "            RewriteCond %{REQUEST_FILENAME} !-f">>nextcloud.conf
echo "            RewriteRule ^(.*) index.php [PT,L]">>nextcloud.conf
echo "    </Directory>">>nextcloud.conf
echo "</VirtualHost>">>nextcloud.conf
mv nextcloud.conf  /etc/apache2/sites-available/
chown "-R" www-data:www-data /var/www/html/nextcloud/
a2dissite 000-default.conf
a2ensite nextcloud.conf
a2enmod headers rewrite env dir mime

###  Criar backup do arquivo ports ###
mkdir ${DIRBKP}apache2
cp /etc/apache2/ports.conf ${DIRBKP}apache2
mv /etc/apache2/ports.conf /etc/apache2/portsBkpSW.conf
###  Setar configuracoes de ports.conf  ###
echo "Listen 80">ports.conf
echo "Listen 1980">>ports.conf
echo "">>ports.conf
echo "<IfModule ssl_module>">>ports.conf
echo "    Listen 443">>ports.conf
echo "</IfModule>">>ports.conf
echo "">>ports.conf
echo "<IfModule mod_gnutls.c>">>ports.conf
echo "    Listen 443">>ports.conf
echo "</IfModule>">>ports.conf

mv ports.conf /etc/apache2/



systemctl reload apache2





clear
echo "Digite a senha do Usuario ${USERNAME} - [Serviço] Compartilhamento de Arquivos"
smbpasswd "-a" ${USERNAME}

mkdir /home/musicas
mkdir /home/videos
mkdir /home/imagens
chmod 777 /home/imagens
chmod 777 /home/videos
chmod 777 /home/musicas 
chmod 777 /var/www/html/nextcloud/data/sweethome/files 

#---- SMB ----
echo "[global]">smb.conf
echo "	winbind use default domain = yes">>smb.conf
echo "	netbios name = SweetHome">>smb.conf
echo "	obey pam restrictions = yes">>smb.conf
echo "	server role = standalone server">>smb.conf
echo "	unix password sync = yes">>smb.conf
echo "	logging = file">>smb.conf
echo "	os level = 20">>smb.conf
echo "	workgroup = SweetHome">>smb.conf
echo "	log file = /var/log/samba/log.%m">>smb.conf
echo "	max log size = 1000">>smb.conf
echo "	usershare allow guests = yes">>smb.conf
echo "	winbind trusted domains only = yes">>smb.conf
echo "	map to guest = bad user">>smb.conf
echo "	passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .">>smb.conf
echo "	panic action = /usr/share/samba/panic-action %d">>smb.conf
echo "	load printers = no">>smb.conf
echo "	passwd program = /usr/bin/passwd %u">>smb.conf
echo "	pam password change = yes">>smb.conf
echo "">>smb.conf
echo "">>smb.conf
echo "[Musicas]">>smb.conf
echo "	path = /home/musicas">>smb.conf
echo "	writeable = yes">>smb.conf
echo "">>smb.conf
echo "[Videos]">>smb.conf
echo "	path = /home/videos">>smb.conf
echo "	writeable = yes">>smb.conf
echo "">>smb.conf
echo "[Imagens]">>smb.conf
echo "	writeable = yes">>smb.conf
echo "	path = /home/imagens">>smb.conf
echo "">>smb.conf
echo "[NV_SweetHome]">>smb.conf
echo "	path = /var/www/html/nextcloud/data/sweethome/files">>smb.conf
echo "	writeable = yes">>smb.conf
echo "	force group = www-data">>smb.conf
echo "	directory mode = 777">>smb.conf
echo "	force user = www-data">>smb.conf
echo "	create mode = 777">>smb.conf

mkdir ${DIRBKP}samba
cp /etc/samba/smb.conf ${DIRBKP}samba
mv /etc/samba/smb.conf /etc/samba/smbBkpSW.conf 
mv smb.conf /etc/samba/

service smbd restart

#    virtualbox

wget https://download.virtualbox.org/virtualbox/6.1.36/virtualbox-6.1_6.1.36-152435~Debian~bullseye_amd64.deb
dpkg "-i" virtualbox-6.1_6.1.36-152435~Debian~bullseye_amd64.deb
apt "--fix-broken" install -y
rm "-r" virtualbox-6.1_6.1.36-152435~Debian~bullseye_amd64.deb
adduser ${USERNAME} vboxusers
wget https://download.virtualbox.org/virtualbox/6.1.36/Oracle_VM_VirtualBox_Extension_Pack-6.1.36a-152435.vbox-extpack
vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.36a-152435.vbox-extpack
rm "-r" Oracle_VM_VirtualBox_Extension_Pack-6.1.36a-152435.vbox-extpack


#Criar maquina Virtual HASS
cd /opt/
mkdir homeassistant
cd homeassistant
wget https://github.com/home-assistant/operating-system/releases/download/8.4/haos_ova-8.4.vdi.zip
mkdir hass
unzip haos_ova-8.4.vdi.zip
mv /opt/homeassistant/haos_ova-8.4.vdi /opt/homeassistant/hass/



/usr/bin/vboxmanage createvm --name hass --ostype Debian_64 --register --basefolder /opt/homeassistant/hass
/usr/bin/vboxmanage modifyvm hass --cpus 1 --memory 512 --vram 8
/usr/bin/VBoxManage modifyvm hass --firmware efi
/usr/bin/vboxmanage modifyvm hass --bioslogodisplaytime 0
/usr/bin/vboxmanage modifyvm hass --boot1 disk
/usr/bin/vboxmanage storagectl hass --name sata --add sata --portcount 1
/usr/bin/vboxmanage storagectl hass --name sata --hostiocache off
/usr/bin/vboxmanage storagectl hass --name sata --bootable on
/usr/bin/vboxmanage storagectl hass --name sata --controller IntelAHCI
/usr/bin/vboxmanage storageattach hass --storagectl sata --port 0 --type hdd --medium /opt/homeassistant/hass/haos_ova-8.4.vdi --mtype normal
/usr/bin/vboxmanage modifyvm hass --clipboard disabled
/usr/bin/vboxmanage modifyvm hass --acpi on --ioapic on
/usr/bin/vboxmanage modifyvm hass --usb on --usbehci on
/usr/bin/vboxmanage modifyvm hass --pae on --hwvirtex on --nestedpaging on --largepages on --vtxvpid on
/usr/bin/vboxmanage modifyvm hass --cpuexecutioncap 100
/usr/bin/vboxmanage modifyvm hass --nic1 bridged --bridgeadapter1 enp3s0 --macaddress1 FACADACABECA --cableconnected1 on --nicpromisc1 deny

echo "/opt/kioskMode.sh">>/home/sweethome/.config/lxsession/LXDE/autostart

cd /opt
mkdir backups
chmod 777 /opt/backups
tar -czvf backup_instalSW_$(date +'%d_%m_%Y').tar.gz BackupConfsInstall/
mv backup_instalSW* /opt/backups/
rm "-r" /opt/BackupConfsInstall







echo "#!/bin/bash">vboxstart.sh
echo "iniciar()">>vboxstart.sh
echo "{">>vboxstart.sh
echo "	/usr/bin/VBoxHeadless -startvm hass">>vboxstart.sh
echo "}">>vboxstart.sh
echo "parar()">>vboxstart.sh
echo "{">>vboxstart.sh
echo "	/usr/bin/VBoxManage controlvm hass poweroff">>vboxstart.sh
echo "}">>vboxstart.sh
echo "case \"$1\" in">>vboxstart.sh
echo "	start)">>vboxstart.sh
echo "		iniciar;;">>vboxstart.sh
echo "	stop)">>vboxstart.sh
echo "		parar;;">>vboxstart.sh
echo "	*)">>vboxstart.sh
echo "		echo \"Formato: /etc/init.d/vboxstart.sh {start|stop}\"">>vboxstart.sh
echo "		exit 1">>vboxstart.sh
echo "esac">>vboxstart.sh
echo "exit 0">>vboxstart.sh
chmod 755 vboxstart.sh 
mv vboxstart.sh /etc/init.d/
update-rc.d vboxstart.sh defaults 99










apt remove --purge connman* -y
reboot
} # this ensures the entire script is downloaded #
