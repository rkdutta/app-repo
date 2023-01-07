#!/bin/bash  

# for base 

runFor=$1 # base or tenant
basePath="$2"
tenant="$3"
environment="$4"

if [[ -z "$runFor" ]]; then
 echo "missing input runFor [base or tenant]"
 exit 1;
fi

if [[ -z "$basePath" ]]; then
 echo "missing input basePath"
 exit 1;
fi


if [[ "$runFor" == "base" ]]; then 
    cd $basePath
    rm -f kustomization.yaml
    kustomize init
elif [[ "$runFor" == "tenant" && "$environment" != "" ]]; then 
    cd $basePath
    rm -f kustomization.yaml
    kustomize init
    kustomize edit add resource "../../../base"
    kustomize edit set namespace $tenant-$environment
else
    echo "Unsupported -  $runFor / $basePath / $environment"
    exit 1
fi

for dir in */ ; do
    echo "Processing in $dir"

    for file in $dir*; 
    do 
        echo "Processing $file file..."
        
        fileNameWithOutPath=`basename $file`
        fileNameExtn=${fileNameWithOutPath##*.}
        fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`
   
        if [[ $dir == "envs/" ]]; then
            kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-env-file=$file --disableNameSuffixHash
        elif [[ $dir == "files/" ]]; then
            kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=$file --disableNameSuffixHash
        elif [[ $dir == "values/" ]]; then
            kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=create --from-file=values.yaml=$file --disableNameSuffixHash
        else
            echo "Unsupported directory structure -  $dir"
            exit 1
        fi
    done
done


# # for tenants

# cd ../tenants/$tenant/$environment
# rm -f kustomization.yaml
# kustomize init
# kustomize edit add resource "../../../base"

# kustomize edit set namespace $tenant-$environment

# for dir in */ ; do
#     echo "Processing in $dir"

#     for file in $dir*; 
#     do 
#         echo "Processing $file file..."
        
#         fileNameWithOutPath=`basename $file`
#         fileNameExtn=${fileNameWithOutPath##*.}
#         fileNameWithOutPathAndExtn=`basename $file .$fileNameExtn`
   
#     if [[ $dir == "files/" ]]; then
#         kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=merge --from-file=$file
#     elif [[ $dir == "envs/" ]]; then
#         kustomize edit add configmap $fileNameWithOutPathAndExtn --behavior=merge --from-env-file=$file
#     else
#         echo "Unsupported directory structure -  $dir"
#         exit 1
#     fi
#     done
# done
