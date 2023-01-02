#!/bin/bash  
tenant=$1
basePath="defaults"
env=$2

rm -rfd merged-*

for file in tenants/$tenant/$env/*.yaml; 
do 
    echo;echo;
    echo "Processing $file file..."
    mkdir -p tenants/$tenant/merged-$env
    file=$file yq ea '. *= load(env(file))' "$basePath/`basename $file`" > tenants/$tenant/merged-$env/`basename $file`

done
# yq ea '. *= load("tenants/kla/$env/podinfo-values.yaml")' $basePath/podinfo-values.yaml
