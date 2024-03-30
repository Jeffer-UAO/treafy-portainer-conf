#!/bin/bash

# Actualizar el sistema
apt update
apt upgrade -y

# Remover docker Uninstall old versions
apt remove docker-ce docker-ce-cli containerd.io -y
apt remove docker docker-engine docker.io containerd runc -y


# 
# Actualizar el índice de paquetes apt e instalar paquetes para permitir que apt utilice un repositorio a través de HTTPS:
# 
apt update
apt install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release



# Añade la clave GPG oficial de Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Utilice el siguiente comando para configurar el repositorio:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


# Cambiar el puerto SSH

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese en nuevo puerto ssh'
echo '#########################################################'
echo '#########################################################'

read sshPort

sed -i 's/#Port 22/Port $sshPort/' /etc/ssh/sshd_config

# Permitir puerto en el firewall
ufw allow $sshPort/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 22/tcp

# Crear el usuario admin y darle permisos de root

echo '#########################################################'
echo '#########################################################'
echo 'Crear el usuario admin'
echo 'Ingrese nombre de usuario administrador'
echo '#########################################################'
echo '#########################################################'

read userAdmin

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese contraseña'
echo '#########################################################'
echo '#########################################################'

read -s passAdmin

echo '#########################################################'
echo '#########################################################'
echo 'Crear el usuario ssh'
echo 'Ingrese nombre de usuario ssh'
echo '#########################################################'
echo '#########################################################'

read userSsh

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese contraseña'
echo '#########################################################'
echo '#########################################################'

read passSsh

echo '#########################################################'
echo '#########################################################'
echo 'Crear el usuario Docker'
echo 'Ingrese nombre de usuario Docker'
echo '#########################################################'
echo '#########################################################'

read userDocker

useradd -m -s /bin/bash $userAdmin
echo "$userAdmin:$passAdmin" | chpasswd
usermod -aG sudo ${{ USER_ADMIN }}

# Crear el usuario ssh y darle permisos solo para SSH
useradd -m -s /bin/bash $userSsh
echo "$userSsh:$passSsh" | chpasswd

# Creamos el usuario administrador de docker
adduser $userDocker
usermod -aG docker $userDocker
git clone https://github.com/Jeffer-UAO/treafy-portainer-conf.git          
mv treafy-portainer-conf/core/ /opt/

# Crear directorios para config ssh
mkdir -p /home/ssheasy/.ssh
mkdir /home/ssheasy/.ssh/config
touch /home/ssheasy/.ssh/config/config_file
touch /home/ssheasy/.ssh/authorized_keys
chmod 700 /home/ssheasy/.ssh
chmod 600 /home/ssheasy/.ssh/authorized_keys
chown -R ssheasy:ssheasy /home/ssheasy/.ssh

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese llave publica ssh para conectar usuario ssh'
echo '#########################################################'
echo '#########################################################'

read keyPublica

public_key=$keyPublica

echo "$public_key" >> /home/ssheasy/.ssh/authorized_keys


# @REM # Mantener la session activa
# @REM # Agregar configuraciones ServerAliveInterval y ServerAliveCountMax al archivo de configuración
# @REM configInterval="ServerAliveInterval 120"
# @REM configCount="ServerAliveCountMax 3"
# @REM echo $configInterval >> /home/ssheasy/.ssh/config/config_file
# @REM echo $configCount >> /home/ssheasy/.ssh/config/config_file


# Instalar Lynis y antimalware 
apt install -y lynis nginx supervisor python3.10 python3-pip cron chkrootkit apache2-utils

# Configurar el treafy

echo '#########################################################'
echo '#########################################################'
echo 'Conficuraciones Traefy'
echo 'Ingrese correo ssl'
echo '#########################################################'
echo '#########################################################'

read sslEmail

sed -i 's/email: tucorreo@mail.com/email: '$sslEmail'/' /opt/core/traefik-data/traefik.yml

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese nombre de usuario '
echo '#########################################################'
echo '#########################################################'

read traefyUser

echo '#########################################################'
echo '#########################################################'
echo 'Ingrese contraseña'
echo '#########################################################'
echo '#########################################################'

read -s traefyPass

contrasenaTraefikfinal=$(htpasswd -nb $traefyUser $traefyPass)
#echo $contrasenaTraefikfinal

#CAMBIAR PERMISO DE
 chmod 600 /opt/core/traefik-data/acme.json

#AGREGAR contrasena en el archivo dynamic.yml
contrasenaDefaulttraefik='enriqueta:$apr1$ZeOc\/mrN$KTGGyWGpp3\/1vPzhBu3as1'
sed -i 's#'$contrasenaDefaulttraefik'#'$contrasenaTraefikfinal'#' /opt/core/traefik-data/configurations/dynamic.yml

chown $userDocker:$userDocker -R /opt/core/

echo "Configuración completa. Reiniciando el servidor para aplicar todos los cambios..."
ufw --force enable
reboot


# @REM # Quedaria pendiente que ingreses al archivo ssh/sshd_config, antes de hacer esto debes verificar el ingreso por ssh con el nuevo usuario
# @REM # y modifiqus la configuracion para quitar el acceso a root y ingreso por contraseña
# @REM # PasswordAuthentication no
# @REM # ChallengeResponseAuthentication no
# @REM # PermitRootLogin no
# @REM # Luego configurar fail2ban
