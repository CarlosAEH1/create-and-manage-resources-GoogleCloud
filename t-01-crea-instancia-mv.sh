#@Autor:        CarlosAEH1
#@Fecha:        02/11/2022
#@Descripcion:  Crea instancia de maquina virtual.

#Configurando zona predeterminada.
gcloud config set compute/zone us-east1-b
#Creando instancia.
gcloud compute instances create gcelab2 --machine-type=f1-micro 