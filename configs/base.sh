#!/bin/bash  

# base folder
basePath="$1"
tenant="$2"
environment="$3"

if [[ -z "$basePath" ]]; then
 echo "missing input basepath"
 exit 1;
fi

if [[ -z "$tenant" ]]; then
 echo "missing input tenant"
 exit 1;
fi

if [[ -z "$environment" ]]; then
 echo "missing input environment"
 exit 1;
fi

cd $basePath
rm -f kustomization.yaml
kustomize init 

for file in *; 
do 
    echo "Processing $file file..."
    
    fileNameWithOutPath=`basename $file`
    fileNameExtn=${fileNameWithOutPath##*.}
    fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`
    kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=$fileNameWithOutPath
done



cd ../tenants/$tenant/$environment
rm -f kustomization.yaml
kustomize init 
echo
echo
pwd
for file in *; 
do 
    echo "Processing $file file..."
    
    fileNameWithOutPath=`basename $file`
    fileNameExtn=${fileNameWithOutPath##*.}
    fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`

    file=$file yq ea '. *= load(env(file))' "$basePath/$fileNameWithOutPath" > tenants/$tenant/merged-$environment/$fileNameWithOutPath
    kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=merge --from-file=$fileNameWithOutPath
done