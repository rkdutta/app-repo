#!/bin/bash  

# for base 

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

for dir in */ ; do
    echo "Processing in $dir"

    for file in $dir*; 
    do 
        echo "Processing $file file..."
        
        fileNameWithOutPath=`basename $file`
        fileNameExtn=${fileNameWithOutPath##*.}
        fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`
   
    if [[ $dir == "files/" ]]; then
        kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=$file
    elif [[ $dir == "envs/" ]]; then
        kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-env-file=$file
    else
        echo "Unsupported directory structure -  $dir"
        exit 1
    fi
    done
done


# for tenants

cd ../tenants/$tenant/$environment
rm -f kustomization.yaml
kustomize init
kustomize edit add resource "../../../base"

kustomize edit set namespace $tenant-$environment

for dir in */ ; do
    echo "Processing in $dir"

    for file in $dir*; 
    do 
        echo "Processing $file file..."
        
        fileNameWithOutPath=`basename $file`
        fileNameExtn=${fileNameWithOutPath##*.}
        fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`
   
    if [[ $dir == "files/" ]]; then
        kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=merge --from-file=$file
    elif [[ $dir == "envs/" ]]; then
        kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=merge --from-env-file=$file
    else
        echo "Unsupported directory structure -  $dir"
        exit 1
    fi
    done
done
