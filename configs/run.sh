#!/bin/bash  
tenant="kla"
basePath="defaults"
env="acc"

for file in tenants/$tenant/$env/*.yaml; 
do 
    echo;echo;
    echo "Processing $file file..."
    file=$file yq ea '. *= load(env(file))' "$basePath/`basename $file`"

done
# yq ea '. *= load("tenants/kla/$env/podinfo-values.yaml")' $basePath/podinfo-values.yaml
