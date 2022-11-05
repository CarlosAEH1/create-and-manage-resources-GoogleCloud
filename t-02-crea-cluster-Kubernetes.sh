#@Autor:        CarlosAEH1
#@Fecha:        02/11/2022
#@Descripcion:  Crea cluster de servicio de Kubernetes.

#Configurando zona predeterminada.
gcloud config set compute/zone us-east1-b
#Creando cluster.
gcloud container clusters create mi-cluster
#Autenticando cluster.
gcloud container clusters get-credentials mi-cluster
#Creando objeto Deployment a partir de imagen de contenedor.
kubectl create deployment hello-server
--image=gcr.io/google-samples/hello-app:2.0
#Creando objeto Service de trafico externo.
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
#Inspeccionando onjeto Service.
kubectl get service