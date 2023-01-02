#!/bin/bash  
tenant=$1
basePath="defaults"
env=$2

rm -rfd tenants/$tenant/merged-*
mkdir -p tenants/$tenant/merged-$env
kustomize create
kustomize edit set namespace $tenant-$env

for file in tenants/$tenant/$env/*.yaml; 
do 
    echo "Processing $file file..."
    
    fileNameWithOutPath=`basename $file`
    fileNameWithOutPathAndExtn=`basename $file .yaml`
    
    file=$file yq ea '. *= load(env(file))' "$basePath/$fileNameWithOutPath" > tenants/$tenant/merged-$env/$fileNameWithOutPath
    kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=tenants/$tenant/merged-$env/$fileNameWithOutPath
done

mv kustomization.yaml tenants/$tenant/merged-$env

# yq ea '. *= load("tenants/kla/$env/podinfo-values.yaml")' $basePath/podinfo-values.yaml


# base folder
basePath="base"
extn="yaml"
cd $basePath
rm -f kustomization.yaml

kustomize create 

for file in *.$extn; 
do 
    echo "Processing $file file..."
    
    #fileNameWithOutPath=`basename $file`
    #fileNameWithOutPathAndExtn=`basename $file .$extn`
    #kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=$fileNameWithOutPath
done
