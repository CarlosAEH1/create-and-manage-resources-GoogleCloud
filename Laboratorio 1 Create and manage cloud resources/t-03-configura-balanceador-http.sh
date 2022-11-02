#@Autor:        CarlosAEH1
#@Fecha:        01/11/2022
#@Descripcion:  Configura un balaceador de cargas HTTP.

#Configurando region prederminada.
gcloud config set compute/region us-east1
#Configurando zona predeterminada.
gcloud config set compute/zone us-east1-b
#Abriendo script para configurar servidores web de NGINX.
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
#Creando plantilla de intancias para servidores web de NGINX.
gcloud compute instance-templates create plantilla-servidor-web \
--network=nucleus-vpc \
--machine-type=g1-small \
--metadata-from-file=startup-script=startup.sh
#Creando grupo de instancias administrado.
gcloud compute instance-groups managed create grupo-servidor-web \
--template=plantilla-servidor-web \
--base-instance-name=web-server \
--size 2
#Asignando puerto (80/TCP) a grupo de instancias administrado.
gcloud compute instance-groups managed set-named-ports grupo-servidor-web \
--named-ports=http:80
#Creando regla de firewall (80/TCP).
gcloud compute firewall-rules create firewall-servidor-web \
--network=nucleus-vpc \
--allow=tcp:80
#Creando una verificacion de estado.
gcloud compute http-health-checks create http-basic-check
#Creando servicio de backend.
gcloud compute backend-services create backend-servidor-web \
--protocol=HTTP \
--http-health-checks=http-basic-check \
--global
#Asignando grupo de instancias administrado a servicio de backend.
gcloud compute backend-services add-backend backend-servidor-web \
--instance-group=grupo-servidor-web \
--global
#Creando mapa de URL.
gcloud compute url-maps create mapa-servidor-web \
--default-service=backend-servidor-web
#Segmentando proxy HTTP para enrutar solicitudes a mapa de URL.
gcloud compute target-http-proxies create http-lb-proxy \
--url-map=mapa-servidor-web
#Creando regla de reenvio.
gcloud compute forwarding-rules create permit-tcp-rule-261 \
--global \
--target-http-proxy=http-lb-proxy \
--ports=80