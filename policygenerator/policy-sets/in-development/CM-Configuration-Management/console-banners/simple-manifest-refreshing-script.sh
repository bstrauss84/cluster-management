#!/bin/bash

# Environments definition
declare -A environment=( ["dev"]="development" ["prod"]="production" ["mgmt"]="management" ["sbx"]="sandbox" )

for plat in "${!environment[@]}"
do 
   echo -e  "##\n# Generating ${environment[$plat]} configuration manifests\n##\n"
   kustomize build --enable-alpha-plugins ${plat}/ | tee policies-generators/${plat}/customized-config-manifest.yaml
   echo ""
done
