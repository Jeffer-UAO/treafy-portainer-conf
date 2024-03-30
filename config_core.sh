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
sed -i 's/#Port 22/Port ${{ SSH_PORT }}/' /etc/ssh/sshd_config

# Permitir puerto en el firewall y eliminar el puerto 22
ufw allow ${{ SSH_PORT }}/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw deny 22/tcp

# Crear el usuario admin y darle permisos de root
useradd -m -s /bin/bash ${{ }}
echo "${{ USER_ADMIN }}:${{ USER_ADMIN_PASSWORD}}" | chpasswd
usermod -aG sudo ${{ USER_ADMIN }}

# Crear el usuario ssh y darle permisos solo para SSH
useradd -m -s /bin/bash ${{ SSH_USER }}
echo "${{ SSH_USER }}:${{ SSH_USER_PASSWORD }}" | chpasswd

# Creamos el usuario administrador de docker
adduser ${{ USER_DOCKER }}
usermod -aG docker ${{ USER_DOCKER }}
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
public_key=${{ PUBLIC_KEY }}

echo "$public_key" >> /home/ssheasy/.ssh/authorized_keys


@REM # Mantener la session activa
@REM # Agregar configuraciones ServerAliveInterval y ServerAliveCountMax al archivo de configuración
@REM configInterval="ServerAliveInterval 120"
@REM configCount="ServerAliveCountMax 3"
@REM echo $configInterval >> /home/ssheasy/.ssh/config/config_file
@REM echo $configCount >> /home/ssheasy/.ssh/config/config_file


# Instalar Lynis y antimalware 
apt install -y lynis nginx supervisor python3.10 python3-pip cron chkrootkit apache2-utils

# Configurar el treafy
sed -i 's/email: tucorreo@mail.com/email: '${{ EMAIL_TRAEFY }}'/' /opt/core/traefik-data/traefik.yml

contrasenaTraefikfinal=$(htpasswd -nb ${{ TRAEFY_USER }} ${{ TRAEFY_PASSWORD }})
#echo $contrasenaTraefikfinal

#CAMBIAR PERMISO DE
 chmod 600 /opt/core/traefik-data/acme.json

#AGREGAR contrasena en el archivo dynamic.yml
contrasenaDefaulttraefik='enriqueta:$apr1$ZeOc\/mrN$KTGGyWGpp3\/1vPzhBu3as1'
sed -i 's#'$contrasenaDefaulttraefik'#'$contrasenaTraefikfinal'#' /opt/core/traefik-data/configurations/dynamic.yml

chown ${{ USER_DOCKER }}:${{ USER_DOCKER }} -R /opt/core/

echo "Configuración completa. Reiniciando el servidor para aplicar todos los cambios..."
ufw --force enable
reboot


@REM # Quedaria pendiente que ingreses al archivo ssh/sshd_config, antes de hacer esto debes verificar el ingreso por ssh con el nuevo usuario
@REM # y modifiqus la configuracion para quitar el acceso a root y ingreso por contraseña
@REM # PasswordAuthentication no
@REM # ChallengeResponseAuthentication no
@REM # PermitRootLogin no
@REM # Luego configurar fail2ban
